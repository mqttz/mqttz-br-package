################################################################################
#
# MQTTZ
#
################################################################################

MQTTZ_SITE = /home/csegarra/Work/CSEM/MQT-TZ/mosquitto
MQTTZ_SITE_METHOD = local
#MQTTZ_INSTALL_STAGING = YES

MQTTZ_MAKE_OPTS = \
	UNAME=Linux \
	STRIP=true \
	prefix=/usr \
	WITH_WRAP=no \
	WITH_DOCS=no

# adns uses getaddrinfo_a
ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),y)
MQTTZ_MAKE_OPTS += WITH_ADNS=yes
else
MQTTZ_MAKE_OPTS += WITH_ADNS=no
endif

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
MQTTZ_MAKE_OPTS += WITH_THREADING=yes
else
MQTTZ_MAKE_OPTS += WITH_THREADING=no
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL),y)
MQTTZ_DEPENDENCIES += libopenssl
MQTTZ_MAKE_OPTS += WITH_TLS=yes
else
MQTTZ_MAKE_OPTS += WITH_TLS=no
endif

ifeq ($(BR2_PACKAGE_C_ARES),y)
MQTTZ_DEPENDENCIES += c-ares
MQTTZ_MAKE_OPTS += WITH_SRV=yes
else
MQTTZ_MAKE_OPTS += WITH_SRV=no
endif

ifeq ($(BR2_PACKAGE_UTIL_LINUX_LIBUUID),y)
MQTTZ_DEPENDENCIES += util-linux
MQTTZ_MAKE_OPTS += WITH_UUID=yes
else
MQTTZ_MAKE_OPTS += WITH_UUID=no
endif

ifeq ($(BR2_PACKAGE_LIBWEBSOCKETS),y)
MQTTZ_DEPENDENCIES += libwebsockets
MQTTZ_MAKE_OPTS += WITH_WEBSOCKETS=yes
else
MQTTZ_MAKE_OPTS += WITH_WEBSOCKETS=no
endif

# C++ support is only used to create a wrapper library
ifneq ($(BR2_INSTALL_LIBSTDCPP),y)
define MQTTZ_DISABLE_CPP
	$(SED) '/-C cpp/d' $(@D)/lib/Makefile
endef

MQTTZ_POST_PATCH_HOOKS += MQTTZ_DISABLE_CPP
endif

MQTTZ_MAKE_DIRS = lib client
ifeq ($(BR2_PACKAGE_MQTTZ_BROKER),y)
MQTTZ_MAKE_DIRS += src
endif

define MQTTZ_BUILD_CMDS
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) DIRS="$(MQTTZ_MAKE_DIRS)" \
		$(MQTTZ_MAKE_OPTS)
endef

define MQTTZ_INSTALL_STAGING_CMDS
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) DIRS="$(MQTTZ_MAKE_DIRS)" \
		$(MQTTZ_MAKE_OPTS) DESTDIR=$(STAGING_DIR) install
endef

define MQTTZ_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) DIRS="$(MQTTZ_MAKE_DIRS)" \
		$(MQTTZ_MAKE_OPTS) DESTDIR=$(TARGET_DIR) install
	rm -f $(TARGET_DIR)/etc/mosquitto/*.example
	$(INSTALL) -D -m 0644 $(@D)/mosquitto-s.conf \
		$(TARGET_DIR)/etc/mosquitto/mosquitto-s.conf
endef

ifeq ($(BR2_PACKAGE_MQTTZ_BROKER),y)
define MQTTZ_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/mosquitto/S50mosquitto \
		$(TARGET_DIR)/etc/init.d/S50mosquitto
endef

define MQTTZ_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/mosquitto/mosquitto.service \
		$(TARGET_DIR)/usr/lib/systemd/system/mosquitto.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -fs ../../../../usr/lib/systemd/system/mosquitto.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/mosquitto.service
endef

define MQTTZ_USERS
	mosquitto -1 nogroup -1 * - - - Mosquitto user
endef
endif

$(eval $(generic-package))
