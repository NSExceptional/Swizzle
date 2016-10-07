//
//  TBAlertController.m
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//
//

#import "TBAlertController.h"

#if ! __has_feature(objc_arc)
#error This file requires ARC! Add "-fobjc-arc" in Build Phases -> Compile Sources -> Compiler Flags.
#endif

#pragma mark - TBAlertView - DO NOT USE
#pragma mark Created to use itself as the delegate for iOS 7 and earlier.


@protocol TBPresentable <NSObject>
@property (nonatomic) NSString *title;
@optional
@property (nonatomic) NSString *message;
@end

@protocol TBAlert <NSObject>

- (NSMutableArray *)textFieldInputStrings;
- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
// AlertView
@interface TBAlertView : UIAlertView <UIAlertViewDelegate>
@property (nonatomic) id<TBAlert> controller;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller;
@end
@implementation TBAlertView
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
        self.title      = title;
        self.message    = message;
        self.delegate   = self;
    }
    
    return self;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (self.alertViewStyle) {
        case UIAlertViewStyleLoginAndPasswordInput:
            [self.controller.textFieldInputStrings addObject:[self textFieldAtIndex:1].text];
        case UIAlertViewStylePlainTextInput:
        case UIAlertViewStyleSecureTextInput:
            [self.controller.textFieldInputStrings addObject:[self textFieldAtIndex:0].text];
            break;
            
        case UIAlertViewStyleDefault:
            break;
    }
    
    [self.controller didDismissWithButtonIndex:buttonIndex];
}

@end

#pragma mark - TBAlertView - DO NOT USE
#pragma mark Created to use itself as the delegate for iOS 7 and earlier.

// ActionSheet
@interface TBActionSheet : UIActionSheet <UIActionSheetDelegate>
@property (nonatomic) id<TBAlert> controller;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller;
@end
@implementation TBActionSheet
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
        self.delegate   = self;
        if (message)
            self.title  = [NSString stringWithFormat:@"%@\n\n%@", title, message];
        else
            self.title  = title;
    }
    
    return self;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.controller didDismissWithButtonIndex:buttonIndex];
}
@end

#pragma mark - TBAlertController

@interface TBAlertController () <TBAlert>

@property (nonatomic      ) id                inCaseOfManualDismissal;
@property (nonatomic      ) TBAlertAction     *cancelAction;
@property (nonatomic      ) NSMutableArray    *buttons;
@property (nonatomic      ) NSMutableArray    *textFieldHandlers;
@property (nonatomic, weak) id<TBPresentable> currentPresentation;
@property (nonatomic, copy) void              (^completion)();
/** An array of \c NSStrings containing the text in each of the alert controller's text views *after* it has been dismissed.
 This array is passed to each \c TBAlertActionBlock, so it is only necessary to access this property if you for some reason need to keep it around for later use. */
@property (nonatomic) NSMutableArray *textFieldInputStrings;

@end

@implementation TBAlertController

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message {
    return [[TBAlertController alloc] initWithTitle:title message:message style:TBAlertControllerStyleAlert];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title message:(NSString *)message {
    return [[TBAlertController alloc] initWithTitle:title message:message style:TBAlertControllerStyleActionSheet];
}

+ (instancetype)simpleOKAlertWithTitle:(NSString *)title message:(NSString *)message {
    TBAlertController *alert = [TBAlertController alertViewWithTitle:title message:message];
    [alert addOtherButtonWithTitle:@"OK"];
    return alert;
}

- (instancetype)initWithStyle:(TBAlertControllerStyle)style {
    self = [super init];
    if (self) {
        _style = style;
        _buttons = [NSMutableArray new];
        _textFieldHandlers = [NSMutableArray new];
        _textFieldInputStrings = [NSMutableArray new];
        _destructiveButtonIndex = NSNotFound;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(TBAlertControllerStyle)style {
    self = [self initWithStyle:style];
    if (self) {
        self.title   = title;
        self.message = message;
    }
    
    return self;
}

- (NSUInteger)numberOfButtons {
    if (self.cancelAction)
        return [self.buttons count] + 1;
    
    return [self.buttons count];
}

- (NSArray *)actions {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.buttons];
    
    if (self.cancelAction)
        [temp addObject:self.cancelAction];
    
    return [temp copy];
}

#pragma mark Updatable properties

- (void)setTitle:(NSString *)title {
    _title = title;
    if (self.currentPresentation) {
        self.currentPresentation.title = title;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (self.currentPresentation) {
        if ([self.currentPresentation respondsToSelector:@selector(setMessage:)]) {
            self.currentPresentation.message = message;
        }
    }
}

#pragma mark Cancel button

- (void)setCancelButton:(TBAlertAction *)button {
    self.cancelAction = button;
}

- (void)setCancelButtonWithTitle:(NSString *)title {
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title];
}

- (void)setCancelButtonWithTitle:(NSString *)title buttonAction:(TBAlertActionBlock)buttonBlock {
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title block:buttonBlock];
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title target:target action:action];
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object {
    NSParameterAssert(object);
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title target:target action:action object:object];
}

