FROM golang:1.27-alpine

WORKDIR /app

ENV GO111MODULE=on
ENV GOOS=linux
ENV CGO_ENABLED=0

RUN apk add --no-cache build-base ca-certificates git

COPY . .

RUN go install github.com/cosmtrek/air@v1.28.0
RUN go install github.com/swaggo/swag/cmd/swag@v1.16.2

EXPOSE 9000

CMD ["air", "-c", ".air.toml"]
