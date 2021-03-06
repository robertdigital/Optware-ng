#############################################################
#
# libtermcap
#
#############################################################

TERMCAP_SITE=ftp://ftp.gnu.org/gnu/termcap/
TERMCAP_VERSION=1.3.1
TERMCAP_SOURCE:=termcap-$(TERMCAP_VERSION).tar.gz
TERMCAP_DIR=termcap-$(TERMCAP_VERSION)
TERMCAP_UNZIP=zcat
TERMCAP_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
TERMCAP_DESCRIPTION=Terminal emulation library
TERMCAP_SECTION=libs
TERMCAP_PRIORITY=optional
TERMCAP_DEPENDS=
TERMCAP_CONFLICTS=

TERMCAP_IPK_VERSION=3

TERMCAP_CPPFLAGS=-fPIC
TERMCAP_LDFLAGS=

TERMCAP_BUILD_DIR:=$(BUILD_DIR)/termcap
TERMCAP_SOURCE_DIR:=$(SOURCE_DIR)/termcap
TERMCAP_IPK_DIR:=$(BUILD_DIR)/termcap-$(TERMCAP_VERSION)-ipk
TERMCAP_IPK=$(BUILD_DIR)/termcap_$(TERMCAP_VERSION)-$(TERMCAP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(TERMCAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(TERMCAP_SITE)/$(TERMCAP_SOURCE)

termcap-source: $(DL_DIR)/$(TERMCAP_SOURCE)

$(TERMCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(TERMCAP_SOURCE)
	rm -rf $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR)
	$(TERMCAP_UNZIP) $(DL_DIR)/$(TERMCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR)
	(cd $(TERMCAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TERMCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TERMCAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-install-termcap \
		--with-termcap=$(TARGET_PREFIX)/etc/termcap \
	)
	touch $(TERMCAP_BUILD_DIR)/.configured

termcap-unpack: $(TERMCAP_BUILD_DIR)/.configured

$(TERMCAP_BUILD_DIR)/libtermcap.a: $(TERMCAP_BUILD_DIR)/.configured
	make -C $(TERMCAP_BUILD_DIR) AR=$(TARGET_AR) CPPFLAGS="$(STAGING_CPPFLAGS) $(TERMCAP_CPPFLAGS)"

termcap: $(TERMCAP_BUILD_DIR)/libtermcap.a

$(STAGING_LIB_DIR)/libtermcap.a: $(TERMCAP_BUILD_DIR)/libtermcap.a
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(TERMCAP_BUILD_DIR)/termcap.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(TERMCAP_BUILD_DIR)/libtermcap.a $(STAGING_LIB_DIR)

termcap-stage: $(STAGING_LIB_DIR)/libtermcap.a

$(TERMCAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(TERMCAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: termcap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TERMCAP_PRIORITY)" >>$@
	@echo "Section: $(TERMCAP_SECTION)" >>$@
	@echo "Version: $(TERMCAP_VERSION)-$(TERMCAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TERMCAP_MAINTAINER)" >>$@
	@echo "Source: $(TERMCAP_SITE)/$(TERMCAP_SOURCE)" >>$@
	@echo "Description: $(TERMCAP_DESCRIPTION)" >>$@
	@echo "Depends: $(TERMCAP_DEPENDS)" >>$@
	@echo "Conflicts: $(TERMCAP_CONFLICTS)" >>$@

$(TERMCAP_IPK): $(TERMCAP_BUILD_DIR)/libtermcap.a
	$(INSTALL) -d $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(TERMCAP_BUILD_DIR)/termcap.h $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/include/termcap.h
	$(INSTALL) -d $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 644 $(TERMCAP_BUILD_DIR)/libtermcap.a $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/lib/libtermcap.a
	$(INSTALL) -d $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -m 644 $(TERMCAP_BUILD_DIR)/termcap.src $(TERMCAP_IPK_DIR)$(TARGET_PREFIX)/etc/termcap
	$(MAKE) $(TERMCAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TERMCAP_IPK_DIR)

termcap-ipk: $(TERMCAP_IPK)

termcap-clean:
	-make -C $(TERMCAP_BUILD_DIR) clean

termcap-dirclean:
	rm -rf $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR) $(TERMCAP_IPK_DIR) $(TERMCAP_IPK)
