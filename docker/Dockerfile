FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# COPY syntax was wrong — missing space and wrong path structure
COPY AccumulatorLoad-1.0.0.jar /app/AccumulatorLoad-1.0.0.jar

# Missing space after mkdir -p
RUN mkdir -p /app/tmp

# JAVA_OPTS missing spaces between flags
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/AccumulatorLoad-1.0.0.jar"]
