from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField,DateField,IntegerField
from wtforms.validators import DataRequired

class SearchForm(FlaskForm):
    Descriptor = StringField('Descriptor', validators=[DataRequired()])
#incident = StringField('Incident Type')
#search = SubmitField('Submit')
#keywords = StringField('Keywords')
#confirm = BooleanField('Action Confirmed')
    submit = SubmitField('Search')

class SparkForm(FlaskForm):
    Query = StringField('Tell us a theme to search for similar compliant types (e.g. parking, taxi)', validators=[DataRequired()])
    submit = SubmitField('Search')