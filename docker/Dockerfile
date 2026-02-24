FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY CpeLoad-0.1.jar /app/CpeLoad-0.1.jar

RUN mkdir -p /app/tmp

ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/CpeLoad-0.1.jar"]
