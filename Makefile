ifeq ($(shell [ -f ./theos/makefiles/common.mk ] && echo 1 || echo 0),0)
all clean package install::
	git submodule update --init --recursive
	$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
else

# TaskToggle MobileSubstrate extension
TWEAK_NAME = TaskToggle
TaskToggle_OBJC_FILES = Tweak.xm
TaskToggle_FRAMEWORKS = UIKit CoreGraphics QuartzCore
TaskToggle_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices

# TaskToggle preferences bundle
BUNDLE_NAME = TGPrefs
TGPrefs_OBJC_FILES = TGPrefsBase.m TGPrefsViewController.m TGPrefsRoot.m TGPrefsToggles.m TGPrefsTheme.m TGPrefsSelf.m TGPrefsPoof.m TGPrefsAddons.m TGPrefsSystem.m TGPrefsWeb.m TGPrefsUtilities.m
TGPrefs_INSTALL_PATH = /Library/PreferenceBundles
TGPrefs_FRAMEWORKS = UIKit CoreGraphics QuartzCore
TGPrefs_PRIVATE_FRAMEWORKS = AppSupport Preferences
TGPrefs_LDFLAGS = $(FW_OBJ_DIR)/TaskToggle.dylib

TOOL_NAME := setuid
setuid_C_FILES = setuid.c
setuid_PACKAGE_TARGET_DIR = /usr/libexec/tasktoggle

include theos/makefiles/common.mk
include theos/makefiles/tweak.mk
include theos/makefiles/bundle.mk
include theos/makefiles/tool.mk

stage::
	$(ECHO_NOTHING)rsync -a "$(FW_PROJECT_DIR)/localization/" "$(FW_STAGING_DIR)/Library/TaskToggle/" $(FW_RSYNC_EXCLUDES)$(ECHO_END)

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Commands
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Themes
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Toggles
	chmod ug+s $(THEOS_STAGING_DIR)/usr/libexec/tasktoggle/setuid
	chmod ug+s $(THEOS_STAGING_DIR)/usr/libexec/tasktoggle/toggle_dylib.sh
	- find $(THEOS_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;

endif