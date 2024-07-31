FROM golang:1.22.2-alpine AS terraform_go

# Install necessary tools
RUN apk add --no-cache curl unzip

# Download and install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.3.0/terraform_1.3.0_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

WORKDIR /opt/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /opt/app/bin/service main.go

# Set the entrypoint to Terraform
CMD ["terraform"]
