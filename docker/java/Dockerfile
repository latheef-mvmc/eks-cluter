# Use an official OpenJDK runtime as the base image
FROM openjdk:11-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Java application JAR file to the working directory
COPY target/my-app.jar my-app.jar

# If you have a requirements.txt file for Python dependencies (e.g., for scripting tasks)
# You can copy it and install Python dependencies (if any are needed).
COPY requirements.txt .

# Install Python dependencies (if required)
RUN pip install --no-cache-dir -r requirements.txt

# Expose the application port (modify this if your app uses a different port)
EXPOSE 8080

# Define the command to run the application
CMD ["java", "-jar", "my-app.jar"]
