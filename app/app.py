from flask import Flask, render_template, request, redirect, url_for, jsonify
from flask_cors import CORS
import pymysql

app = Flask(__name__)
CORS(app)

entries = []

USERNAME = "admin"
PASSWORD = "Admin@123"

BUCKET_URL = "https://storage.googleapis.com/flask_rishabh_test_1"

db_user = 'root'
db_password = 'root'
db_name = 'flask_db'
db_connection_name = 'flask-server-deployment:asia-south2:newdb'


# Function to get a database connection
def get_db_connection():
    try:
        # Establish connection with Cloud SQL using Unix socket
        connection = pymysql.connect(
            user=db_user,
            password=db_password,
            database=db_name,
            unix_socket=f'/cloudsql/{db_connection_name}',  # For GCP Cloud SQL connection
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.MySQLError as e:
        print(f"Database connection failed: {e}")
        return None
    


# Route for the welcome page
@app.route('/')
def welcome():
    return redirect(f"{BUCKET_URL}/welcome.html", code=302)


# Route for the form page
@app.route('/form', methods=['GET', 'POST'])
def form():
    return redirect(f"{BUCKET_URL}/form.html", code=302)


# Route to handle form submission
@app.route('/submit', methods=['POST'])
def submit_form():
    global entries
    if request.method == 'POST':
        name = request.form.get('name')
        birthday = request.form.get('birthday')
        email = request.form.get('email')
        print(f"Name: {name}, Birthday: {birthday}, Email: {email}")

        connection = get_db_connection()
        if not connection:
            return jsonify({"error": "Database connection failed"}), 500

        with connection.cursor() as cursor:
            
            # cursor.execute("delete from data_rec;")
            # connection.commit()
            
            cursor.execute("INSERT INTO data_rec (name, birthday, email) VALUES (%s, %s, %s)", (name, birthday, email))
            connection.commit()

        connection.close()

        return redirect(f"{BUCKET_URL}/thankyou.html", code=302)


# Route to admin login to view all entries
@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        # Retrieve data from form
        username = request.form.get('username')
        password = request.form.get('password')

        # Check if credentials match
        if username == USERNAME and password == PASSWORD:
            return redirect(f"{BUCKET_URL}/all_entries.html", code=302)
        else:
            error = "Invalid username or password"  # Set error message on failure
        
    return redirect(f"{BUCKET_URL}/login.html", code=302)


# Route to show all the entered records
@app.route('/all_entries')
def all_entries():
    connection = get_db_connection()
    if not connection:
        return jsonify({"error": "Database connection failed"}), 500

    with connection.cursor() as cursor:
        cursor.execute("select * from data_rec;")
        data = cursor.fetchall()
        print(data)
    return redirect(f"{BUCKET_URL}/all_entries.html", code=302)


# Route for the thank you page
@app.route('/thankyou')
def thank_you():
    return redirect(f"{BUCKET_URL}/thankyou.html", code=302)


if __name__ == '__main__':
    app.run()
