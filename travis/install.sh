#!/bin/bash
set -ev

########
# OS X #
########
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # Setup versions
    export QT_VERSION_SHORT=5.9.1
    export QT_VERSION=5.9.1
    export QT_PATH=/Users/$USER/Qt$QT_VERSION
    export VLC_VERSION=2.2.6

    # Install from homebrew
    brew update
    # brew outdated cmake || brew upgrade cmake
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
        curl -LO http://download.qt.io/official_releases/online_installers/qt-unified-mac-x64-online.dmg
        hdiutil attach qt-unified-mac-x64-online.dmg

        QT_APP=$(cd /Volumes && ls | grep qt-unified-mac)
        QT_APP=${QT_APP//\//}

        /Volumes/${QT_APP}/${QT_APP}.app/Contents/MacOS/${QT_APP} -v --script ../../packaging/travis/qt-installer-noninteractive.qs
        popd
    fi
    export PATH=$PATH:$QT_PATH/$QT_VERSION_SHORT/clang_64/bin

    popd
fi
