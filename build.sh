#
# To run :
#   ./build.sh
#
# Known working list of kernels:
#
# k4.19.31-ax86
#

set -e

# These two values will need to be updated to work with your local setup
#####
SOURCE_BUILD_DIR='/mnt/source-code/androidx86'
DOCKER_REG='docreg.local:5000'
#####

ANDROID_VER='pie'
TARGET_PROD='android_x86_64'
TARGET_BUILD_VAR='user'
KERNEL_VER='4.9'
PROJECT='androidx86'
PROJECT_REPO='http://scm.osdn.net/gitroot/android-x86/manifest.git'
PROJECT_REPO_BRANCH="${ANDROID_VER}-x86"

#Need to update for each new Android version
bliss_ver() {
    case $ANDROID_VER in
        q)
            printf 'q'
            ;;
        pie)
            printf 'p9.0'
            ;;
        oreo)
            printf 'o8.1'
            ;;
    esac
    echo '-x86'
}

while getopts 'bc:j:s:t:' option; do
    case "${option}" in
        a|android-version)
            ANDROID_VER="$OPTARG"
            PROJECT_REPO_BRANCH="${ANDROID_VER}-x86"
            echo "Set Android Version to ${ANDROID_VER}"
            ;;
        b|bliss)
            PROJECT="bliss"
            echo "Set Project to ${PROJECT}"
            PROJECT_REPO='https://github.com/BlissRoms-x86/manifest.git'
            PROJECT_REPO_BRANCH=$(bliss_ver)
            ;;
        k|kernel)
            KERNEL="$OPTARG"
            echo "Set Kernel Version use ${KERNEL}"
            ;;
        *)
            echo "Unknown option ${OPTARG}"
            exit 0
            ;;
    esac
done
shift $((OPTIND -1))

SERVICE_NAME="${PROJECT}_builder"
BUILD_PATH="${SOURCE_BUILD_DIR}/${PROJECT}/${ANDROID_VER}"

export PROJECT_REPO=$PROJECT_REPO
export PROJECT_REPO_BRANCH=$PROJECT_REPO_BRANCH

if [ ! -d $BUILD_PATH ]; then
    mkdir -p $BUILD_PATH
fi

echo 'Building base..'
docker build -t "${DOCKER_REG}/androidx86_builder:base" \
    -f Dockerfile.base .

cat <<EOF > cmds/download_repo.sh
export PYTHONHTTPSVERIFY=0
git config --global http.sslVerify "false"
git config --global color.ui false

# Download repo since it is so big
repo init -u ${PROJECT_REPO} -b ${PROJECT_REPO_BRANCH} && \
    repo sync -j 14 --no-tags --no-clone-bundle
EOF

if [ $PROJECT == 'androidx86' ]; then
    cat <<EOF > cmds/make_k${KERNEL_VER}.sh
cd kernel && \
git fetch x86 kernel-${KERNEL_VER} && \
git checkout FETCH_HEAD && \
cd ..
EOF
elif [ $PROJECT == 'bliss' ]; then
    cat <<EOF > cmds/prepare_kernel.sh
cd kernel && \
git fetch BR-x86 && \
git checkout BR-x86/\${1} && \
make clean && \
make mrproper && \
cd /androidx86
EOF

    cat <<EOF > cmds/list_kernels.sh
cd kernel && \
git remote show BR-x86 && \
cd /androidx86
EOF

    cat <<EOF > cmds/make_image.sh
. build/envsetup.sh && \
lunch android_x86_64-userdebug && \
make -j 16 iso_img
EOF
fi

cat <<EOF > cmds/init.sh
for bdir in vendor/bliss_priv/proprietary vendor/bliss_priv/source; do
    if ! [ -d $bdir ]; then
        mkdir $bdir
    fi
done

PROPRIETARY_TOOLS='/androidx86/vendor/bliss_priv/proprietary'
if ! [ -d $PROPRIETARY_TOOLS ]; then
    cp -r proprietary $PROPRIETARY_TOOLS
fi

if [ -d '/androidx86/cmds' ]; then
    rm -rf /androidx86/cmds
fi

mv cmds/setup2.sh /androidx86/vendor/bliss_priv/
mv cmds /androidx86/
EOF

chmod +x cmds/prepare_kernel.sh
chmod +x cmds/list_kernels.sh
chmod +x cmds/make_image.sh
chmod +x cmds/init.sh

echo 'Building main image..'
docker build -t "${DOCKER_REG}/${SERVICE_NAME}:${ANDROID_VER}_${TARGET_PROD}" \
    --build-arg DOCKER_REG="${DOCKER_REGISTRY}" \
    --build-arg ANDROID_VERSION="${ANDROID_VER}" \
    --build-arg TARGET_PRODUCT="${TARGET_PROD}" \
    --build-arg TARGET_BUILD_VARIANT="${TARGET_BUILD_VAR}" \
    --build-arg BUILD_PATH_DIR="${BUILD_PATH}" \
    --build-arg KERNEL_VERSION="${KERNEL_VER}" \
    -f Dockerfile .

echo 'Please run with the following:'
echo ''
echo "docker run --mount type=bind,src=${BUILD_PATH},dst=/androidx86 -it ${DOCKER_REG}/${SERVICE_NAME}:${ANDROID_VER}_${TARGET_PROD} /bin/bash"
echo ''
echo 'Once inside the container, run `./init.sh && cd /androidx86`'

# If the propriety directory failed to copy, exit the docker container and run the following:
#
# echo 'cd /mnt/source-code/androidx86/bliss/pie/vendor/bliss_priv'
# echo './setup2.sh'
#
# This will download and install the latest required propriety binaries required for the build process.