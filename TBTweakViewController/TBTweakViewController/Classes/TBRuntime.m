//
//  TBRuntime.m
//  TBTweakViewController
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBRuntime.h"
#import "Categories.h"
#import "MKMirror+Reflection.h"
#import "MKMethod.h"

#define TBEquals(a, b) ([a compare:b options:NSCaseInsensitiveSearch] == NSOrderedSame)
#define TBContains(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location != NSNotFound)
#define TBHasPrefix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == 0)
#define TBHasSuffix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == (a.length - b.length))


@interface TBRuntime () {
    NSMutableArray<NSString*> *_imageDisplayNames;
}

@property (nonatomic) NSMutableDictionary *bundles_pathToShort;
@property (nonatomic) NSCache *bundles_pathToClassNames;
@property (nonatomic) NSMutableArray<NSString*> *imagePaths;

@end

/// @return success if the map passes.
static inline NSString * TBWildcardMap_(NSString *token, NSString *candidate, NSString *success, TBWildcardOptions options) {
    switch (options) {
        case TBWildcardOptionsNone:
            // Only "if equals"
            if (TBEquals(candidate, token)) {
                return success;
            }
        default: {
            // Only "if contains"
            if (options & TBWildcardOptionsPrefix &&
                options & TBWildcardOptionsSuffix) {
                if (TBContains(candidate, token)) {
                    return success;
                }
            }
            // Only "if candidate ends with with token"
            else if (options & TBWildcardOptionsPrefix) {
                if (TBHasSuffix(candidate, token)) {
                    return success;
                }
            }
            // Only "if candidate starts with with token"
            else if (options & TBWildcardOptionsSuffix) {
                // Case like "Bundle." where we want "" to match anything
                if (!token.length) {
                    return success;
                }
                if (TBHasPrefix(candidate, token)) {
                    return success;
                }
            }
        }
    }

    return nil;
}

/// @return candidate if the map passes.
static inline NSString * TBWildcardMap(NSString *token, NSString *candidate, TBWildcardOptions options) {
    return TBWildcardMap_(token, candidate, candidate, options);
}

@implementation TBRuntime

#pragma mark - Initialization

+ (instancetype)runtime {
    static TBRuntime *runtime;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runtime = [self new];
        [runtime reloadLibrariesList];
    });

    return runtime;
}

- (id)init {
    self = [super init];
    if (self) {
        _imagePaths = [NSMutableArray array];
        _bundles_pathToShort = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Private

- (void)reloadLibrariesList {
    unsigned int imageCount = 0;
    const char **imageNames = objc_copyImageNames(&imageCount);

    if (imageNames) {
        NSMutableArray *imageNameStrings = [NSMutableArray upto:imageCount map:^id(NSUInteger i) {
            return @(imageNames[i]);
        }];

        self.imagePaths = imageNameStrings;
        free(imageNames);

        // Sort alphabetically
        [imageNameStrings sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            NSString *shortName1 = [self shortNameForImageName:name1];
            NSString *shortName2 = [self shortNameForImageName:name2];
            return [shortName1 caseInsensitiveCompare:shortName2];
        }];

        // Cache image display names
        _imageDisplayNames = [imageNameStrings map:^id(NSString *path) {
            return [self shortNameForImageName:path];
        }];
    }
}

- (NSString *)shortNameForImageName:(NSString *)imageName {
    // Cache
    NSString *shortName = _bundles_pathToShort[imageName];
    if (shortName) {
        return shortName;
    }

    NSArray *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        NSString *parentDir = components[components.count - 2];
        if ([parentDir hasSuffix:@".framework"]) {
            shortName = parentDir;
        }
    }

    if (!shortName) {
        shortName = imageName.lastPathComponent;
    }

    _bundles_pathToShort[imageName] = shortName;
    return shortName;
}

- (NSMutableArray<NSString*> *)classNamesInImageAtPath:(NSString *)path {
    // Check cache
    NSMutableArray *classNameStrings = [_bundles_pathToClassNames objectForKey:path];
    if (classNameStrings) {
        return classNameStrings.mutableCopy;
    }

    unsigned int classCount = 0;
    const char **classNames = objc_copyClassNamesForImage(path.UTF8String, &classCount);

    if (classNames) {
        classNameStrings = [NSMutableArray upto:classCount map:^id(NSUInteger i) {
            return @(classNames[i]);
        }];

        free(classNames);

        [classNameStrings sortUsingSelector:@selector(caseInsensitiveCompare:)];
        [_bundles_pathToClassNames setObject:classNameStrings forKey:path];

        return classNameStrings.mutableCopy;
    }

    return [NSMutableArray array];
}

