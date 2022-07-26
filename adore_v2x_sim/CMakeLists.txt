# **:*****************************************************************************
# * Copyright (C) 2017-2020 German Aerospace Center (DLR). 
# * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
# *
# * This program and the accompanying materials are made available under the 
# * terms of the Eclipse Public License 2.0 which is available at
# * http://www.eclipse.org/legal/epl-2.0.
# *
# * SPDX-License-Identifier: EPL-2.0 
# *
# * Contributors: 
# *  Daniel Heß
# ********************************************************************************
cmake_minimum_required(VERSION 2.8.3)
project(adore_v2x_sim)

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

set(PACKAGE_VENDOR "DLR TS-KOS-SAI")
set(PACKAGE_DESCRIPTION ${PROJECT_NAME})
set(PACKAGE_MAINTAINER "DLR TS-KOS-SAI")
set(PACKAGE_MAINTAINER_EMAIL "ts-kos-sai@dlr.de")

include(GNUInstallDirs)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(Packing)

set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH};/tmp/v2x_if_ros_msg/build/install")
find_package(catkin REQUIRED COMPONENTS
	message_generation
	nav_msgs
	roscpp
  dsrc_v2_dsrc
  denm_v2_denm_pdu_descriptions
  dsrc_v2_mapem_pdu_descriptions
  dsrc_v2_spatem_pdu_descriptions
  dsrc_v2_srem_pdu_descriptions
  cpm_v1_19_cpm_pdu_descriptions
  mcm_dmove_mcm_dmove

  cam_v2_cam_pdu_descriptions
  cpm_v1_19_cpm_freespaceaddendum_descriptions
  cpm_v1_19_cpm_sensorinformation_descriptions
  cpm_v1_19_cpm_originatingstationdata_descriptions
  cpm_v1_19_cpm_perceivedobject_descriptions
  dsrc_v2_srem_pdu_descriptions
  )

add_message_files(
  FILES
  V2XMetaSim.msg
  SimSPATEM.msg
  SimMAPEM.msg
  SimMCM.msg
  SimDENM.msg
  SimSREM.msg
#  strp_fau/msg/SpaceTimeReservationProcedure.msg
)

generate_messages(
    DEPENDENCIES
    std_msgs  # Or other packages containing msgs
    nav_msgs
    geometry_msgs
#   strp_fau
    dsrc_v2_dsrc
    denm_v2_denm_pdu_descriptions
    dsrc_v2_mapem_pdu_descriptions
    dsrc_v2_spatem_pdu_descriptions
    dsrc_v2_srem_pdu_descriptions
    cpm_v1_19_cpm_pdu_descriptions
    mcm_dmove_mcm_dmove
)

catkin_package(
  CATKIN_DEPENDS
    roscpp
    std_msgs
    message_runtime
    geometry_msgs
    nav_msgs
    adore_if_ros_msg
    denm_v2_denm_pdu_descriptions
    dsrc_v2_mapem_pdu_descriptions
    dsrc_v2_spatem_pdu_descriptions
    cpm_v1_19_cpm_pdu_descriptions
    mcm_dmove_mcm_dmove
)

include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

add_executable(channel_sim_node src/channel_sim_node.cpp)
target_link_libraries(
    channel_sim_node  
    ${PROJECT_NAME}::${PROJECT_NAME}  
    ${catkin_LIBRARIES}
)

set_target_properties(
    channel_sim_node PROPERTIES
    INSTALL_RPATH "${CMAKE_CURRENT_SOURCE_DIR}/../${PROJECT_NAME}/build/install/lib"
    BUILD_WITH_INSTALL_RPATH 1
)

include(PackagingInstallTargets)
