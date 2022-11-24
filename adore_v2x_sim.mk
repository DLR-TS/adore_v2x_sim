# This Makefile contains useful targets that can be included in downstream projects.

ifndef adore_v2x_sim_MAKEFILE_PATH

MAKEFLAGS += --no-print-directory


.EXPORT_ALL_VARIABLES:
adore_v2x_sim_project:=adore_v2x_sim
ADORE_V2X_SIM_PROJECT:=${adore_v2x_sim_project}

#adore_v2x_sim_MAKEFILE_PATH:=$(shell realpath "$(lastword $(MAKEFILE_LIST))" | sed "s|/${adore_v2x_sim_project}.mk||g")
adore_v2x_sim_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")

adore_v2x_sim_tag:=$(shell cd "${adore_v2x_sim_MAKEFILE_PATH}/v2x_if_ros_msg/make_gadgets" && make get_sanitized_branch_name REPO_DIRECTORY=${adore_v2x_sim_MAKEFILE_PATH})
ADORE_V2X_SIM_TAG:=${adore_v2x_sim_tag}

adore_v2x_sim_image:=${adore_v2x_sim_project}:${adore_v2x_sim_tag}
ADORE_V2X_SIM_IMAGE:=${adore_v2x_sim_image}

adore_v2x_sim_CMAKE_BUILD_PATH="${adore_v2x_sim_project}/build"
ADORE_V2X_SIM_CMAKE_BUILD_PATH=${adore_v2x_sim_CMAKE_BULID_PATH}!

adore_v2x_sim_CMAKE_INSTALL_PATH="${adore_v2x_sim_CMAKE_BUILD_PATH}/install"
ADORE_V2X_SIM_CMAKE_INSTALL_PATH=${adore_v2x_sim_CMAKE_INSTALL_PATH}


include ${adore_v2x_sim_MAKEFILE_PATH}/v2x_if_ros_msg/v2x_if_ros_msg.mk

#$(info "adore_v2x_sim_MAKEFILE_PATH: ${adore_v2x_sim_MAKEFILE_PATH}")
#$(error "")


.PHONY: build_adore_v2x_sim 
build_adore_v2x_sim: ## Build adore_v2x_sim
	cd "${adore_v2x_sim_MAKEFILE_PATH}" && make

.PHONY: clean_adore_v2x_sim
clean_adore_v2x_sim: ## Clean adore_v2x_sim build artifacts
	cd "${adore_v2x_sim_MAKEFILE_PATH}" && make clean

.PHONY: branch_adore_v2x_sim
branch_adore_v2x_sim: ## Returns the current docker safe/sanitized branch for adore_v2x_sim
	@printf "%s\n" ${adore_v2x_sim_tag}

.PHONY: image_adore_v2x_sim
image_adore_v2x_sim: ## Returns the current docker image name for adore_v2x_sim
	@printf "%s\n" ${adore_v2x_sim_image}

.PHONY: update_adore_v2x_sim
update_adore_v2x_sim:
	cd "${adore_v2x_sim_MAKEFILE_PATH}" && git pull

endif
