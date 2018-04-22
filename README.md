# Swizzle
An extensible tweak to create simple tweaks for any app, from within any app.

### System-wide tweak functionality is not yet implemetned.

## For users

Trigger the FLEXing window. Click on the `TWEAK` button to present the Swizzle window. There are two tabs: local, and system. Local tweaks apply to the current app ONLY, and system tweaks apply to any app where the target class is found, including SpringBoard.

A "tweak" is comprised of one or more "hooks." Tap the + button to create a tweak. Swizzle will ask for a name. Tweaks can be toggled on or off. Select a tweak to give it some hooks. You can swipe to delete hooks. 

Tap the + button to add some hooks. This will present a new screen with a list of open bundles. Once you select a bundle, you must select a class, then a method. Once you have a method selected, you can configure and save the hook.

Bundles are things like the app binary itself, UIKit, MapKit, etc. Bundles hold different classes. Selecting a bundle reveals all classes it holds. Selecting a class reveals all methods it implements and inherits. Selecting an inherited method will **add** an implementation in the selected class.

You can type to filter any of the lists mentioned above, using the format `bundle.class.[-+]method`, where `bundle` is a bundle name, `class` is a class name, and `[-+]method` is a method name, such as `-count` or `+imageNamed:`. You can filter the lists with wildcards. Some examples:

- `UI*` would reveal all bundles whose names start with `UI`.
- `Snapchat.*` would reveal all classes in the Snapchat binary if you were in the Snapchat app.
- `Snapchat.*.-` would reveal all instance methods of every class in the Snapchat app binary.
- `Snapchat.*.*` would reveal *all* methods of every class in the Snapchat app binary (as would simply `Snapchat.*.`). 
- `*Kit\.framework.*view` would reveal all classes containing the word `view` in bundles whose names end with `Kit.framework`, such as `UIKit\.framework` or `MapKit\.framework`.
- `*.*.` and `*.*.*` reveal every single method in the current runtime. This level of detail might take a while to gather...

The `\.` escape is needed in some bundle names to prevent interpreting `MapKit\.framework` as `bundle=MapKit, class=framework`.

### Developers:

Installing Swizzle as a tweak is straightforward if you already have the Xcode project building. Just do `make package install` like usual.

The Xcode project has a podfile that relies on MirrorKit. In the podfile, change `pod 'MirrorKit', :path => '../../../MirrorKit'` to `pod 'MirrorKit', :git => 'https://github.com/NSExceptional/MirrorKit.git`, then run `pod install` from Terminal in the same directory as the podfile. The Xcode project builds an app that you can use to test Swizzle without being jailbroken or needing Theos to install.

DM me on Twitter or chat me on Reddit (chat, not DM) with any questions! @NSExceptional, /u/ThePantsThief.

# TODO

- [ ] System-wide tweak functionality.
- [ ] Online documentation (help wanted)
- [ ] Tweak preferences should be stored outside of app container (so that deleting an app does not delete your tweaks)
- [ ] Disallow deleting hooks from tweaks that are turned on
- [ ] Fix crashes and other performance issues in the "hook chooser" screen, specifically related to performing complex, large queries like `*.*view.*` or tapping on a result from a previous query before the current query finishes loading.
- [ ] Make value hooks more modular to allow third party extensions
