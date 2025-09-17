# Build stage
FROM golang:1.21 AS builder

# Force Go to use static linking
ENV CGO_ENABLED=0
ENV GO111MODULE=off

WORKDIR /go/src/app
COPY . .

# Build statically linked binary for Linux
RUN go build -o server .

# Final image
FROM alpine:latest

# Set environment variable for background color
ENV COLOR_SOURCE=env
ENV BACKGROUND_COLOR=blue

WORKDIR /app

# Copy the statically linked binary
COPY --from=builder /go/src/app/server .

EXPOSE 8080

# Run the binary
CMD ["./server"]
