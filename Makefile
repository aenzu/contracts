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
		MODULE_OPT="--go_opt=module=github.com/aenzu/contracts"; \
		GRPC_MODULE_OPT="--go-grpc_opt=module=github.com/aenzu/contracts"; \
		\
		echo ">> Processing pagination"; \
		protoc $$PROTO_INCLUDES \
			--go_out=/app \
			$$MODULE_OPT \
			pagination/pagination.proto; \
		\
		echo ">> Processing account"; \
		protoc $$PROTO_INCLUDES \
			--go_out=/app \
			$$MODULE_OPT \
			--go-grpc_out=/app \
			$$GRPC_MODULE_OPT \
			account/account_model.proto \
			account/account_service.proto; \
	'

clean:
	find account pagination -type d -name go -exec rm -rf {} +