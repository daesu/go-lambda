# go-lambda

Skeleton to setup a go lambda function with api-gateway on AWS using terraform. Projects uses the [3musketeers](https://3musketeers.pages.dev/guide/) pattern.

## Running

Can be run through `go` directly or through `make` & `docker-compose`.

## Local

Create a `.env` file by copying the contents of `.env.default` and optionally adding values.

```
make build
```

Running locally will start a server at `http://localhost:8081` with a single `GET` endpoint `ping`

```
make run
```

Or alternatively if you want to use `go` directly, `go run main.go`

### Running Tests

```
make tests
```

### Deploying to AWS lambda

Deploying to AWS lambda requires adding valid AWS credentials to `.env`

```
make deploy
```

This will provision AWS Lambda and an API Gateway for the service.

To tear down the resources

```
make destroy
```

