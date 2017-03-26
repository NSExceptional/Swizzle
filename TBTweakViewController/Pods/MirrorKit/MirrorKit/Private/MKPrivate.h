//
//  MKPrivate.h
//  Pods
//
//  Created by Tanner on 3/25/17.
//
//

#import <Foundation/Foundation.h>

extern Class * MKKnownUnsafeClasses();

static inline BOOL MKClassIsSafe(Class cls) {
    Class * ignored = MKKnownUnsafeClasses();
    for (NSInteger x = 0; x < sizeof(ignored); x++) {
        if (cls == ignored[x]) {
            return NO;
        }
    }

    return YES;
}
