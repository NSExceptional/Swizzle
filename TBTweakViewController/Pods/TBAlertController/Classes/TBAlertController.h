//
//  TBAlertController.h
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TBAlertAction.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, TBAlertControllerStyle) {
    TBAlertControllerStyleActionSheet = 0,
    TBAlertControllerStyleAlert
};


@interface TBAlertController : NSObject

///------------------
/// @name Properties
///------------------

#pragma mark Properties

/** The style of the alert controller, representing action sheet style or alert view style. */
@property (nonatomic, readonly) TBAlertControllerStyle style;
/** Setting this property has the same effect on iOS 7 and 8 as \c UIAlertViewStyle does on \c UIAlertView.
 Any additional text views added manually are added after the text views added by the specified style, even if you add them before setting this property. */
@property (nonatomic          ) UIAlertViewStyle       alertViewStyle;
/** The title of the alert controller. */
@property (nonatomic, copy, nullable) NSString         *title;
/** The message of the alert controller. */
@property (nonatomic, copy, nullable) NSString         *message;
/** The reference view for UIPopoverViewController on iPad */
@property (nonatomic, assign, nullable) UIView         *popoverSourceView;
/** Defaults to \c NSNotFound. Values greater than the number of buttons are allowed but will be ignored and discarded. */
@property (nonatomic) NSInteger destructiveButtonIndex;
/** @return The number of "other buttons" added + the cancel button, if you added one. */
- (NSUInteger)numberOfButtons;
/** @return An array of \c TBAlertActions representing all "other button" actions and the cancel button action, if you added one. Gauranteed to never be \c nil. */
- (NSArray *)actions;

///--------------------
/// @name Initializers
///--------------------

#pragma mark Initializers

/** A convenience method for `initWithTitle:message:style:` where \c style is \c TBAlertControllerStyleAlert.
 @return A \c TBAlertController with no actions. */
+ (instancetype)alertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
/** A convenience method for `initWithTitle:message:style:` where \c style is \c TBAlertControllerStyleActionSheet.
 @return A \c TBAlertController with no actions. */
+ (instancetype)actionSheetWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
/** A convenience method for creating an alert view style alert controller with a single "OK" button.
 @return A \c TBAlertController with an "OK" button to dismiss it. */
+ (instancetype)simpleOKAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/** Initializer that creates a \c TBAlertController in the specified style with no actions, title, or message. */
- (id)initWithStyle:(TBAlertControllerStyle)style;
/** Initializer that creates a \c TBAlertController in the specified style with the given title and message. */
- (id)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message style:(TBAlertControllerStyle)style;


///-------------------------
/// @name The Cancel Button
///-------------------------

#pragma mark Cancel button

/** Adds a cancel button via a \c TBAlertAction. */
- (void)setCancelButton:(TBAlertAction *)button;
/** Adds an actionless cancel button with the given title. */
- (void)setCancelButtonWithTitle:(NSString *)title;
/** Adds a cancel button with a block to be executed when triggered.
 
 @param title The button title
 @param buttonBlock The \c TBAlertActionBlock to be executed when the button is triggered. */
- (void)setCancelButtonWithTitle:(NSString *)title buttonAction:(TBAlertActionBlock)buttonBlock;
/** Adds a cancel button with a target-selector style action to execute when triggered.
 
 @warning Both parameters are optional; however, it is required that both parameters are \c nil or neither are.
 
 @param title The button title
 @param target The object to perform the \c action selector on when the button is triggered.
 @param action A selector to perform on the \c target object when the button is triggered. */
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
/** Adds a cancel button with a target-selector style action which takes a single parameter to execute when triggered.
 
 @warning All three parameters are optional; however, however, it is required that both \c target and \c action are \c nil or neither are.
 @note If both \c target and \c action are \c nil, \c object is ignored.
 
 @param title The button title
 @param target The object to perform the \c action selector on when the button is triggered.
 @param action A selector to perform on the \c target object when the button is triggered.
 @param object An object to pass to \c action. Behavior is undefined for \c nil values. */
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object;
/** @warning This is a feature of \c UIAlertAction and is only available on iOS 8. */
- (void)setCancelButtonEnabled:(BOOL)enabled NS_AVAILABLE_IOS(8_0);
/** Removes the cancel button. */
- (void)removeCancelButton;

///---------------------
/// @name Other buttons
///---------------------

#pragma mark Other buttons

