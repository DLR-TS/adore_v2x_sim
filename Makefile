SHELL:=/bin/bash

.DEFAULT_GOAL := all 

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

MAKEFLAGS += --no-print-directory


.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

include adore_v2x_sim.mk

.PHONY: all
all: help 

.PHONY: set_env 
set_env: 
	$(eval PROJECT := ${ADORE_V2X_SIM_PROJECT}) 
	$(eval TAG := ${ADORE_V2X_SIM_TAG})

.PHONY: build 
build: set_env start_apt_cacher_ng _build get_cache_statistics ## Build adore_v2x_sim

.PHONY: _build 
_build: set_env root_check docker_group_check clean 
	cd "${ADORE_V2X_SIM_SUBMODULES_PATH}/v2x_if_ros_msg" && make build 
	cd "${ROOT_DIR}" && touch CATKIN_IGNORE
	docker build --network host \
                 --tag ${PROJECT}:${TAG} \
                 --build-arg PROJECT=${PROJECT} \
                 --build-arg V2X_IF_ROS_MSG_TAG=${V2X_IF_ROS_MSG_TAG} .
	docker cp $$(docker create --rm ${PROJECT}:${TAG}):/tmp/${PROJECT}/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: clean
clean: set_env ## Clean adore_v2x_sim build artifacts 
	cd "${ADORE_V2X_SIM_SUBMODULES_PATH}/v2x_if_ros_msg" && make clean 
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${PROJECT}:${TAG}") --force 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}:${TAG}) --force 2> /dev/null || true
