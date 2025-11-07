FROM maven:3.9.5-amazoncorretto-17 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and download dependencies first (for better layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY src /app/src

# Package the application into a JAR file (assuming a Spring Boot or similar structure)
RUN mvn clean package -DskipTests

# --- Stage 2: Create the Final Runtime Image ---
# Use a minimal JRE image for the final production environment
# FIX: Use the correct, available Amazon Corretto Alpine JRE tag
FROM amazoncorretto:17-alpine-jre 

# Set the entry point variable
ARG JAR_FILE=target/*.jar

# Copy the packaged JAR file from the 'builder' stage
COPY --from=builder /app/${JAR_FILE} app.jar

# Define the port the container will expose (change if your app uses a different port)
EXPOSE 8080

# Run the application when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]
