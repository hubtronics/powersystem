from flask import Flask, render_template, request, redirect, url_for, flash, session, make_response
from werkzeug.security import generate_password_hash, check_password_hash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, login_required, logout_user, current_user, UserMixin
import os
import urllib.parse

# ----- Setup -----
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, 'garage.db')

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + DB_PATH
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Security settings for production
if os.environ.get('FLASK_ENV') == 'production':
    app.config['SESSION_COOKIE_SECURE'] = True
    app.config['SESSION_COOKIE_HTTPONLY'] = True
    app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

# ----- Models -----
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), default='staff')

    def check_password(self, pw):
        return check_password_hash(self.password_hash, pw)

class Customer(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    phone = db.Column(db.String(50))
    email = db.Column(db.String(200))
    # Relationship to vehicles
    vehicles = db.relationship('Vehicle', backref='customer', lazy=True)

class Vehicle(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('customer.id'), nullable=False)
    plate_number = db.Column(db.String(20), nullable=False)
    vin = db.Column(db.String(50), unique=True, nullable=False)
    make = db.Column(db.String(50), nullable=False)
    model = db.Column(db.String(50), nullable=False)
    year = db.Column(db.Integer)
    color = db.Column(db.String(30))
    mileage = db.Column(db.Integer)
    created_date = db.Column(db.DateTime, default=db.func.current_timestamp())
    # Relationship to service visits
    service_visits = db.relationship('ServiceVisit', backref='vehicle', lazy=True, cascade='all, delete-orphan')

class ServiceVisit(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicle.id'), nullable=False)
    visit_date = db.Column(db.DateTime, default=db.func.current_timestamp())
    service_type = db.Column(db.String(100), nullable=False)  # Engine, Suspension, Brakes, etc.
    description = db.Column(db.Text)  # Detailed description of work
    customer_complaint = db.Column(db.Text)  # What customer reported
    work_performed = db.Column(db.Text)  # What was actually done
    service_price = db.Column(db.Float, default=0)  # Fixed service price
    labor_hours = db.Column(db.Float, default=0)  # Keep for reference but not billing
    labor_rate = db.Column(db.Float, default=0)  # Keep for reference but not billing
    labor_cost = db.Column(db.Float, default=0)  # Will be same as service_price
    total_cost = db.Column(db.Float, default=0)  # Total including parts and service price
    status = db.Column(db.String(20), default='Completed')  # Completed, In Progress, Scheduled
    notes = db.Column(db.Text)  # Additional notes
    technician = db.Column(db.String(100))  # Who performed the work
    # Relationship to parts used
    parts_used = db.relationship('PartUsed', backref='service_visit', lazy=True, cascade='all, delete-orphan')

class PartUsed(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    service_visit_id = db.Column(db.Integer, db.ForeignKey('service_visit.id'), nullable=False)
    part_number = db.Column(db.String(100), nullable=False)
    part_name = db.Column(db.String(200), nullable=False)
    part_description = db.Column(db.String(300))
    quantity = db.Column(db.Integer, default=1)
    unit_cost = db.Column(db.Float, default=0)  # Cost per unit
    delivery_cost = db.Column(db.Float, default=0)  # Shipping/delivery cost
    total_part_cost = db.Column(db.Float, default=0)  # (unit_cost * quantity) + delivery_cost
    supplier = db.Column(db.String(100))  # Where part was purchased
    warranty_period = db.Column(db.String(50))  # Warranty info

# ----- Login loader -----
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# ----- Database Initialization -----
def init_db():
    """Create tables and default admin."""
    try:
        db.create_all()
        # Check if admin user exists
        if not User.query.filter_by(username='admin').first():
            admin = User(
                username='admin',
                password_hash=generate_password_hash('1234'),
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            print("✅ Default admin created (username: admin, password: 1234)")
        else:
            print("✅ Database initialized - admin user already exists")
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        # If there's an error, try to recreate the database
        db.drop_all()
        db.create_all()
        admin = User(
            username='admin',
            password_hash=generate_password_hash('1234'),
            role='admin'
        )
        db.session.add(admin)
        db.session.commit()
        print("✅ Database recreated with default admin")

# ----- Theme helper -----
def current_theme():
    return session.get('theme', 'light')

@app.context_processor
def inject_theme():
    return {'theme': current_theme()}

# ----- Database initialization moved to main block -----

# ----- Routes -----
@app.route('/toggle-theme')
def toggle_theme():
    t = session.get('theme', 'light')
    session['theme'] = 'dark' if t == 'light' else 'light'
    return redirect(request.referrer or url_for('dashboard'))

@app.route('/')
def home():
    if not current_user.is_authenticated:
        return redirect(url_for('login'))
    return redirect(url_for('dashboard'))

@app.route('/dashboard')
@login_required
def dashboard():
    customers = Customer.query.count()
    vehicles = Vehicle.query.count()
    service_visits = ServiceVisit.query.count()
    parts_used = PartUsed.query.count()
    return render_template('dashboard.html', 
                         customers=customers,
                         vehicles=vehicles, 
                         service_visits=service_visits,
                         parts_used=parts_used)

@app.route('/login', methods=['GET','POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('dashboard'))
        flash('Invalid credentials', 'danger')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

# ----- Customers -----
@app.route('/customers')
@login_required
def customers():
    rows = Customer.query.order_by(Customer.name).all()
    return render_template('customers.html', customers=rows)

@app.route('/customers/new', methods=['GET','POST'])
@login_required
def customers_new():
    if request.method == 'POST':
        name = request.form.get('name')
        phone = request.form.get('phone')
        email = request.form.get('email')
        c = Customer(name=name, phone=phone, email=email)
        db.session.add(c)
        db.session.commit()
        flash('Customer created', 'success')
        return redirect(url_for('customers'))
    return render_template('customers_new.html')

# ----- Settings -----
@app.route('/settings')
@login_required
def settings():
    return render_template('settings.html')

# ----- Vehicles -----
@app.route('/vehicles')
@login_required
def vehicles():
    vehicles = Vehicle.query.join(Customer).all()
    return render_template('vehicles.html', vehicles=vehicles)

@app.route('/vehicles/new', methods=['GET', 'POST'])
@login_required
def vehicles_new():
    if request.method == 'POST':
        customer_id = request.form.get('customer_id')
        plate_number = request.form.get('plate_number')
        vin = request.form.get('vin')
        make = request.form.get('make')
        model = request.form.get('model')
        year = request.form.get('year')
        color = request.form.get('color')
        mileage = request.form.get('mileage')
        
        # Check if VIN already exists
        existing_vehicle = Vehicle.query.filter_by(vin=vin).first()
        if existing_vehicle:
            flash(f'A vehicle with VIN "{vin}" already exists in the system. Please check the VIN number.', 'error')
            customers = Customer.query.all()
            return render_template('vehicles_new.html', customers=customers)
        
        # Check if plate number already exists
        existing_plate = Vehicle.query.filter_by(plate_number=plate_number).first()
        if existing_plate:
            flash(f'A vehicle with plate number "{plate_number}" already exists in the system.', 'error')
            customers = Customer.query.all()
            return render_template('vehicles_new.html', customers=customers)
        
        try:
            vehicle = Vehicle(
                customer_id=customer_id,
                plate_number=plate_number,
                vin=vin,
                make=make,
                model=model,
                year=int(year) if year else None,
                color=color,
                mileage=int(mileage) if mileage else None
            )
            db.session.add(vehicle)
            db.session.commit()
            flash('Vehicle added successfully', 'success')
            return redirect(url_for('vehicles'))
        except Exception as e:
            db.session.rollback()
            flash('An error occurred while adding the vehicle. Please try again.', 'error')
            customers = Customer.query.all()
            return render_template('vehicles_new.html', customers=customers)
    
    customers = Customer.query.all()
    return render_template('vehicles_new.html', customers=customers)

@app.route('/vehicles/<int:vehicle_id>')
@login_required
def vehicle_detail(vehicle_id):
    vehicle = Vehicle.query.get_or_404(vehicle_id)
    service_visits = ServiceVisit.query.filter_by(vehicle_id=vehicle_id).order_by(ServiceVisit.visit_date.desc()).all()
    return render_template('vehicle_detail.html', vehicle=vehicle, service_visits=service_visits)

# ----- Service Visits -----
@app.route('/vehicles/<int:vehicle_id>/service/new', methods=['GET', 'POST'])
@login_required
def service_visit_new(vehicle_id):
    vehicle = Vehicle.query.get_or_404(vehicle_id)
    
    if request.method == 'POST':
        # Handle empty string values safely
        labor_hours_str = request.form.get('labor_hours', '0').strip()
        labor_rate_str = request.form.get('labor_rate', '0').strip()
        service_price_str = request.form.get('service_price', '0').strip()
        
        labor_hours = float(labor_hours_str) if labor_hours_str else 0.0
        labor_rate = float(labor_rate_str) if labor_rate_str else 0.0
        service_price = float(service_price_str) if service_price_str else 0.0
        
        service_visit = ServiceVisit(
            vehicle_id=vehicle_id,
            service_type=request.form.get('service_type'),
            description=request.form.get('description'),
            customer_complaint=request.form.get('customer_complaint'),
            work_performed=request.form.get('work_performed'),
            labor_hours=labor_hours,
            labor_rate=labor_rate,
            service_price=service_price,
            technician=request.form.get('technician'),
            notes=request.form.get('notes')
        )
        
        # Set labor cost to service price (fixed pricing)
        service_visit.labor_cost = service_visit.service_price
        
        db.session.add(service_visit)
        db.session.flush()  # Get the ID without committing
        
        # Handle parts data - multiple parts can be added
        parts_total = 0.0
        part_names = request.form.getlist('part_name[]')
        part_names_custom = request.form.getlist('part_name_custom[]')
        part_numbers = request.form.getlist('part_number[]')
        part_quantities = request.form.getlist('part_quantity[]')
        part_unit_costs = request.form.getlist('part_unit_cost[]')
        part_delivery_costs = request.form.getlist('part_delivery_cost[]')
        
        for i in range(len(part_names)):
            # Determine the actual part name (custom overrides dropdown)
            actual_part_name = ''
            if i < len(part_names_custom) and part_names_custom[i].strip():
                actual_part_name = part_names_custom[i].strip()
            elif part_names[i] and part_names[i] != 'Custom Part':
                actual_part_name = part_names[i]
            
            if actual_part_name:  # Only add if part name is provided
                quantity = int(part_quantities[i]) if i < len(part_quantities) and part_quantities[i] else 1
                unit_cost = float(part_unit_costs[i]) if i < len(part_unit_costs) and part_unit_costs[i] else 0.0
                delivery_cost = float(part_delivery_costs[i]) if i < len(part_delivery_costs) and part_delivery_costs[i] else 0.0
                
                total_cost = (unit_cost * quantity) + delivery_cost
                parts_total += total_cost
                
                part = PartUsed(
                    service_visit_id=service_visit.id,
                    part_name=actual_part_name,
                    part_number=part_numbers[i] if i < len(part_numbers) else '',
                    quantity=quantity,
                    unit_cost=unit_cost,
                    delivery_cost=delivery_cost,
                    total_part_cost=total_cost,
                    warranty_period=''  # Removed warranty field as requested
                )
                db.session.add(part)
        
        # Update total cost including parts
        service_visit.total_cost = service_visit.labor_cost + parts_total
        
        db.session.add(service_visit)
        db.session.commit()
        
        flash('Service visit created successfully', 'success')
        return redirect(url_for('service_visit_detail', visit_id=service_visit.id))
    
    return render_template('service_visit_new.html', vehicle=vehicle)

@app.route('/service-visits/<int:visit_id>')
@login_required
def service_visit_detail(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    parts = PartUsed.query.filter_by(service_visit_id=visit_id).all()
    return render_template('service_visit_detail.html', visit=visit, parts=parts)

@app.route('/service-visits/<int:visit_id>/parts/new', methods=['GET', 'POST'])
@login_required
def add_part(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    
    if request.method == 'POST':
        quantity = int(request.form.get('quantity', 1))
        unit_cost = float(request.form.get('unit_cost', 0))
        delivery_cost = float(request.form.get('delivery_cost', 0))
        
        part = PartUsed(
            service_visit_id=visit_id,
            part_number=request.form.get('part_number'),
            part_name=request.form.get('part_name'),
            part_description=request.form.get('part_description'),
            quantity=quantity,
            unit_cost=unit_cost,
            delivery_cost=delivery_cost,
            supplier=request.form.get('supplier'),
            warranty_period=request.form.get('warranty_period')
        )
        
        # Calculate total part cost
        part.total_part_cost = (unit_cost * quantity) + delivery_cost
        
        db.session.add(part)
        
        # Update service visit total cost
        visit.total_cost = visit.labor_cost + sum(p.total_part_cost for p in visit.parts_used) + part.total_part_cost
        
        db.session.commit()
        
        flash('Part added successfully', 'success')
        return redirect(url_for('service_visit_detail', visit_id=visit_id))
    
    return render_template('add_part.html', visit=visit)

# ----- Reports -----
@app.route('/service-visits/<int:visit_id>/print')
@login_required
def print_service_visit(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    parts = PartUsed.query.filter_by(service_visit_id=visit_id).all()
    return render_template('print_service_visit.html', visit=visit, parts=parts)

@app.route('/service-visits/<int:visit_id>/download-pdf')
@login_required
def download_pdf_invoice(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    parts = PartUsed.query.filter_by(service_visit_id=visit_id).all()
    
    # Render the template with special PDF styling
    html_content = render_template('pdf_invoice.html', visit=visit, parts=parts)
    
    # Create response as downloadable HTML that opens print dialog
    response = make_response(html_content)
    response.headers['Content-Type'] = 'text/html'
    response.headers['Content-Disposition'] = f'attachment; filename=invoice_{visit.id}_{visit.vehicle.plate_number}.html'
    
    return response

@app.route('/service-visits/<int:visit_id>/whatsapp')
@login_required  
def share_whatsapp(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    parts = PartUsed.query.filter_by(service_visit_id=visit_id).all()
    
    # Create WhatsApp message
    message = f"""*Powertune Auto Garage - Service Invoice*

*Vehicle:* {visit.vehicle.make} {visit.vehicle.model} ({visit.vehicle.plate_number})
*Customer:* {visit.vehicle.customer.name}
*Service:* {visit.service_type}
*Date:* {visit.visit_date.strftime('%B %d, %Y')}

*INVOICE DETAILS:*
"""
    
    # Add service cost
    message += f"• {visit.service_type} Service: KSH {visit.service_price or visit.labor_cost:,.2f}\n"
    
    # Add parts
    parts_total = 0
    for part in parts:
        message += f"• {part.part_name} (Qty: {part.quantity}): KSH {part.total_part_cost:,.2f}\n"
        parts_total += part.total_part_cost
    
    message += f"\n*TOTAL AMOUNT: KSH {visit.total_cost:,.2f}*\n\n"
    message += "*Payment Options:*\n"
    message += "💳 M-PESA PayBill: 222111\n"
    message += "🏦 Account: 121219\n\n"
    message += "Thank you for choosing Powertune Auto Garage!\n"
    message += "📱 For questions, call us or WhatsApp this number."
    
    # URL encode the message
    encoded_message = urllib.parse.quote(message)
    whatsapp_url = f"https://wa.me/254727648671?text={encoded_message}"
    
    return redirect(whatsapp_url)

@app.route('/customers/<int:customer_id>/complete-report')
@login_required
def customer_complete_report(customer_id):
    customer = Customer.query.get_or_404(customer_id)
    vehicles = Vehicle.query.filter_by(customer_id=customer_id).all()
    
    # Get all service visits for all customer vehicles
    all_visits = []
    for vehicle in vehicles:
        visits = ServiceVisit.query.filter_by(vehicle_id=vehicle.id).order_by(ServiceVisit.visit_date.desc()).all()
        all_visits.extend(visits)
    
    # Sort all visits by date
    all_visits.sort(key=lambda x: x.visit_date, reverse=True)
    
    return render_template('customer_complete_report.html', customer=customer, vehicles=vehicles, all_visits=all_visits)

# ----- Customer Edit/Delete Routes -----
@app.route('/customers/<int:customer_id>/edit', methods=['GET', 'POST'])
@login_required
def customers_edit(customer_id):
    customer = Customer.query.get_or_404(customer_id)
    
    if request.method == 'POST':
        customer.name = request.form['name']
        customer.phone = request.form['phone']
        customer.email = request.form.get('email')
        customer.address = request.form.get('address')
        
        db.session.commit()
        flash('Customer updated successfully!', 'success')
        return redirect(url_for('customers'))
    
    return render_template('customers_new.html', customer=customer, edit_mode=True)

@app.route('/customers/<int:customer_id>/delete', methods=['POST'])
@login_required
def customers_delete(customer_id):
    customer = Customer.query.get_or_404(customer_id)
    
    # Delete all associated vehicles and their service visits first
    vehicles = Vehicle.query.filter_by(customer_id=customer_id).all()
    for vehicle in vehicles:
        # Delete all service visits for this vehicle
        service_visits = ServiceVisit.query.filter_by(vehicle_id=vehicle.id).all()
        for visit in service_visits:
            # Delete parts used in this visit
            parts = PartUsed.query.filter_by(service_visit_id=visit.id).all()
            for part in parts:
                db.session.delete(part)
            db.session.delete(visit)
        db.session.delete(vehicle)
    
    # Now delete the customer
    db.session.delete(customer)
    db.session.commit()
    flash('Customer and all associated records deleted successfully!', 'success')
    return redirect(url_for('customers'))

@app.route('/customers/<int:customer_id>')
@login_required
def customer_detail(customer_id):
    customer = Customer.query.get_or_404(customer_id)
    vehicles = Vehicle.query.filter_by(customer_id=customer_id).all()
    return render_template('customer_detail.html', customer=customer, vehicles=vehicles)

# ----- Vehicle Edit/Delete Routes -----
@app.route('/vehicles/<int:vehicle_id>/edit', methods=['GET', 'POST'])
@login_required
def vehicles_edit(vehicle_id):
    vehicle = Vehicle.query.get_or_404(vehicle_id)
    customers = Customer.query.all()
    
    if request.method == 'POST':
        vehicle.plate_number = request.form['plate_number']
        vehicle.make = request.form['make']
        vehicle.model = request.form['model']
        vehicle.year = int(request.form['year'])
        vehicle.vin = request.form.get('vin')
        vehicle.color = request.form.get('color')
        vehicle.customer_id = int(request.form['customer_id'])
        
        db.session.commit()
        flash('Vehicle updated successfully!', 'success')
        return redirect(url_for('vehicles'))
    
    return render_template('vehicles_new.html', vehicle=vehicle, customers=customers, edit_mode=True)

@app.route('/vehicles/<int:vehicle_id>/delete', methods=['POST'])
@login_required
def vehicles_delete(vehicle_id):
    vehicle = Vehicle.query.get_or_404(vehicle_id)
    
    # Delete all associated service visits and their parts first
    service_visits = ServiceVisit.query.filter_by(vehicle_id=vehicle_id).all()
    for visit in service_visits:
        # Delete parts used in this visit
        parts = PartUsed.query.filter_by(service_visit_id=visit.id).all()
        for part in parts:
            db.session.delete(part)
        db.session.delete(visit)
    
    # Now delete the vehicle
    db.session.delete(vehicle)
    db.session.commit()
    flash('Vehicle and all associated service records deleted successfully!', 'success')
    return redirect(url_for('vehicles'))

# ----- Service Visit Delete Route -----
@app.route('/service-visit/<int:visit_id>/delete', methods=['POST'])
@login_required
def service_visit_delete(visit_id):
    visit = ServiceVisit.query.get_or_404(visit_id)
    vehicle_id = visit.vehicle_id
    
    # Delete all associated parts first
    parts = PartUsed.query.filter_by(service_visit_id=visit_id).all()
    for part in parts:
        db.session.delete(part)
    
    # Now delete the service visit
    db.session.delete(visit)
    db.session.commit()
    flash('Service visit and all associated parts deleted successfully!', 'success')
    return redirect(url_for('vehicle_detail', vehicle_id=vehicle_id))

# ----- Part Delete Route -----
@app.route('/part/<int:part_id>/delete', methods=['POST'])
@login_required
def part_delete(part_id):
    part = PartUsed.query.get_or_404(part_id)
    visit_id = part.service_visit_id
    
    db.session.delete(part)
    db.session.commit()
    flash('Part deleted successfully!', 'success')
    return redirect(url_for('service_visit_detail', visit_id=visit_id))

# ----- Run app -----
if __name__ == '__main__':
    with app.app_context():
        init_db()
    # Production configuration
    app.run(host='0.0.0.0', port=5000, debug=False)
