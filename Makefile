#!make

DOCKER=docker
DOCKER_COMPOSE=docker-compose

.DEFAULT_GOAL:=help

-include .env .env.local .env.*.local

VCS_REF=$(shell git rev-parse --short HEAD)
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION:=$(shell cat VERSION)

BACKEND ?= postgres

ifndef IMAGE_NAME
$(error IMAGE_NAME is not set)
endif

.PHONY: version

all:	help

## lint			- Lint Dockerfile.
lint:
	docker run --rm -i hadolint/hadolint < Dockerfile

## test.unit		- Run unit tests.
test.unit:
	IMAGE_NAME=${IMAGE_NAME} \
	VCS_REF=${VCS_REF} \
	VERSION=${VERSION} \
	$(DOCKER_COMPOSE) \
	-f tests/docker-compose.test.${BACKEND}.yml \
	up \
	--build \
	--renew-anon-volumes \
	--no-color \
	--exit-code-from tester

## build			- Build docker image.
build:
	$(DOCKER) build \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VERSION=$(VERSION) \
	-t $(IMAGE_NAME) \
	-t $(IMAGE_NAME):$(VERSION) \
	-t $(IMAGE_NAME):$(VCS_REF) \
	-t $(IMAGE_NAME):latest .

## push			- Push docker image to repository.
push:
	$(DOCKER) push $(IMAGE_NAME)

## pull			- Pull docker images.
pull:
	$(DOCKER_COMPOSE) -f docker-compose.yml pull

## up			- Create and start up docker containers.
up:
	$(DOCKER_COMPOSE) -f docker-compose.yml up

## down			- Stop and remove docker containers.
down:
	$(DOCKER_COMPOSE) -f docker-compose.yml down

## clean			- Clean up docker containers.
clean:
	$(DOCKER_COMPOSE) -f docker-compose.yml rm

## version		- Show version.
version:
	@$(DOCKER_COMPOSE) version
	@echo "alerta version $(VERSION)"

## shell			- Container shell prompt.
shell:
	$(DOCKER_COMPOSE) -f docker-compose.test.yml run --rm sut bash

## env			- Print environment variables.
env:
	env | sort

## help			- Show this help.
help: Makefile
	@echo ''
	@echo 'Usage:'
	@echo '  make [TARGET]'
	@echo ''
	@echo 'Targets:'
	@sed -n 's/^##//p' $<
	@echo ''

	@echo 'Add project-specific env variables to .env file:'
	@echo 'PROJECT=$(PROJECT)'

.PHONY: help lint test build sdist wheel clean all
