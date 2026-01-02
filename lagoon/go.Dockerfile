FROM uselagoon/commons AS builder

RUN apk add go
WORKDIR /app
COPY . /app
RUN go build -o plenary /app/cmd/web/

ENTRYPOINT ["/app/plenary"]
