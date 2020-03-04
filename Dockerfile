FROM docreg.local:5000/androidx86_builder:base as ab_base

ARG ANDROID_VERSION=q
ENV ANDROID_VERSION $ANDROID_VERSION
ARG TARGET_PRODUCT=asus_laptop
ENV TARGET_PRODUCT $TARGET_PRODUCT
ARG TARGET_BUILD_VARIANT=user
ENV TARGET_BUILD_VARIANT $TARGET_BUILD_VARIANT
ARG BUILD_PATH_DIR=/mnt/video/androidx86
ENV BUILD_PATH_DIR $BUILD_PATH_DIR
ARG KERNEL_VERSION=4.9
ENV KERNEL_VERSION $KERNEL_VERSION

RUN mkdir -p /cmds

COPY ./cmds cmds
COPY ./proprietary proprietary

RUN mv cmds/init.sh .

ENV BOARD_KERNEL_IMAGE_NAME=Image

CMD ["cp", "/root/download_repo.sh", "/androidx86"]

# WORKDIR android-x86

# ENV PYTHONHTTPSVERIFY=0
# RUN export PYTHONHTTPSVERIFY=0
# RUN git config --global http.sslVerify "false"
# RUN git config --global color.ui false