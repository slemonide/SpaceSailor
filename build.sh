#!/usr/bin/env bash

function createLoveFile {
    zip -9 -r game.love `dirname $0`
}

function buildWindowsExe {
    wget https://bitbucket.org/rude/love/downloads/love-0.10.2-win32.zip
    unzip love-0.10.2-win32.zip
    cat love-0.10.2-win32/love.exe game.love > game.exe
    cp love-0.10.2-win32/*dll .
}

#createLoveFile
#buildWindowsExe