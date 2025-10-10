FROM maven:3.6.3-openjdk-17 as builder

WORKDIR /workspace
COPY pom.xml .
COPY src/ src/
RUN mvn clean package -DskipTests

FROM openjdk:17-slim

WORKDIR /app
COPY --from=builder /workspace/target/salary-0.1.0-RELEASE.jar app.jar

# Create health check script
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
