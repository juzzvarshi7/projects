import requests

# Base URL for the Flask application
base_url = 'http://127.0.0.1:5000'

# Example user credentials for login
username = 'user1'
password = 'password'

# Example customer data for creating a new customer
customer_data = {
    'name': 'New Customer',
    'email': 'newcustomer@example.com',
    'phone': '1234567890',
    'notes': 'This is a note about the new customer.'
}

# Example interaction data for logging interactions
interaction_data = {
    'customer_id': 1,
    'interaction_type': 'Call',
    'interaction_notes': 'Called customer to follow up on the sales inquiry.'
}

# Example request to login endpoint
login_response = requests.post(f'{base_url}/login', json={'username': username, 'password': password})
print('Login Response:', login_response.json())

# Example request to create a new customer
create_customer_response = requests.post(f'{base_url}/customers', json=customer_data)
print('Create Customer Response:', create_customer_response.json())

# Example request to retrieve a list of all customers
get_customers_response = requests.get(f'{base_url}/customers')
print('Get Customers Response:', get_customers_response.json())

# Example request to log an interaction with a customer
log_interaction_response = requests.post(f'{base_url}/interactions', json=interaction_data)
print('Log Interaction Response:', log_interaction_response.json())
