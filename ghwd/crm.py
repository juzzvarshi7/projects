from flask import Flask, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Dummy user database
users = {
    'user1': {
        'username': 'user1',
        'password_hash': generate_password_hash('password'),
        'email': 'user1@example.com',
        'full_name': 'User One'
    },
    'user2': {
        'username': 'user2',
        'password_hash': generate_password_hash('password2'),
        'email': 'user2@example.com',
        'full_name': 'User Two'
    }
}

# Dummy CRM data
customers = [
    {
        'id': 1,
        'name': 'Customer One',
        'email': 'customer1@example.com',
        'phone': '1234567890',
        'notes': 'This is a note about Customer One.'
    },
    {
        'id': 2,
        'name': 'Customer Two',
        'email': 'customer2@example.com',
        'phone': '9876543210',
        'notes': 'This is a note about Customer Two.'
    }
]

# Authentication endpoint
@app.route('/login', methods=['POST'])
def login():
    auth = request.authorization
    if not auth or not auth.username or not auth.password:
        return jsonify({'message': 'Invalid credentials'}), 401
    username = auth.username
    password = auth.password
    
    if username not in users or not check_password_hash(users[username]['password_hash'], password):
        return jsonify({'message': 'Invalid username or password'}), 401
    return jsonify({'message': 'Login successful'}), 200

# Endpoint to get customer details
@app.route('/customers/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    for customer in customers:
        if customer['id'] == customer_id:
            return jsonify(customer)
    return jsonify({'message': 'Customer not found'}), 404

# Endpoint to create a new customer
@app.route('/customers', methods=['POST'])
@app.route('/', methods=['GET'])
def homepage():
    return 'Welcome to the CRM Application!', 200

def create_customer():
    data = request.json
    new_customer = {
        'id': len(customers) + 1,
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
        'notes': data.get('notes', '')
    }
    customers.append(new_customer)
    return jsonify(new_customer), 201

if __name__ == '__main__':
    app.run(debug=True)
