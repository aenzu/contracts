PROTO_ROOT=.
DOCKER_IMAGE=proto_builder

.PHONY: docker-build gen clean

docker-build:
	docker build -t $(DOCKER_IMAGE) .

gen: docker-build
	docker run --rm -v $(abspath $(PROTO_ROOT)):/app $(DOCKER_IMAGE) \
	bash -c '\
		set -e; \
		PROTO_INCLUDES="-I /app -I /usr/local/include/googleapis"; \
		\
		echo ">> Processing pagination"; \
		mkdir -p /app/pagination/go; \
		protoc $$PROTO_INCLUDES \
			--go_out=/app/pagination/go \
			--go_opt=paths=source_relative \
			pagination/pagination.proto; \
		\
		echo ">> Processing account"; \
		mkdir -p /app/account/go; \
		protoc $$PROTO_INCLUDES \
			--go_out=/app/account/go \
			--go_opt=paths=source_relative \
			--go-grpc_out=/app/account/go \
			--go-grpc_opt=paths=source_relative \
			account/account_model.proto \
			account/account_service.proto; \
	'

clean:
	find account pagination -type d -name go -exec rm -rf {} +