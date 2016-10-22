ifndef PROJECT
$(error Missing PROJECT variable)
endif
ifndef NAME
$(error Missing NAME variable)
endif
ifndef TARBALL
$(error Missing TARBALL variable)
endif
ifndef TARGET
$(error Missing TARGET variable)
endif
ifndef VERSION
$(error Missing VERSION variable)
endif

all: results

# Unpack source tarball
$(NAME)/CMakeLists.txt: $(TARBALL)
	@echo "Extracting..."
	tar xf $<

# Build
$(NAME)/.build-debug: $(NAME)/CMakeLists.txt
	@echo "-------------------------------------------------------------------"
	@echo "Configuring"
	@echo "-------------------------------------------------------------------"
	@mkdir -p $(dir $@)/build-debug
	@mkdir -p $(dir $@)/install-debug
	cd $(dir $@)/build-debug && \
	cmake .. -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=../install-debug/ \
		-DCOVERAGE=ON \
		-DLIBVLC_INCLUDE_DIR=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/include \
		-DLIBVLC_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlc.dylib \
		-DLIBVLCCORE_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlccore.dylib
	@echo "-------------------------------------------------------------------"
	@echo "Building packages"
	@echo "-------------------------------------------------------------------"
	cd $(dir $@)/build-debug && ninja prepare > /dev/null
	cd $(dir $@)/build-debug && cmake ..
	cd $(dir $@)/build-debug && ninja -v
	cd $(dir $@)/build-debug && ninja coverage -v
	touch $@

$(NAME)/.build-release: $(NAME)/CMakeLists.txt
	@echo "-------------------------------------------------------------------"
	@echo "Configuring"
	@echo "-------------------------------------------------------------------"
	@mkdir -p $(dir $@)/build-release
	@mkdir -p $(dir $@)/install-release
	cd $(dir $@)/build-release && \
	cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install-release/ \
		-DLIBVLC_INCLUDE_DIR=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/include \
		-DLIBVLC_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlc.dylib \
		-DLIBVLCCORE_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlccore.dylib
	@echo "-------------------------------------------------------------------"
	@echo "Building"
	@echo "-------------------------------------------------------------------"
	cd $(dir $@)/build-release && ninja prepare > /dev/null
	cd $(dir $@)/build-release && cmake ..
	cd $(dir $@)/build-release && ninja -v
	cd $(dir $@)/build-release && ninja install -v
	touch $@

$(NAME)/.build-static: $(NAME)/CMakeLists.txt
	@echo "-------------------------------------------------------------------"
	@echo "Configuring"
	@echo "-------------------------------------------------------------------"
	@mkdir -p $(dir $@)/build-static
	@mkdir -p $(dir $@)/install-static
	cd $(dir $@)/build-static && \
	cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DSTATIC=ON -DCMAKE_INSTALL_PREFIX=../install-static/ \
		-DLIBVLC_INCLUDE_DIR=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/include \
		-DLIBVLC_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlc.dylib \
		-DLIBVLCCORE_LIBRARY=/Volumes/vlc-${VLC_VERSION}/VLC.app/Contents/MacOS/lib/libvlccore.dylib
	@echo "-------------------------------------------------------------------"
	@echo "Building"
	@echo "-------------------------------------------------------------------"
	cd $(dir $@)/build-static && ninja prepare > /dev/null
	cd $(dir $@)/build-static && cmake ..
	cd $(dir $@)/build-static && ninja -v
	cd $(dir $@)/build-static && ninja install -v
	cd $(dir $@)/build-static && ninja test -v
	touch $@

results: $(NAME)/.build-debug \
		 $(NAME)/.build-release \
		 $(NAME)/.build-static
	@echo "-------------------------------------------------------------------"
	@echo "Copying packages"
	@echo "-------------------------------------------------------------------"
	@mkdir -p $@.tmp/
	cd $(NAME)/install-release && zip -r -X libvlc-qt_$(VERSION)_macos$(RELEASE).zip lib qml
	mv $(NAME)/install-release/libvlc-qt_$(VERSION)_macos$(RELEASE).zip $@.tmp/
	mv $(NAME)/build-debug/coverage.info $@.tmp/
	mv -f $@.tmp $@
	touch $@/.done
