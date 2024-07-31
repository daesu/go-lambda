AWS_REGION ?= eu-west-1

setup:
	@if [ ! -d ".terraform" ]; then \
		echo "initializing terraform ..."; \
		docker-compose run --rm terraform_go terraform init; \
	fi
	
build: setup
	@mkdir -p bin
	docker-compose run --rm service sh -c "cd /opt/app && env GOOS=linux go build -tags aws_lambda -ldflags='-s -w' -o /opt/app/bin/service main.go"
	cp bootstrap bin/
	cd bin; zip -r service.zip service bootstrap

clean:
	rm -rf bin/*
	rm -rf .terraform/
	rm -f .terraform*
	rm -f terraform.*
	
tests:
	docker-compose run --rm test

run:
	docker-compose up service

deploy: build
	docker-compose run --rm terraform_go terraform apply -var="region=$(AWS_REGION)" -auto-approve

destroy:
	docker-compose run --rm terraform_go terraform destroy -var="region=$(AWS_REGION)" -auto-approve
