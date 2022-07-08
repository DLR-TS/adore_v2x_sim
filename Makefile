SHELL:=/bin/bash

.DEFAULT_GOAL := all

PROJECT="adore_v2x_sim"
VERSION="latest"
IMAGE_NAME="${PROJECT}:${VERSION}"
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: help 
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: build 
build: clean
	rm -rf ${ROOT_DIR}/${PROJECT}/build
	cd v2x_if_ros_msg && make 
	cd "${ROOT_DIR}" && \
        touch CATKIN_IGNORE && \
        docker build --network="host" -t ${IMAGE_NAME} . 
	cd "${ROOT_DIR}" && \
        docker cp $$(docker create --rm ${IMAGE_NAME}):/tmp/${PROJECT}/build ${PROJECT}/build

.PHONY: clean 
clean: 
	rm -rf ${ROOT_DIR}/${PROJECT}/build
	docker rm $$(docker ps -a -q --filter "ancestor=${IMAGE_NAME}") 2> /dev/null || true
	docker rmi $$(docker images -q ${IMAGE_NAME}) 2> /dev/null || true
 
