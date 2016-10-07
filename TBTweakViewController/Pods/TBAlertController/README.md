TBAlertController
=================

[![Issues](https://img.shields.io/github/issues-raw/ThePantsThief/TBAlertController.svg?style=flat)](https://github.com/ThePantsThief/TBAlertController/issues)
[![Stars](https://img.shields.io/github/stars/ThePantsThief/TBAlertController.svg?style=flat)](https://github.com/ThePantsThief/TBAlertController/stargazers)
[![Version](https://img.shields.io/cocoapods/v/TBAlertController.svg?style=flat)](http://cocoadocs.org/docsets/TBAlertController)
[![License](https://img.shields.io/cocoapods/l/TBAlertController.svg?style=flat)](http://cocoadocs.org/docsets/TBAlertController)
[![Platform](https://img.shields.io/cocoapods/p/TBAlertController.svg?style=flat)](http://cocoadocs.org/docsets/TBAlertController)

`UIAlertController`, `UIAlertView`, and `UIActionSheet` unified for developers who want to support iOS 7, 8, and 9.

Installation:
=============
Cocoapods
- Add `pod 'TBAlertController' to your podfile, then run `pod install`.

Manual installation
- Clone this repo
- Add `TBAlertController.h`, `TBAlertController.m`, `TBAlertAction.h`, and `TBAlertAction.m` to your project
- Import `TBAlertController.h`, and optionally `TBAlertAction.h` if you plan to use it.

About
=====
`TBAlertController` tries to be as much of a drop-in replacement for the iOS 7 classes as possible, and adds a simpler interface for iOS 8 by allowing you to directly add buttons instead of first creating action objects. This feature is coming soon, however, to remain consitent with `UIAlertController`'s interface.

The only major difference for iOS 7 is that `TBAlertController` does away with delegates in favor of block and target-selector style actions. Delegate support will not be added, since this project is directed at developers who want to minimize code involving action sheets and alert views on iOS 7 and 8. It is possible to use the same code for both platforms; `TBAlertController` takes care of the rest for you.

Features
========
- No more delegates! And no more iOS 7 / 8 / 9 conditional code. One alert to rule them all...
- Allows for reusable methods thanks to the target-selector style button actions, which usually fit on a single line.
- Tries to be as much of a drop-in replacement for the iOS 8 API as possible. The method signatures are different but work as expected.
- Supports adding text fields using `UIAlertViewStyle` for iOS 7 and 8, and `addTextFieldWithConfigurationHandler:` for iOS 8.
- Add buttons directly using any of the `addOtherButtonWithTitle...` methods, or by creating a `TBAlertAction` and adding that. Adding actions directly allows for slimmer code, while creating and adding `TBAlertAction`s works similar to how `UIAlertController` adds buttons.

Examples
========
``` obj-c

TBAlertController *alert = [[TBAlertController alloc] initWithStyle:TBAlertControllerStyleActionSheet];
alert.title   = @"Alert";
alert.message = @"This is a message!";
[alert addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *strings) { [self pressedOK]; }];
[alert addOtherButtonWithTitle:@"Delete" target:self action:@selector(selfDestruct)];
[alert setCancelButtonWithTitle:@"Cancel"];
alert.destructiveButtonIndex = 1;
```

This will create an action sheet with the title `Alert` and a message, as well as three buttons: `OK` with a block style action, `Delete` with a target-selector style action (as well as being the "destructive" button), and a `Cancel` button which only dismisses the alert. The cancel button will always appear last in the list of buttons if set using one of the `setCancelButton...` methods.

Display an alert with `showFromViewController:` or `showFromViewController:animated:completion:`.

Actions can be added to any button, either block or target-selector style. Destructive buttons can only be added when using `TBAlertControllerStyleActionSheet` on iOS 7. Buttons can also be added with just a title.

The target-selector style actions also support passing a single parameter, like `performSelector:withObject:`.

``` obj-c

TBAlertController *alert = [[TBAlertController alloc] initWithTitle:@"Title"
                                                            message:@"Hello world"
                                                              style:TBAlertControllerStyleActionSheet];
[alert addOtherButtonWithTitle:@"Dismiss"];
[alert addOtherButtonWithTitle:@"Say hi" target:self action:@selector(say:) withObject:@"hi"];
```

You can also add text fields when using the alert view style. iOS 7 only supports adding text fields using `UIAlertViewStyle`, while iOS 8 can add text fields using `UIAlertViewStyle` or via `addTextFieldWithConfigurationHandler:`. Text from all text fields are passed to button action blocks in an array. To add predefined text fields with `UIAlertViewStyle`, set the `alertViewStyle` property (defaults to `UIAlertViewStyleDefault` which has no effect). On iOS 8, you can make use of the `alertViewStyle` property simultaneously with `addTextFieldWithConfigurationHandler:`; text fields added by the `alertViewStyle` property will always appear at the top of the alert.

``` obj-c

TBAlertController *alert = [[TBAlertController alloc] initWithStyle:TBAlertControllerStyleAlertView];
[alert addOtherButtonWithTitle:@"Log input" buttonAction:^(NSArray *strings) {
            NSString *first  = strings[0];
            NSString *second = strings[1];
            NSLog(@"%@ %@", first, second);
}];
// iOS 8 only
[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"This will appear as the second text box";
}];
// iOS 7 and 8
alert.alertViewStyle = UIAlertViewStylePlainTextInput;
```
Gotchas
=======
The following will throw exceptions:
- Calling any method only available in iOS 8, indicated by `NS_AVAILABLE_IOS(8_0)`, including `addTextFieldWithConfigurationHandler`.
- Adding a text field when using `TBAlertControllerStyleActionSheet` and `setButtonEnabled:atIndex:`.
- Setting `destructiveButtonIndex` when using the alert view style on iOS 7 (since iOS 7 doesn't support this).
- Passing `nil` for any of the folliwing: title, target, action, or a block for `buttonAction:`. You may pass `nil` to the `object` parameter of `addOtherButtonWithTitle:target:action:withObject:`, as it will call just call the parent method which takes no `object` parameter.

License
=======
MIT license. See LICENSE file for more details.
