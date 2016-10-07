export TARGET = iphone:latest:latest
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Swizzle
Muta_FILES = Tweak.xm
#Swizzle_FRAMEWORKS = UIKit
#Swizzle_PRIVATE_FRAMEWORKS = ChatKit
#Swizzle_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-install::
	install.exec "killall -9 SpringBoard"
