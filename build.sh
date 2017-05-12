#!/usr/bin/env bash
#### Thanks to https://medium.com/@premek/autobuild-love2d-games-travisci-github-ccf50ae7108e for the example

PROJECT_NAME="SpaceSailor"
LOVE_VERSION="0.10.2"

# Downloads required libraries
function downloadLibraries {
    mkdir "lib"
    cd "lib"
    wget "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win32.zip"
    cd -
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
    tmp="target/tmp/"
    mkdir -p "${tmp}/${PROJECT_NAME}"
    cat "target/love-${LOVE_VERSION}-win32/love.exe" "target/${PROJECT_NAME}.love"
        > "$tmp/${PROJECT_NAME}/${PROJECT_NAME}.exe"
    cp "target/love-${LOVE_VERSION}-win32/*dll" "target/love-${LOVE_VERSION}-win32/license*" "${tmp}/${PROJECT_NAME}"
    cd "${tmp}"
    zip -9 -r - "$PROJECT_NAME" > "${PROJECT_NAME}-win.zip"
    cd -
    cp "${tmp}/${PROJECT_NAME}-win.zip" "target/"
    rm -r "${tmp}"
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

### build
if [ "$1" == "build" ]; then
    downloadLibraries
    createLoveFile
fi
#buildWindowsExe