export ARCHS = armv7 arm64
export TARGET = iphone:latest:5.0

GO_EASY_ON_ME = 1

# Path to theos
THEOS = /opt/theos

# IP address of target device
THEOS_DEVICE_IP = 192.168.5.11

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = Preference

BUNDLE_NAME = LunarCalendarWidget
LunarCalendarWidget_FILES = LunarCalendarWidgetController.m \
			    TLCCWidgetViewController.m \
			    ../Common/NSCalendarAdditons.m \
			    ../Common/NSDateComponentsAdditions.m \
			    ../Common/lunardate.c \
			    ../Common/solarterm.c \
			    ../Common/TLCalendarScrollView.m \
			    ../Common/TLFestivalsManager.m \
			    ../Common/TLPreferences.m \
			    ../Common/TLCalendarDisplayAttributeKeys.m \
			    TLLunarCalendarWeeView.m \
			    TLMonthWidgetView.m \
			    TLWeekWidgetView.m \
			    TLDayWidgetView.m \
			    TLWidgetView.m
LunarCalendarWidget_INSTALL_PATH = /System/Library/WeeAppPlugins
LunarCalendarWidget_FRAMEWORKS = UIKit CoreGraphics
LunarCalendarWidget_LDFLAGS = -F$(SYSROOT)/System/Library/PrivateFrameworks -weak_framework SpringBoardUIServices

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-install::
	install.exec "dpkg -r com.crazytonyli.chinesecalendarpro"

after-install::
	install.exec "killall -9 SpringBoard"
