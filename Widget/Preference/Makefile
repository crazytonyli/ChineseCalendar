include ../config.mk
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LunarCalendarWidgetPreference
LunarCalendarWidgetPreference_FILES = LCWSettingsController.m \
																			LCWPListController.m \
																			LCWPColorController.m 
LunarCalendarWidgetPreference_INSTALL_PATH = /Library/PreferenceBundles
LunarCalendarWidgetPreference_FRAMEWORKS = UIKit
LunarCalendarWidgetPreference_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LunarCalendarWidgetPreference.plist$(ECHO_END)
