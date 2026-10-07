from app import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

class Reflection(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    date = db.Column(db.Date, default=datetime.utcnow)
    emotional_state = db.Column(db.String(10), nullable=False)
    activities = db.Column(db.String(200), nullable=False)
    social_interactions = db.Column(db.String(200), nullable=False)
    personal_reflections = db.Column(db.String(200), nullable=False)
