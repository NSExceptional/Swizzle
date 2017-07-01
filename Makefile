export TARGET = iphone:10.3:9.0
export ARCHS = arm64
include $(THEOS)/makefiles/common.mk

# Relevant folders
PROJECT_SRC = TBTweakViewController/TBTweakViewController/Classes
PODS_ROOT = TBTweakViewController/Pods
MK_DIR = /Users/tanner/Repos/MirrorKit/MirrorKit

# Swizzle sources and all dependency sources
MY_SOURCES =     $(wildcard $(PROJECT_SRC)/*.m)
MY_SOURCES +=    $(wildcard $(PROJECT_SRC)/*.S)
EXT_DEPENDS =    $(wildcard $(PODS_ROOT)/Masonry/Masonry/*.m)
EXT_DEPENDS +=   $(wildcard $(PODS_ROOT)/TBAlertController/Classes/*.m)
LOCAL_DEPENDS =  $(wildcard $(MK_DIR)/*.m)
LOCAL_DEPENDS += $(wildcard $(MK_DIR)/Classes/*.m)
LOCAL_DEPENDS += $(wildcard $(MK_DIR)/Categories/*.m)
LOCAL_DEPENDS += $(wildcard $(MK_DIR)/Private/*.m)

# Misc flags
INCLUDES =  -I$(PODS_ROOT)/Headers/Public
INCLUDES += -I$(PODS_ROOT)/Headers/Public/MirrorKit
INCLUDES += -I$(PROJECT_SRC)
IGNORED_WARNINGS =  -Wno-missing-braces -Wno-ambiguous-macro
IGNORED_WARNINGS += -Wno-objc-property-no-attribute -Wno-\#warnings
IGNORED_WARNINGS += -Wno-unused-command-line-argument -Wno-deprecated-declarations
POORLY_EMITTED_WARNINGS = -Wno-incomplete-implementation -Wno-incompatible-pointer-types

TWEAK_NAME = Swizzle
Swizzle_FILES = $(MY_SOURCES) $(EXT_DEPENDS) $(LOCAL_DEPENDS) Tweak.xm
Swizzle_FRAMEWORKS = UIKit
Swizzle_CFLAGS += $(INCLUDES) $(IGNORED_WARNINGS) -fobjc-arc
Swizzle_CFLAGS += $(POORLY_EMITTED_WARNINGS)

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-install::
	install.exec "killall -9 SpringBoard"


print-%  : ; @echo $* = $($*)
