import os
import pymysql

db_user = 'root'
db_password = 'root'
db_name = 'flask_db'
db_connection_name = 'flask-server-deployment:asia-south2:newdb'

# If connecting from your local machine, use the public IP address of your Cloud SQL instance
# Set db_host to "127.0.0.1" if testing locally with a local MySQL server
db_host = "34.131.128.246"  # Replace with the public IP of your Cloud SQL instance
db_port = 3306  # Default MySQL port

try:
    # Establish the connection
    connection = pymysql.connect(
        host=db_host,
        user=db_user,
        password=db_password,
        database=db_name,
        port=db_port,
        cursorclass=pymysql.cursors.DictCursor
    )
    
    print("Connection to the database was successful!")

    # Example query to test the connection
    with connection.cursor() as cursor:
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()
        print("Tables in the database:", tables)

except pymysql.MySQLError as e:
    print(f"Database connection failed: {e}")
finally:
    if connection:
        connection.close()
        print("Database connection closed.")