- (void)setCancelButtonEnabled:(BOOL)enabled {
    NSAssert([UIAlertController class], @"Buttons can only be disabled on iOS 8.");
    NSAssert(self.cancelAction, @"Cancel button was never set, cannot enable or disable it.");
    self.cancelAction.enabled = enabled;
}

- (void)removeCancelButton {
    self.cancelAction = nil;
}

#pragma mark Destructive button

- (void)setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex {
    if (![UIAlertController class])
        NSAssert(self.style == TBAlertControllerStyleActionSheet, @"Only alert contorllers of style TBAlertControllerStyleActionSheet can have destructive buttons on iOS 7.");
    
    _destructiveButtonIndex = destructiveButtonIndex;
}

#pragma mark Other buttons

- (void)addOtherButton:(TBAlertAction *)button {
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title {
    NSParameterAssert(title);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title];
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title target:target action:action];
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object {
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title target:target action:action object:object];
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title buttonAction:(void(^)(NSArray *textFieldStrings))buttonBlock {
    NSParameterAssert(title); NSParameterAssert(buttonBlock);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title block:buttonBlock];
    [self.buttons addObject:button];
}

- (void)setButtonEnabled:(BOOL)enabled atIndex:(NSUInteger)buttonIndex {
    NSAssert([UIAlertController class], @"Buttons can only be disabled on iOS 8.");
    
    // Cancel button
    if (buttonIndex == [self.buttons count]) {
        NSAssert(self.cancelAction, @"Invalid button index; out of bounds.");
        self.cancelAction.enabled = enabled;
    }
    else
        [self.buttons[buttonIndex] setEnabled:enabled];
}

- (void)removeButtonAtIndex:(NSUInteger)buttonIndex {
    if (buttonIndex == self.buttons.count) {
        NSAssert(self.cancelAction, @"Invalid button index; out of bounds.");
        [self removeCancelButton];
    }
    else {
        [self.buttons removeObjectAtIndex:buttonIndex];
    }
}

#pragma mark Text fields

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    NSAssert([UIAlertController class], @"Adding individual text fields is only supported on iOS 8. Use alertViewStyle instead.");
    NSParameterAssert(configurationHandler);
    NSAssert(self.style == TBAlertControllerStyleAlert,
             @"Text fields can only be added to alert controllers of style TBAlertControllerStyleAlert.");
    
    [self.textFieldHandlers addObject:configurationHandler];
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle {
    NSAssert(self.style == TBAlertControllerStyleAlert,
             @"Text fields can only be added to alert controllers of style TBAlertControllerStyleAlert.");
    
    _alertViewStyle = alertViewStyle;
}

- (void)getTextFromTextFields:(NSArray *)textFields {
    for (UITextField *textField in textFields)
        [self.textFieldInputStrings addObject:textField.text];
}

#pragma mark Displaying (iOS 8)

- (void)showFromViewController:(UIViewController *)viewController {
    [self showFromViewController:viewController animated:YES completion:nil];
}

- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(TBVoidBlock)completion {
    // iOS 8+
    if ([UIAlertController class]) {
        NSUInteger i = 0;
        NSMutableArray *actions = [NSMutableArray new];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:(UIAlertControllerStyle)self.style];
        self.inCaseOfManualDismissal = alertController;
        
        // Add text fields
        switch (self.alertViewStyle) {
                
            case UIAlertViewStyleLoginAndPasswordInput: { // Login
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = @"Login";
                }];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = @"Password";
                    textField.secureTextEntry = YES;
                }];
                break;
            }
            case UIAlertViewStylePlainTextInput: { // Plaintext
                [alertController addTextFieldWithConfigurationHandler:nil];
                break;
            }
            case UIAlertViewStyleSecureTextInput: { // Secure text
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.secureTextEntry = YES;
                }];
                break;
            }
            case UIAlertViewStyleDefault:;
        }
        
        for (id handler in self.textFieldHandlers)
            [alertController addTextFieldWithConfigurationHandler:handler];
        
        
        // "Other button" actions
        for (TBAlertAction *button in self.buttons) {
            UIAlertActionStyle style = (i == self.destructiveButtonIndex) ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
            [actions addObject:[self actionFromAlertAction:button withStyle:style controller:alertController]];
            i++;
        }
        // Cancel action
        if (self.cancelAction) {
            [actions addObject:[self actionFromAlertAction:self.cancelAction withStyle:UIAlertActionStyleCancel controller:alertController]];
        }
        
        // Add actions to alert controller
        for (UIAlertAction *action in actions)
            [alertController addAction:action];
        
        if( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
        {
            UIPopoverPresentationController *popPresentation = [alertController popoverPresentationController];
            popPresentation.sourceView = self.popoverSourceView ? self.popoverSourceView : viewController.view;
        }
        
        self.currentPresentation = (id)alertController;
        [viewController presentViewController:alertController animated:animated completion:completion];
        
    }
    // iOS 7 or earlier
    else {
        self.completion = [completion copy];
        
        // Alert view
        if (self.style == TBAlertControllerStyleAlert)
            [self show];
        
        // Action sheet
        else if (self.style == TBAlertControllerStyleActionSheet)
            [self showInView:[viewController.view window]];
    }
}

#pragma mark Displaying (iOS 7)

- (void)show {
    NSAssert(self.style == TBAlertControllerStyleAlert,
             @"You can only call \"show\" on an alert controller of style TBAlertControllerStyleAlert. \"show\" is also depricated on iOS 8.");
    
    TBAlertView *alert = [[TBAlertView alloc] initWithTitle:self.title message:self.message controller:self];
    self.inCaseOfManualDismissal = alert;
    
    // Add buttons
    for (TBAlertAction *button in self.buttons) {
        NSString *title = button.title;
        [alert addButtonWithTitle:title];
    }
    // Add cancel button
    if (self.cancelAction) {
        [alert addButtonWithTitle:self.cancelAction.title];
        [alert setCancelButtonIndex:alert.numberOfButtons-1];
    }
    
    // Text views
    alert.alertViewStyle = self.alertViewStyle;
    
    self.currentPresentation = (id)alert;
    [alert show];
    
    // Completion block
    if (self.completion)
        self.completion();
}

- (void)showInView:(UIView *)view {
    NSAssert(self.style == TBAlertControllerStyleActionSheet,
             @"You can only call \"showInView:\" on an alert controller of style TBAlertControllerStyleActionSheet. \"showInView:\" is also depricated on iOS 8.");
    
    TBActionSheet *actionSheet = [[TBActionSheet alloc] initWithTitle:self.title message:self.message controller:self];
    self.inCaseOfManualDismissal = actionSheet;
    
    // Add buttons
    for (TBAlertAction *button in self.buttons) {
        NSString *title = button.title;
        [actionSheet addButtonWithTitle:title];
    }
    // Cancel button
    if (self.cancelAction) {
        [actionSheet addButtonWithTitle:self.cancelAction.title];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    }
    // Destructive button index
    if (self.destructiveButtonIndex > -1)
        actionSheet.destructiveButtonIndex = self.destructiveButtonIndex;
    
    // show
    self.currentPresentation = (id)actionSheet;
    [actionSheet showInView:view];
    
    // Completion block
    if (self.completion)
        self.completion();
}

