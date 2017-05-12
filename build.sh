#!/usr/bin/env bash
#### Thanks to https://medium.com/@premek/autobuild-love2d-games-travisci-github-ccf50ae7108e for the example

PROJECT_NAME="SpaceSailor"
LOVE_VERSION="0.10.2"

# Downloads required libraries
function downloadLibraries {
    if [ ! -f "lib/love-${LOVE_VERSION}-win32.zip" ]; then
        mkdir "lib"
        cd "lib"
        curl -LOk -# "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win32.zip"
        cd -
    fi
}

# Builds .love file
function createLoveFile {
    mkdir "target"
    cp -r src/* "target"
    cp -r "assets" "target/assets"
    cd "target"
    zip -9 -r "${PROJECT_NAME}.love" .
    rm *.lua
    rm -rf assets/
    cd -
}

# Builds Windows .exe file
function buildWindowsExe {
    unzip -o "lib/love-${LOVE_VERSION}-win32.zip" -d "target"
    cat "target/love-${LOVE_VERSION}-win32/love.exe" "target/${PROJECT_NAME}.love" > "target/${PROJECT_NAME}.exe"
    cp -r target/love-${LOVE_VERSION}-win32/*dll "target"
}

# Checks that all lua files have correct syntax
function validate {
    find . -iname "*.lua" | xargs luac -p || { echo 'luac parse test failed' ; exit 1; }
}

# Cleans the build path
function clean {
 rm -rf "target"
 exit
}

### clean
if [ "$1" == "clean" ]; then
    clean
fi

### validate
if [ "$1" == "validate" ]; then
    validate
fi

### build
if [ "$1" == "build" ]; then
    echo "Building LOVE file..."
    createLoveFile
    echo "Downloading libraries..."
    downloadLibraries
    echo "Building Windows executable..."
    buildWindowsExe
fi