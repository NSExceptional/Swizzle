//
//  MKPrivate.m
//  Pods
//
//  Created by Tanner on 3/25/17.
//
//

#import "MKPrivate.h"

static Class * _UnsafeClasses = NULL;

Class * MKKnownUnsafeClasses() {
    if (!_UnsafeClasses) {
        Class ignored[] = {
            NSClassFromString(@"_NSZombie_"),
            NSClassFromString(@"__ARCLite__"),
            NSClassFromString(@"__NSCFCalendar"),
            NSClassFromString(@"__NSCFTimer"),
            NSClassFromString(@"NSCFTimer"),
            NSClassFromString(@"__NSGenericDeallocHandler"),
            NSClassFromString(@"NSAutoreleasePool"),
            NSClassFromString(@"NSPlaceholderNumber"),
            NSClassFromString(@"NSPlaceholderString"),
            NSClassFromString(@"NSPlaceholderValue"),
            NSClassFromString(@"Object"),
            NSClassFromString(@"VMUArchitecture"),
            NSClassFromString(@"Object"),
            NSClassFromString(@"JSExport"),
            NSClassFromString(@"__NSAtom"),
            NSClassFromString(@"_NSZombie_"),
            NSClassFromString(@"__NSMessage"),
            NSClassFromString(@"__NSMessageBuilder")
        };

        _UnsafeClasses = (Class *)malloc(sizeof(ignored));
        memcpy(_UnsafeClasses, ignored, sizeof(ignored));
    }

    return _UnsafeClasses;
}
