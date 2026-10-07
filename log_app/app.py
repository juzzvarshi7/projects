from flask import Flask, render_template, request, jsonify, redirect, url_for, session
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import json

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Set a secret key for session management
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///reflections.db'
db = SQLAlchemy(app)

# Database models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

class Reflection(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    date = db.Column(db.Date, default=datetime.utcnow)
    emotional_state = db.Column(db.String(10), nullable=False)  # e.g., 'Happy', 'Sad'
    activities = db.Column(db.String(200), nullable=False)
    social_interactions = db.Column(db.String(200), nullable=False)
    personal_reflections = db.Column(db.String(200), nullable=False)

# Initialize database
with app.app_context():
    db.create_all()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = User.query.filter_by(username=data['username'], password=data['password']).first()
    if user:
        session['user_id'] = user.id  # Store user_id in session
        return jsonify({"status": "success", "user_id": user.id})
    return jsonify({"status": "error", "message": "Invalid credentials"})

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    new_user = User(username=data['username'], password=data['password'])
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"status": "success"})

@app.route("/save_response", methods=["POST"])
def save_response():
    data = request.get_json()
    reflection = Reflection(
        user_id=session['user_id'],
        emotional_state=data['emotional_state'],
        activities=data['activities'],
        social_interactions=data['social_interactions'],
        personal_reflections=data['personal_reflections']
    )
    db.session.add(reflection)
    db.session.commit()
    return jsonify({"status": "success"})

@app.route("/dashboard")
def dashboard():
    reflections = Reflection.query.filter_by(user_id=session['user_id']).all()
    return render_template("dashboard.html", reflections=reflections)

if __name__ == "__main__":
    app.run(debug=True)
