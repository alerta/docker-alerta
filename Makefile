#!make

-include .env .env.local .env.*.local

VCS_REF=$(shell git rev-parse --short HEAD)
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION:=$(shell cat VERSION)

ifndef IMAGE_NAME
$(error IMAGE_NAME is not set)
endif

.PHONY: version

all:	help

help:
	@echo ""
	@echo "Usage: make <command>"
	@echo "Commands:"
	@echo "   lint     Lint Dockerfile"
	@echo "   test     Test container"
	@echo "   build    Build container"
	@echo "   pull     Pull latest containers"
	@echo "   up       Create and start containers"
	@echo "   down     Stop and remove containers"
	@echo "   clean    Remove stopped containers"
	@echo "   version  Show versions"
	@echo "   shell    Container shell prompt"
	@echo ""

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile

test: env
	@echo "IMAGE_NAME=${IMAGE_NAME}" >.env
	@echo "VCS_REF=${VCS_REF}" >>.env
	@echo "VERSION=${VERSION}" >>.env
	docker-compose -f docker-compose.test.yml up \
	--build \
	--renew-anon-volumes \
	--no-color \
	--exit-code-from tester
	@echo "IMAGE_NAME=${IMAGE_NAME}" >.env

build:
	docker build \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VERSION=$(VERSION) \
	-t $(IMAGE_NAME) \
	-t $(IMAGE_NAME):$(VERSION) \
	-t $(IMAGE_NAME):$(VCS_REF) \
	-t $(IMAGE_NAME):latest .

push:
	docker push $(IMAGE_NAME)

pull:
	docker-compose -f docker-compose.yml pull

up:
	docker-compose -f docker-compose.yml up

down:
	docker-compose -f docker-compose.yml down

clean:
	docker-compose -f docker-compose.yml rm

version:
	@docker-compose version
	@echo "alerta version $(VERSION)"

shell:
	docker-compose -f docker-compose.test.yml run --rm sut bash

env:
	env
