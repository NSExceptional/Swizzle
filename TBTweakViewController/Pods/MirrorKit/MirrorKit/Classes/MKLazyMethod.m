//
//  MKLazyMethod.m
//  Pods
//
//  Created by Tanner on 3/25/17.
//
//

#import "MKLazyMethod.h"

@implementation MKLazyMethod

#pragma mark Initialization

- (id)initWithMethod:(Method)method class:(Class)cls isInstanceMethod:(BOOL)isInstanceMethod {
    NSParameterAssert(method);

    if (self) {
        _objc_method      = method;
        _targetClass      = cls;
        _isInstanceMethod = isInstanceMethod;
        @try {
            _signatureString = @(method_getTypeEncoding(method));
            _signature = [NSMethodSignature signatureWithObjCTypes:_signatureString.UTF8String];
        } @catch (id exception) {
            return nil;
        }
    }

    return self;
}

#pragma mark Lazy property overrides

- (SEL)selector {
    if (!_selector) {
        _selector = method_getName(_objc_method);
    }

    return _selector;
}

- (NSString *)selectorString {
    if (!_selectorString) {
        _selectorString = NSStringFromSelector(self.selector);
    }

    return _selectorString;
}

- (NSString *)typeEncoding {
    if (!_typeEncoding) {
        _typeEncoding = [_signatureString stringByReplacingOccurrencesOfString:@"[0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, _signatureString.length)];
    }

    return _typeEncoding;
}

- (IMP)implementation {
    if (!_implementation) {
        _implementation = method_getImplementation(_objc_method);
    }

    return _implementation;
}

- (NSUInteger)numberOfArguments {
    if (!_numberOfArguments) {
        _numberOfArguments = method_getNumberOfArguments(_objc_method);
    }

    return _numberOfArguments;
}

- (MKTypeEncoding)returnType {
    if (!_returnType) {
        _returnType = (MKTypeEncoding)[_signatureString characterAtIndex:0];
    }

    return _returnType;
}

- (NSString *)fullName {
    if (!_fullName) {
        _fullName = [self debugNameGivenClassName:NSStringFromClass(_targetClass)];
    }

    return _fullName;
}

@end
