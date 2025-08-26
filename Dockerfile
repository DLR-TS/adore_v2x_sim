ARG PROJECT

ARG V2X_IF_ROS_MSG_TAG="latest"


FROM v2x_if_ros_msg:${V2X_IF_ROS_MSG_TAG} AS v2x_if_ros_msg
FROM ros:noetic-ros-core-focal AS adore_v2x_sim_requirements_base


ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


RUN mkdir -p /tmp/${PROJECT}
WORKDIR /tmp/${PROJECT}
COPY files/${REQUIREMENTS_FILE} /tmp/${PROJECT}

# Step 0: Allow insecure repos temporarily
RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99insecure && \
    echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/99insecure

# Step 1: Install curl, gnupg2, etc.
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg2 ca-certificates

# Step 2: Replace the expired key (used by ROS repo already present in base image)
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | \
    gpg --dearmor --no-tty --batch --yes -o /usr/share/keyrings/ros1-latest-archive-keyring.gpg


# Step 3: Remove insecure workaround
RUN rm /etc/apt/apt.conf.d/99insecure

RUN apt-get update && \
    apt-get install --no-install-recommends -y $(sed '/^#/d' ${REQUIREMENTS_FILE}) && \
    rm -rf /var/lib/apt/lists/*

COPY ${PROJECT} /tmp/${PROJECT}/${PROJECT}

FROM adore_v2x_sim_requirements_base AS adore_v2x_sim_external_library_requirements_base
ARG INSTALL_PREFIX=/tmp/${PROJECT}/${PROJECT}/build/install
RUN mkdir -p "${INSTALL_PREFIX}"
RUN cd /tmp/${PROJECT}/${PROJECT}/build && ln -sf install devel

ARG LIB=v2x_if_ros_msg
COPY --from=v2x_if_ros_msg /tmp/${LIB} /tmp/${LIB}
WORKDIR /tmp/${LIB}/${LIB}/build
RUN cmake --install . --prefix ${INSTALL_PREFIX} 



COPY ${PROJECT} /tmp/${PROJECT}

FROM adore_v2x_sim_external_library_requirements_base AS adore_v2x_sim_builder
ARG PROJECT

SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/${PROJECT}/${PROJECT}/build


RUN source /opt/ros/noetic/setup.bash && \
    cmake .. \
             -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX="install" && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . && \
    mv CMakeCache.txt CMakeCache.txt.build

FROM alpine:3.14

ARG PROJECT

COPY --from=adore_v2x_sim_builder /tmp/${PROJECT}/${PROJECT} /tmp/${PROJECT}/${PROJECT}

