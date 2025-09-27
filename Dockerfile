# Build stage
FROM bellsoft/liberica-runtime-container:jdk-21-stream-musl AS build

WORKDIR /app

# Copy Maven wrapper and settings
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Ensure mvnw is executable
RUN chmod +x mvnw

# Pre-download dependencies for better caching
RUN ./mvnw dependency:go-offline -B --no-transfer-progress -DskipTests=true

# Copy source code
COPY src src

# Build application
RUN ./mvnw clean package -DskipTests --no-transfer-progress

# Runtime stage
FROM bellsoft/liberica-runtime-container:jre-21-stream-musl

WORKDIR /app

# Copy JAR from build stage (assuming only one final JAR is produced)
COPY --from=build /app/target/*-SNAPSHOT.jar app.jar

EXPOSE 8090

ENTRYPOINT ["java", "-jar", "app.jar"]
