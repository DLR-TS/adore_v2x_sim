# This Makefile contains useful targets that can be included in downstream projects.

ifndef adore_v2x_sim_MAKEFILE_PATH

MAKEFLAGS += --no-print-directory


.EXPORT_ALL_VARIABLES:
ADORE_V2X_SIM_PROJECT:=adore_v2x_sim

ADORE_V2X_SIM_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(SUBMODULES_PATH),)
ADORE_V2X_SIM_SUBMODULES_PATH:=${ADORE_V2X_SIM_MAKEFILE_PATH}
else
ADORE_V2X_SIM_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${ADORE_V2X_SIM_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)),)
$(info INFO: To clone submodules use: 'git submodules update --init --recursive')
$(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
$(info INFO: Default submodule path is: ${ADORE_V2X_SIM_MAKEFILE_PATH}')
$(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif
APT_CACHER_NG_DOCKER_PATH:=${ADORE_V2X_SIM_SUBMODULES_PATH}/apt_cacher_ng_docker
REPO_DIRECTORY:=${ADORE_V2X_SIM_MAKEFILE_PATH}
CPP_PROJECT_DIRECTORY:=${REPO_DIRECTORY}/${ADORE_V2X_SIM_PROJECT}

ADORE_V2X_SIM_TAG:=$(shell cd "${MAKE_GADGETS_PATH}" && make get_sanitized_branch_name REPO_DIRECTORY="${REPO_DIRECTORY}")
ADORE_V2X_SIM_IMAGE:=${ADORE_V2X_SIM_PROJECT}:${ADORE_V2X_SIM_TAG}

ADORE_V2X_SIM_CMAKE_BUILD_PATH:="${ADORE_V2X_SIM_PROJECT}/build"
ADORE_V2X_SIM_CMAKE_INSTALL_PATH:="${ADORE_V2X_SIM_CMAKE_BUILD_PATH}/install"

include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk
include ${APT_CACHER_NG_DOCKER_PATH}/apt_cacher_ng_docker.mk
include ${ADORE_V2X_SIM_SUBMODULES_PATH}/v2x_if_ros_msg/v2x_if_ros_msg.mk

$(info ADORE_V2X_SIM_SUBMODULES_PATH: ${ADORE_V2X_SIM_SUBMODULES_PATH})

.PHONY: build_adore_v2x_sim 
build_adore_v2x_sim: ## Build adore_v2x_sim
	cd "${ADORE_V2X_SIM_MAKEFILE_PATH}" && env -i make build

.PHONY: clean_adore_v2x_sim
clean_adore_v2x_sim: ## Clean adore_v2x_sim build artifacts
	cd "${ADORE_V2X_SIM_MAKEFILE_PATH}" && make clean

.PHONY: branch_adore_v2x_sim
branch_adore_v2x_sim: ## Returns the current docker safe/sanitized branch for adore_v2x_sim
	@printf "%s\n" ${ADORE_V2X_SIM_TAG}

.PHONY: image_adore_v2x_sim
image_adore_v2x_sim: ## Returns the current docker image name for adore_v2x_sim
	@printf "%s\n" ${ADORE_V2X_SIM_IMAGE}

endif
