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
TGPrefs_PRIVATE_FRAMEWORKS = Preferences
TGPrefs_LDFLAGS = $(FW_OBJ_DIR)/TaskToggle.dylib

include theos/makefiles/common.mk
include theos/makefiles/tweak.mk
include theos/makefiles/bundle.mk

stage::
	$(ECHO_NOTHING)rsync -a "$(FW_PROJECT_DIR)/localization/" "$(FW_STAGING_DIR)/Library/TaskToggle/" $(FW_RSYNC_EXCLUDES)$(ECHO_END)

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Commands
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Themes
	mkdir -p $(THEOS_STAGING_DIR)/Library/TaskToggle/Toggles
	- find $(THEOS_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;