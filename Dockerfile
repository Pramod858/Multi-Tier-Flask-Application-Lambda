# Use the official Python 3.11 image
FROM python:3.11

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy requirements.txt to the working directory
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the templates folder and main app file
COPY ./templates ./templates
COPY app.py .

# Expose the port the app runs on
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
