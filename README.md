# kubernetes-devops-security

This repo is retired.

Please use [this repo](https://github.com/kodekloudhub/devsecops) for the DevSecOps course.

Thank you.


##### Dockerfile
- after adding Open Policy Agent (OPA) Conftest" which is collection of rules to statically analyze Dockerfiles to improve security we updated the Docker file to the following

[
FROM adoptopenjdk/openjdk8:alpine-slim                       (our image)
EXPOSE 8080                                                  (exposing the application)
ARG JAR_FILE=target/*.jar         
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline   (creating group and user called k8s-pipeline)
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar              (moving jar file to k8s-pipeline home dir)
USER k8s-pipeline                                     (use k8s-pipline user to run the next command)
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
]