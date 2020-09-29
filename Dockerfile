FROM golang:1.13.4-buster as builder

WORKDIR /go/src/app

COPY . .

RUN echo "Fetch dependencies..." && \
    go get -d -v ./... && \
    echo "Building..." && \
    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/siclo-go-app && \
    echo "Done"

FROM alpine:latest 
WORKDIR  /home/siclo/

RUN apk --update --no-cache add bash

ENV USER_HOME    /home/siclo/
ARG user=siclo
ARG group=siclo
ARG uid=1000
ARG gid=1000

RUN mkdir -p /home/siclo/ && \
    addgroup -g ${gid} ${group} && \
    adduser -h ${USER_HOME} -S ${user} -u ${uid} -G ${group} -s /bin/bash ${user}
    
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/America/Mexico_City /etc/localtime && \
    echo "America/Mexico_City" > /etc/timezone

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go/src/app/build/siclo-go-app .

RUN  chown -R ${user}:${group} /home/siclo/

CMD ["/home/siclo/siclo-go-app"]