export TARGET = iphone:latest:latest
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Muta
Muta_FILES = Tweak.xm
#Muta_FRAMEWORKS = UIKit
#Muta_PRIVATE_FRAMEWORKS = ChatKit
#Muta_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-install::
	install.exec "killall -9 SpringBoard"
