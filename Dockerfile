ARG PROJECT

ARG V2X_IF_ROS_MSG_TAG="latest"


FROM v2x_if_ros_msg:${V2X_IF_ROS_MSG_TAG} AS v2x_if_ros_msg
FROM ros:noetic-ros-core-focal AS adore_v2x_sim_requirements_base


ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


RUN mkdir -p /tmp/${PROJECT}
WORKDIR /tmp/${PROJECT}
COPY files/${REQUIREMENTS_FILE} /tmp/${PROJECT}


RUN apt-get update && \
    xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/${PROJECT}/${PROJECT}/build/devel && \
    cd /tmp/${PROJECT}/${PROJECT}/build && ln -s devel install 

COPY --from=v2x_if_ros_msg /tmp/v2x_if_ros_msg /tmp/v2x_if_ros_msg
WORKDIR /tmp/v2x_if_ros_msg/v2x_if_ros_msg/build
RUN cmake --install . --prefix /tmp/${PROJECT}/${PROJECT}/build/install


COPY ${PROJECT} /tmp/${PROJECT}/${PROJECT}

FROM adore_v2x_sim_requirements_base AS adore_v2x_sim_builder
ARG PROJECT
WORKDIR /tmp/${PROJECT}/${PROJECT}
RUN mkdir -p build 
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/${PROJECT}/${PROJECT}/build


RUN source /opt/ros/noetic/setup.bash && \
    cmake .. && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . && \
    cd /tmp/${PROJECT}/${PROJECT}/build && ln -s devel install && \
    mv CMakeCache.txt CMakeCache.txt.build

FROM alpine:3.14

ARG PROJECT
#COPY --from=adore_v2x_sim_builder /tmp/${PROJECT}/build /tmp/${PROJECT}/build
COPY --from=adore_v2x_sim_builder /tmp/${PROJECT}/${PROJECT} /tmp/${PROJECT}/${PROJECT}

