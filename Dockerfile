# Build the manager binary
FROM golang:1.13.5 as builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY . .


# Build
RUN CGO_ENABLED=0 GOARCH=amd64 GO111MODULE=on go build -a -o ice-kube main.go

# Use distroless as minimal base image to package the ice-kube binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot 
WORKDIR /
COPY --from=builder /workspace/ice-kube .
USER nonroot:nonroot

ENTRYPOINT ["/ice-kube"]
