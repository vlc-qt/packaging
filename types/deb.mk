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
ifndef RELEASE
$(error Missing RELEASE variable)
endif
ifndef DEBEMAIL
DEBEMAIL="info@tano.si"
endif
ifndef DEBFULLNAME
DEBFULLNAME="Tano.si Buildbot"
endif

# https://wiki.debian.org/IntroDebianPackaging:
# The name consists of the source package name, an underscore, the upstream
# version number, followed by .orig.tar.gz
# Note that there is an underscore (_), not a dash (-), in the name.
# This is important, because the packaging tools are picky.
DEB_NAME=$(PROJECT)_$(VERSION)
DEB_TARBALL=$(DEB_NAME).orig.tar.gz

all: results

# Unpack source tarball
$(NAME)/debian/changelog: $(TARBALL)
	tar xf $<
	mv -f debian/ $(NAME)/
	ls -l $(NAME)/

# Copy tarball to .orig.tar.gz (needed to generate .dsc)
$(DEB_TARBALL): $(TARBALL)
	cp -pf $< $@

# Build packages
$(DEB_NAME)-$(RELEASE)~$(TARGET).dsc: $(NAME)/debian/changelog $(DEB_TARBALL)
	@echo "-------------------------------------------------------------------"
	@echo "Updating changelog"
	@echo "-------------------------------------------------------------------"
	cd $(NAME) && NAME=$(DEBFULLNAME) DEBEMAIL=$(DEBEMAIL) \
		dch -b -u low -D $(TARGET) -v $(VERSION)-$(RELEASE)~$(TARGET) "Automatic build for $(TARGET)"
	@echo
	@echo "-------------------------------------------------------------------"
	@echo "Building packages"
	@echo "-------------------------------------------------------------------"
	cd $(NAME) && debuild --preserve-envvar=CCACHE_DIR \
    	--prepend-path=/usr/lib/ccache \
		-uc -us
	@echo
	@echo "-------------------------------------------------------------------"
	@echo "Running tests"
	@echo "-------------------------------------------------------------------"
	cd $(NAME)/obj-* && xvfb-run -s "-screen 0 1024x768x24 +extension GLX +render" make test

results: $(DEB_NAME)-$(RELEASE)~$(TARGET).dsc
	@echo "-------------------------------------------------------------------"
	@echo "Copying packages"
	@echo "-------------------------------------------------------------------"
	mkdir -p $@.tmp/
	mv -f *.deb *.changes *.dsc $@.tmp/
	mv -f *.diff.* *.orig.tar.* $@.tmp/
	mv -f *.build $@.tmp/build.log
	mv -f $@.tmp $@
	touch $@/.done
