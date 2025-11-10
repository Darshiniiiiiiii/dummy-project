FROM maven:3.9.5-amazoncorretto-17 AS build_env
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline


COPY src /app/src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-focal 


ARG JAR_FILE=target/*.jar

COPY --from=build_env /app/${JAR_FILE} app.jar

# Define the port the container will expose (change if your app uses a different port)
EXPOSE 8080

# Run the application when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]
