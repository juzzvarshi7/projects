from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, SelectField, TextAreaField
from wtforms.validators import DataRequired

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Register')

class ReflectionForm(FlaskForm):
    emotional_state = SelectField('Emotional State', choices=[('Happy', 'Happy'), ('Sad', 'Sad'), ('Neutral', 'Neutral')], validators=[DataRequired()])
    activities = TextAreaField('Activities', validators=[DataRequired()])
    social_interactions = TextAreaField('Social Interactions', validators=[DataRequired()])
    personal_reflections = TextAreaField('Personal Reflections', validators=[DataRequired()])
    submit = SubmitField('Save Reflection')
