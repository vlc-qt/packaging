#!/bin/bash
set -ev

########
# OS X #
########
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # Setup versions
    export QT_VERSION_SHORT=5.7
    export QT_VERSION=5.7.0
    export QT_PATH=/Users/$USER/Qt$QT_VERSION
    export VLC_VERSION=2.2.4

    # Install from homebrew
    brew update
    brew outdated cmake || brew upgrade cmake
    brew install p7zip ninja gnu-tar
    brew install lcov --HEAD

    # Install other dependencies
    if [[ ! -d dependencies ]]; then
        mkdir -p dependencies
    fi
    pushd dependencies

    # Install VLC
    if [[ ! -f vlc/vlc-${VLC_VERSION}.dmg ]]; then
        pushd vlc
        curl -LO http://download.videolan.org/vlc/${VLC_VERSION}/macosx/vlc-${VLC_VERSION}.dmg
        popd
    fi
    hdiutil attach vlc/vlc-${VLC_VERSION}.dmg

    # Install Qt
    if [[ ! -d "$QT_PATH/${QT_VERSION_SHORT}/" ]]; then
        mkdir -p qt
        pushd qt
        curl -LO http://download.qt.io/official_releases/qt/${QT_VERSION_SHORT}/${QT_VERSION}/qt-opensource-mac-x64-clang-${QT_VERSION}.dmg
        hdiutil attach qt-opensource-mac-x64-clang-${QT_VERSION}.dmg
        /Volumes/qt-opensource-mac-x64-clang-${QT_VERSION}/qt-opensource-mac-x64-clang-${QT_VERSION}.app/Contents/MacOS/qt-opensource-mac-x64-clang-${QT_VERSION} --script ../../packaging/travis/qt-installer-noninteractive.qs
        popd
    fi
    export PATH=$PATH:$QT_PATH/$QT_VERSION_SHORT/clang_64/bin

    popd
fi
