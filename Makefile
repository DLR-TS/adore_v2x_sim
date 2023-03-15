SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFILE_PATH:=$(shell dirname "$(abspath "$(lastword $(MAKEFILE_LIST)"))")

#$(info "ROOT_DIR: ${ROOT_DIR}")
#$(info "MAKEFILE_PATH: ${MAKEFILE_PATH}")

.DEFAULT_GOAL := help 

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
include adore_v2x_sim.mk

DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: all
all: build

.PHONY: set_env 
set_env: 
	$(eval PROJECT := ${ADORE_V2X_SIM_PROJECT}) 
	$(eval TAG := ${ADORE_V2X_SIM_TAG})

.PHONY: build 
build: start_apt_cacher_ng _build get_cache_statistics ## Build adore_v2x_sim

.PHONY: _build 
_build: root_check docker_group_check set_env clean 
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
