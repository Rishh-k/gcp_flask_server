# Use an official Python runtime as a base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 8080

# Install any dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8080 for Flask
# EXPOSE 8080

# Set the environment variables to run Flask
# ENV FLASK_APP=app.py
# ENV FLASK_RUN_HOST=0.0.0.0

# # Run the Flask app
# CMD ["flask", "run"]
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app