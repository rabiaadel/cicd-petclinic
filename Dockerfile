# ===== Build Stage =====
FROM bellsoft/liberica-runtime-container:jdk-21-stream-musl AS build
WORKDIR /app

# Copy Maven wrapper & settings
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./

RUN chmod +x mvnw

# Pre-fetch dependencies for caching
RUN ./mvnw dependency:go-offline -B --no-transfer-progress -DskipTests=true

# Copy source code and build
COPY src src
RUN ./mvnw clean package -DskipTests --no-transfer-progress

# ===== Runtime Stage =====
FROM bellsoft/liberica-runtime-container:jre-21-stream-musl
WORKDIR /app

# Add non-root user
RUN adduser -D spring
USER spring

# Copy final JAR
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