#pragma mark - Public

- (NSMutableArray<NSString*> *)bundleNamesForToken:(TBToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return _imageDisplayNames;
        }

        // No dot syntax because imageDisplayNames is only mutable internally
        return [_imageDisplayNames map:^id(NSString *binary) {
            NSString *UIName = [self shortNameForImageName:binary];
            return TBWildcardMap(query, UIName, options);
        }];
    }

    return [NSMutableArray array];
}

- (NSMutableArray<NSString*> *)bundlePathsForToken:(TBToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return self.imagePaths;
        }

        return [self.imagePaths map:^id(NSString *binary) {
            NSString *UIName = [self shortNameForImageName:binary];
            return TBWildcardMap_(query, UIName, binary, options);
        }];
    }

    return [NSMutableArray array];
}

- (NSMutableArray<NSString*> *)classesForToken:(TBToken *)token inBundles:(NSMutableArray<NSString*> *)bundles {
    if (bundles.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optimization, avoid unnecessary sorting
        if (bundles.count == 1) {
            // Optimization, avoid a loop
            if (options == TBWildcardOptionsAny) {
                return [self classNamesInImageAtPath:bundles.firstObject];
            }

            return [[self classNamesInImageAtPath:bundles.firstObject] map:^id(NSString *className) {
                return TBWildcardMap(query, className, options);
            }];
        }
        else {
            // Optimization, avoid a loop
            if (options == TBWildcardOptionsAny) {
                return [[bundles flatmap:^NSArray *(NSString *bundlePath) {
                    return [self classNamesInImageAtPath:bundlePath];
                }] sortedUsingSelector:@selector(caseInsensitiveCompare:)];
            }

            return [[bundles flatmap:^NSArray *(NSString *bundlePath) {
                return [[self classNamesInImageAtPath:bundlePath] map:^id(NSString *className) {
                    return TBWildcardMap(query, className, options);
                }];
            }] sortedUsingSelector:@selector(caseInsensitiveCompare:)];
        }
    }

    return [NSMutableArray array];
}

- (NSMutableArray<MKMethod*> *)methodsForToken:(TBToken *)token
                                      instance:(NSNumber *)checkInstance
                                     inClasses:(NSMutableArray *)classes {
    if (classes.count) {
        TBWildcardOptions options = token.options;
        BOOL instance = checkInstance.boolValue;
        NSString *selector = token.string;

        switch (options) {
            /// In practice, I don't think this case is ever used with methods
            case TBWildcardOptionsNone: {
                SEL sel = (SEL)selector.UTF8String;
                return [classes map:^id(NSString *name) {
                    Class cls = NSClassFromString(name);

                    // Method is absolute
                    return [MKLazyMethod methodForSelector:sel class:cls instance:instance];
                }];
            }
            case TBWildcardOptionsAny: {
                return [classes flatmap:^NSArray *(NSString *name) {
                    // Any means `instance` was not specified
                    Class cls = NSClassFromString(name);
                    return [MKMirror allMethodsOf:cls];
                }];
            }
            default: {
                // Only "if contains"
                if (options & TBWildcardOptionsPrefix &&
                    options & TBWildcardOptionsSuffix) {
                    return [classes flatmap:^NSArray *(NSString *name) {
                        Class cls = NSClassFromString(name);
                        return [[MKMirror allMethodsOf:cls] map:^id(MKMethod *method) {

                            // Method is a prefix-suffix wildcard
                            if (TBContains(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only "if method ends with with selector"
                else if (options & TBWildcardOptionsPrefix) {
                    return [classes flatmap:^NSArray *(NSString *name) {
                        Class cls = NSClassFromString(name);

                        return [[MKMirror allMethodsOf:cls] map:^id(MKMethod *method) {
                            // Method is a prefix wildcard
                            if (TBHasSuffix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only "if method starts with with selector"
                else if (options & TBWildcardOptionsSuffix) {
                    assert(checkInstance);

                    return [classes flatmap:^NSArray *(NSString *name) {
                        Class cls = NSClassFromString(name);

                        id mapping = ^id(MKMethod *method) {
                            // Case like "Bundle.class.-" where we want "-" to match anything
                            if (!selector.length) {
                                return method;
                            }

                            // Method is a suffix wildcard
                            if (TBHasPrefix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        };

                        if (instance) {
                            return [[MKMirror instanceMethodsOf:cls] map:mapping];
                        } else {
                            return [[MKMirror classMethodsOf:cls] map:mapping];
                        }
                    }];
                }
            }
        }
    }
    
    return [NSMutableArray array];
}

@end
