# MirrorKit

[![CI Status](http://img.shields.io/travis/ThePantsThief/MirrorKit.svg?style=flat)](https://travis-ci.org/ThePantsThief/MirrorKit)
[![Version](https://img.shields.io/cocoapods/v/MirrorKit.svg?style=flat)](http://cocoapods.org/pods/MirrorKit)
[![License](https://img.shields.io/cocoapods/l/MirrorKit.svg?style=flat)](http://cocoapods.org/pods/MirrorKit)
[![Platform](https://img.shields.io/cocoapods/p/MirrorKit.svg?style=flat)](http://cocoapods.org/pods/MirrorKit)

Inspired by Swift's MirrorType and [MAObjcRuntime](https://github.com/mikeash/MAObjCRuntime), this framework aims to simplify working with the Objective-C runtime and offer a simple way to reflect classes and objects.

## Installation

MirrorKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MirrorKit"
```

# Usage

Documentation for MirrorKit is on [Cocoadocs](http://cocoadocs.org/docsets/MirrorKit/1.0.0/Classes/MKMirror.html).

``` objc
#import "MirrorKit.h"
...

XZYObject *foo = [[XZYObject alloc] initWithBar:bar];
MKMirror *reflection = [MKMirror reflect:foo]; // works for classes too

// Get a list of foo's properties, retrieve information about a property
NSArray *properties = reflection.properties;
MKProperty *property = properties.firstObject;
NSString *propertyName = property.name;
BOOL readwrite = !property.isReadOnly;

// Discover all loaded subclasses of any class!
NSArray *subclasses = [NSDictionary allSubclasses];
NSLog(subclasses); // 20+ classes... wow
```

Here's where the real fun begins. Let's create a class at runtime:

``` objc
// Start here by naming it. Your class will implicitly inherit from NSObject.
MKClassBuilder *builder = [MKClassBuilder allocateClass:@"NSAtom"];

// Create and add IVars...
MKIVarBuilder *nameIvar name:@"_name" size:sizeof(id) alignment:log2(sizeof(id)) typeEncoding:@(@encode(id))];
MKIVarBuilder *lengthIvar = [MKIVarBuilder name:@"_length" size:sizeof(NSUInteger) alignment:log2(sizeof(NSUInteger)) typeEncoding:@(@encode(NSUInteger))];
[builder addIVars:@[nameIvar, lengthIvar]];

// Create some methods...
NSString *initTypes  = [NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)];
NSString *fooTypes   = [NSString stringWithFormat:@"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(id)];
MKSimpleMethod *init = [MKSimpleMethod buildMethodNamed:@"init" withTypes:initTypes implementation:imp_implementationWithBlock(^(id self) {
self = [super init];
if (self) {
NSUInteger len = 5;
[self setIVarByName:lengthIvar.name value:&len size:sizeof(len)];
[self setIVarByName:nameIvar.name object:@"ThePantsThief"];
NSLog(@"Called init");
}
return self;
})];
MKSimpleMethod *fooMethod = [MKSimpleMethod buildMethodNamed:@"foo:" withTypes:fooTypes implementation:imp_implementationWithBlock(^(id self, id someObject) {
NSLog(@"-[%@ foo:] %lu: %@", NSStringFromClass([self class]), [self length], [self name], [someObject description]);
})];

// Create some property attributes, using either MKMutablePropertyAttributes or a dictionary to create an MKPropertyAttributes object
MKMutablePropertyAttributes *nameAttributes = [MKMutablePropertyAttributes attributes];
nameAttributes.isReadOnly  = YES;
nameAttributes.backingIVar = nameIvar.name;
[nameAttributes setTypeEncodingChar:MKTypeEncodingObjcObject];
NSDictionary *lengthAttributesDict = @{MKPropertyAttributeKeyNonAtomic:       @YES,
MKPropertyAttributeKeyTypeEncoding:    [NSString stringWithFormat:@"%c", (char)MKTypeEncodingUnsignedLongLong],
MKPropertyAttributeKeyBackingIVarName: lengthIvar.name};
MKPropertyAttributes *lengthAttributes = [MKPropertyAttributes attributesFromDictionary:lengthAttributesDict];

// Initialize some properties with those attributes...
MKProperty *nameProperty   = [MKProperty propertyWithName:@"name" attributes:nameAttributes];
MKProperty *lengthProperty = [MKProperty propertyWithName:@"length" attributes:lengthAttributes];
// Properties need getters and setters! These aren't too straightforward, sadly.
// Casting is necessary. These macros make it kinda simple.
MKSimpleMethod *getName   = MKPropertyGetter(pName, id __strong);
MKSimpleMethod *getLength = MKPropertyGetter(pLength, NSUInteger);
MKSimpleMethod *setLength = MKPropertySetter(pLength, NSUInteger);

// Add the methods, and properties
[builder addMethods:@[init, fooMethod, getName, getLength, setLength]];
[builder addProperties:@[nameProperty, lengthProperty]];

// Register the class and create an instance of it!
Class myClass = [builder registerClass];
id myAtom     = [myClass new];
```

# To-do

- Finish testing
- Add OS X demo

## Author

Tanner Bennett, tannerbennett@me.com

## License

MirrorKit is available under the MIT license. See the LICENSE file for more info.
