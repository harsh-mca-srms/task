# ---------- Build Stage ----------
FROM maven:3.6.3-openjdk-17 as builder
WORKDIR /workspace

COPY pom.xml .
COPY src/ src/

RUN mvn clean package -DskipTests

# ---------- Runtime Stage ----------
FROM openjdk:17-slim
WORKDIR /app

# Copy the JAR built from the previous stage
COPY --from=builder /workspace/target/salary-0.1.0-RELEASE.jar app.jar

# Download OpenTelemetry agent inside the image
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

# Start with the OpenTelemetry Java agent
ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "app.jar"]
