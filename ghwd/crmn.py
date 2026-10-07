from flask import Flask, request, jsonify

app = Flask(__name__)

# Dummy user database (for demonstration purposes)
users = {
    'user1': {
        'username': 'user1',
        'password': 'password',
        'email': 'user1@example.com',
        'role': 'admin'
    },
    'user2': {
        'username': 'user2',
        'password': 'password2',
        'email': 'user2@example.com',
        'role': 'user'
    }
}

# Dummy customer database
customers = []

# Authentication endpoint
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Invalid credentials'}), 401

    if username not in users or users[username]['password'] != password:
        return jsonify({'message': 'Invalid username or password'}), 401

    return jsonify({'message': 'Login successful', 'user': users[username]}), 200

# Endpoint to create a new customer
@app.route('/customers', methods=['POST'])
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

# Endpoint to list all customers
@app.route('/customers', methods=['GET'])
def get_customers():
    return jsonify(customers)

# Endpoint to log interactions with customers
@app.route('/interactions', methods=['POST'])
def log_interaction():
    data = request.json
    # Here you would handle logging interactions with customers
    return jsonify({'message': 'Interaction logged successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True)
