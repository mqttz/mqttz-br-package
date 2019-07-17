################################################################################
#
# mqttz
#
################################################################################

MQTTZ_SITE = /home/cse/Work/CSEM/ARM-TZ/mqtt-tz/code/mosquitto
MQTTZ_SITE_METHOD = local

define MQTTZ_BUILD_CMDS
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) all
endef

#define HELLO_INSTALL_TARGET_CMDS
#    $(INSTALL) -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin
#endef

$(eval $(generic-package))
