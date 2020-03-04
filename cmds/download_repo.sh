export PYTHONHTTPSVERIFY=0
git config --global http.sslVerify "false"
git config --global color.ui false

# Download repo since it is so big
repo init -u https://github.com/BlissRoms-x86/manifest.git -b p9.0-x86 &&     repo sync -j 14 --no-tags --no-clone-bundle
