
VCS_REF=$(shell git rev-parse --short HEAD)
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION:=$(shell cat VERSION)

.PHONY: version

build:
	docker-compose -f docker-compose.yml -f docker-compose.mongo.yml build \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VERSION=$(VERSION)

up:
	docker-compose -f docker-compose.yml -f docker-compose.mongo.yml up

down:
	docker-compose -f docker-compose.yml -f docker-compose.mongo.yml down

clean:
	docker-compose -f docker-compose.yml -f docker-compose.mongo.yml rm

version:
	@docker-compose version
	@echo "alerta version $(VERSION)"
