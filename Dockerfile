# Étape 1 - Build du JAR
FROM maven:3.8.5-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 - Image d'exécution
FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
COPY --from=build /app/target/*.jar /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
