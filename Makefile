.PHONY: build install test
SHELL=/bin/bash

install: vendor/bundle-darwin
	@echo "-> Done installing"

vendor/bundle-darwin: vendor/oracle/Darwin/instantclient_12_2
	@echo "-> Bundle install" && \
		OCI_DIR="$(shell pwd)/vendor/oracle/Darwin/instantclient_12_2" \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle install 1>/dev/null

vendor/bundle: create_bundler_image vendor/lib
	@echo "-> Installing dependencies" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/lib \
		--env BUNDLE_PATH=/app/vendor/bundle \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle install 1>/dev/null

vendor/lib: vendor/oracle/Linux/instantclient_12_2
	@echo "-> Setting up lib files" && \
		$(SHELL) ./scripts/prep-libraries.sh

vendor/oracle/Linux/instantclient_12_2:
	@echo "-> Install headers for ruby-oic8 (Linux)" && \
		$(SHELL) ./scripts/install-ruby-oic8.sh Linux

vendor/oracle/Darwin/instantclient_12_2:
	@echo "-> Install headers for ruby-oic8 (Darwin)" && \
		$(SHELL) ./scripts/install-ruby-oic8.sh Darwin

create_bundler_image:
	@echo "-> Creating bundler docker image" &&\
		docker build \
		-t bundler:2.1.4 \
		-f bundler.Dockerfile \
		- < bundler.Dockerfile 1>/dev/null

build: vendor/lib vendor/bundle
	@echo "-> Building lambda package" && \
		$(SHELL) ./scripts/build-lambda.sh

test:
	@echo "-> Testing $(shell uname)"
	@make test_$(shell uname | tr '[:upper:]' '[:lower:]')

test_integration:
	@echo "-> Testing $(shell uname)"
	@make test_integration_$(shell uname | tr '[:upper:]' '[:lower:]')

test_e2e:
	@echo "-> Testing $(shell uname)"
	@make test_e2e_$(shell uname | tr '[:upper:]' '[:lower:]')

test_all:
	@echo "-> Testing $(shell uname)"
	@make test_all_$(shell uname | tr '[:upper:]' '[:lower:]')

test_darwin: vendor/bundle-darwin
	@echo "-> Running unit tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec --exclude-pattern "**/integration/*_spec.rb, **/e2e/*_spec.rb"

test_integration_darwin: vendor/bundle-darwin
	@echo "-> Running integration tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec spec/integration

test_e2e_darwin: vendor/bundle-darwin
	@echo "-> Running e2e tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec spec/e2e

test_all_darwin:
	@$(MAKE) test_darwin
	@$(MAKE) test_integration_darwin
	@$(MAKE) test_e2e_darwin

test_linux: vendor/bundle
	@echo "-> Running unit tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec --exclude-pattern "**/integration/*_spec.rb, **/e2e/*_spec.rb"

test_integration_linux: vendor/bundle
	@echo "-> Running integration tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec spec/integration

test_e2e_linux: vendor/bundle
	@echo "-> Running e2e tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec spec/e2e

test_all_linux:
	@$(MAKE) test_linux
	@$(MAKE) test_integration_linux
	@$(MAKE) test_e2e_linux

test_all_lambda: vendor/bundle
	@docker run \
 		-e DOCKER_LAMBDA_WATCH=1 \
 		-e DOCKER_LAMBDA_STAY_OPEN=1 \
 		-p 9001:9001 \
 		--rm -v "$(shell pwd)":/var/task:ro,delegated \
 		-v "$(shell pwd)"/vendor/lib:/opt/lib:ro,delegated \
 		lambci/lambda:ruby2.7 \
 		/var/task/lib/bootstrap.handler

clean:
	@echo "-> Cleaning up dependencies" && \
		rm -rf vendor/lib && rm -rf vendor/bundle && rm -rf vendor/bundle-darwin