#pragma mark Dismissing

- (void)dismiss {
    self.currentPresentation = nil;
    
    if ([UIAlertController class]) {
        [self getTextFromTextFields:[(UIAlertController *)self.inCaseOfManualDismissal textFields]];
        [(UIAlertController *)self.inCaseOfManualDismissal dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissWithButtonIndex:0];
    }
}

- (void)dismissWithButtonIndex:(NSUInteger)index {
    self.currentPresentation = nil;
    
    // Button 0 with no actions defaults to [self dismiss]
    if (index == 0 && self.buttons.count == 0) {
        [self dismiss];
        return;
    }
    
    if ([UIAlertController class]) {
        TBAlertAction *action = self.actions[index];
        [self dismiss];
        if (action.enabled)
            [action perform:[self.textFieldInputStrings copy]];
    }
    else {
        switch (self.style) {
            case TBAlertControllerStyleActionSheet: {
                [(UIActionSheet *)self.inCaseOfManualDismissal dismissWithClickedButtonIndex:index animated:YES];
                break;
            }
            case TBAlertControllerStyleAlert: {
                [(UIAlertView *)self.inCaseOfManualDismissal dismissWithClickedButtonIndex:index animated:YES];
                break;
            }
        }
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(TBVoidBlock)completion {
    NSAssert([UIAlertController class], @"This method is only available on iOS 8.");
    self.currentPresentation = nil;
    [(UIAlertController *)self.inCaseOfManualDismissal dismissViewControllerAnimated:animated completion:completion];
}

#pragma mark Button actions (iOS 7)

- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.currentPresentation = nil;
    TBAlertAction *button = [self buttonAtIndex:buttonIndex];
    [button perform:self.textFieldInputStrings.copy];
}

- (TBAlertAction *)buttonAtIndex:(NSUInteger)buttonIndex {
    // Cancel button
    if (buttonIndex == self.buttons.count) {
        NSAssert(self.cancelAction, @"Invalid button index; out of bounds.");
        return self.cancelAction;
    }
    
    return self.buttons[buttonIndex];
}

#pragma mark UIAlertAction convenience (kinda wanna make this a category, can't because they call getTextFromTextFields)

- (UIAlertAction *)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style target:(id)target selector:(SEL)selector controller:(UIAlertController *)controller {
    __weak id weakTarget = target;
    
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        
        if (controller.textFields.count > 0)
            [self getTextFromTextFields:controller.textFields];
        
        if ([weakTarget respondsToSelector:selector])
            func(weakTarget, selector);
    }];
    
    return action;
}

- (UIAlertAction *)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style target:(id)target selector:(SEL)selector object:(id)object controller:(UIAlertController *)controller {
    __weak id weakTarget = target;
    __weak id weakObject = object;
    
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL, id) = (void *)imp;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *aciton) {
        
        if (controller.textFields.count > 0)
            [self getTextFromTextFields:controller.textFields];
        
        if ([weakTarget respondsToSelector:selector])
            func(weakTarget, selector, weakObject);
    }];
    
    return action;
}

- (UIAlertAction *)actionFromAlertAction:(TBAlertAction *)button withStyle:(UIAlertActionStyle)style controller:(UIAlertController *)controller {
    UIAlertAction *action;
    
    switch (button.style) {
        case TBAlertActionStyleNoAction:
        case TBAlertActionStyleBlock: {
            action = [UIAlertAction actionWithTitle:button.title style:style handler:^(UIAlertAction *alertAction) {
                [self getTextFromTextFields:controller.textFields];
                [button perform:[self.textFieldInputStrings copy]];
            }];
        }
            break;
            
        case TBAlertActionStyleTargetObject:
        case TBAlertActionStyleTarget: {
            
            // With object
            if (button.object)
                action = [self actionWithTitle:button.title
                                         style:style
                                        target:button.target
                                      selector:button.action
                                        object:button.object
                                    controller:controller];
            // Without object
            else
                action = [self actionWithTitle:button.title
                                         style:style
                                        target:button.target
                                      selector:button.action
                                    controller:controller];
            
        }
            break;
    }
    
    action.enabled = button.enabled;
    return action;
}

@end


