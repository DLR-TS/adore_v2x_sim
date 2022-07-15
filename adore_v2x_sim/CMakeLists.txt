# *******************************************************************************
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
  INCLUDE_DIRS include
  LIBRARIES adore_v2x_sim
  CATKIN_DEPENDS roscpp std_msgs message_runtime geometry_msgs nav_msgs
  CATKIN_DEPENDS adore_if_ros_msg
#  CATKIN_DEPENDS strp_fau
  CATKIN_DEPENDS denm_v2_denm_pdu_descriptions
  CATKIN_DEPENDS dsrc_v2_mapem_pdu_descriptions
  CATKIN_DEPENDS dsrc_v2_spatem_pdu_descriptions
 # CATKIN_DEPENDS dsrc_v2_srem_pdu_descriptions
  CATKIN_DEPENDS cpm_v1_19_cpm_pdu_descriptions
  CATKIN_DEPENDS mcm_dmove_mcm_dmove
#  DEPENDS system_lib
)

include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

add_executable(channel_sim_node src/channel_sim_node.cpp)
add_dependencies(channel_sim_node ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})
target_link_libraries(channel_sim_node  ${catkin_LIBRARIES} )

include(PackagingInstallTargets)

## Mark cpp header files for installation
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
  FILES_MATCHING PATTERN "*.h"
  PATTERN ".svn" EXCLUDE
)

install(TARGETS ${PROJECT_NAME}
        EXPORT ${PROJECT_NAME}_Targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})


include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/LibraryConfig.cmake.in"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION
  ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)

install(EXPORT ${PROJECT_NAME}_Targets
        COMPONENT ${PROJECT_NAME}
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake
)

install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
              # "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake
        COMPONENT ${PROJECT_NAME}
)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/build/install/include DESTINATION .) 