/** Adds a button via a \c TBAlertAction. */
- (void)addOtherButton:(TBAlertAction *)button;
/** Adds an actionless button with the given title. */
- (void)addOtherButtonWithTitle:(NSString *)title;
/** Adds a button with a block to be executed when triggered.
 
 @param title The button title.
 @param buttonBlock The \c TBAlertActionBlock to be executed when the button is triggered. */
- (void)addOtherButtonWithTitle:(NSString *)title buttonAction:(TBAlertActionBlock)buttonBlock;
/** Adds a button with a target-selector style action to execute when triggered.
 
 @warning Both parameters are optional; however, it is required that both parameters are \c nil or neither are.
 
 @param title The button title.
 @param target The object to perform the \c action selector on when the button is triggered.
 @param action A selector to perform on the \c target object when the button is triggered. */
- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
/** Adds a button with a target-selector style action which takes a single parameter to execute when triggered.
 
 @warning All three parameters are optional; however, however, it is required that both \c target and \c action are \c nil or neither are.
 @note If both \c target and \c action are \c nil, \c object is ignored.
 
 @param title The button title.
 @param target The object to perform the \c action selector on when the button is triggered.
 @param action A selector to perform on the \c target object when the button is triggered.
 @param object An object to pass to \c action. Behavior is undefined for \c nil values. */
- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(nullable id)object;
/** @note You can also use this to enable or disable the cancel button if you have one set.
 @warning This is a feature of UIAlertAction and is only available on iOS 8. */
- (void)setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)buttonIndex NS_AVAILABLE_IOS(8_0);
/** Removes a button.
 @note You can also use this to remove the cancel button if you have one set. */
- (void)removeButtonAtIndex:(NSUInteger)buttonIndex;

///-------------------
/// @name Text Fields
///-------------------

#pragma mark Text Fields

/** @see Equivalent to addTextFieldWithConfigurationHandler: on \c UIAlertController.
 
 @warning This is a feature of \c UIAlertController and only available on iOS 8.
 @note This will work in conjunction with the \c alertViewStyle property on iOS 8 (it is safe to set \c alertViewStyle and use this method).
 @note The text fields for the \c alertViewStyle property will always come out on top of any fields added here. */
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler NS_AVAILABLE_IOS(8_0);

///----------------------------------------------------
/// @name Displaying / dismissing the alert controller
///----------------------------------------------------

#pragma mark Displaying / dismissing the alert controller

/** Presents the alert controller from the given view controller.
 
 @note \c viewController has no effect on iOS 7 when using \c TBAlertControllerStyleAlert. Using \c TBAlertControllerStyleActionSheet, the action sheet is shown from `viewController.view.window`.
 
 @param viewController The view controller that should present the alert controller. */
- (void)showFromViewController:(UIViewController *)viewController;
/** Presents the alert controller from the given view controller.
 
 @note \c viewController has no effect on iOS 7 when using \c TBAlertControllerStyleAlert.
 @note When using \c TBAlertControllerStyleActionSheet, the action sheet is shown from `viewController.view.window`.
 @note \c animated has no effect on iOS 7.
 
 @param viewController The view controller that should present the alert controller.
 @param animated Whether or not to animate the presentation. This value is ignored on iOS 7.
 @param completion An optional block to execute when the alert controller has been presented. You may pass \c nil to this parameter. */
- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(nullable TBVoidBlock)completion;

/** Convenience method for programmatically dismissing the alert controller.
 
 @note On iOS 7, this dismisses the alert view or action sheet by clicking button index \c 0, even if none exists. The action for that button, if any, will be performed. No action is performed on iOS 8. */
- (void)dismiss;
/** Convenience method for programmatically dismissing the alert controller by trigger a specific button. The action, if any, will be performed.
 
 @param index The button index to trigger. It is always safe to pass \c 0 to this parameter.
 @note On iOS 7, passing \c 0 to \c index is equivalent to calling \c dismiss.
 @warning Behavior is undefied for values of \c index greater than or equal to \c numberOfButtons. */
- (void)dismissWithButtonIndex:(NSUInteger)index;
/** @see Equivalent to calling `dismissAnimated:completion` on \c UIAlertController.
 
 @warning This is a feature of \c UIAlertController and only available on iOS 8. */
- (void)dismissAnimated:(BOOL)animated completion:(nullable TBVoidBlock)completion NS_AVAILABLE_IOS(8_0);

NS_ASSUME_NONNULL_END

@end
