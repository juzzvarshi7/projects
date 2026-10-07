import requests

# Base URL for your Flask application
base_url = 'http://127.0.0.1:5000'

# Example user credentials
username = 'user1'
password = 'password'

# Example customer data
customer_data = {
    'name': 'New Customer',
    'email': 'newcustomer@example.com',
    'phone': '1234567890',
    'notes': 'This is a note about the new customer.'
}

# Example request to login endpoint
login_response = requests.post(f'{base_url}/login', auth=(username, password))
print('Login Response:', login_response.json())

# Example request to create a new customer
create_customer_response = requests.post(f'{base_url}/customers', json=customer_data)
print('Create Customer Response:', create_customer_response.json())

# Example request to retrieve details of a specific customer (replace <customer_id> with an actual ID)
customer_id = 1
get_customer_response = requests.get(f'{base_url}/customers/{customer_id}')
print('Get Customer Response:', get_customer_response.json())