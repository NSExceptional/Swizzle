//
//  TestStructs.h
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

typedef struct _Two {
    char a, b;
} Two;

typedef struct _Six {
    short a, b;
    char c;
} Six;

typedef struct _Twelve {
    long a;
    char b, c;
} Twelve;

typedef struct _Sixteen {
    int a, b;
    int c;
} Sixteen;

typedef struct _Twenty {
    long a, b;
    int c;
} Twenty;

typedef struct _FloatMix {
    float a;
    double b;
    float c;
} FloatMix;

typedef struct _FloatLarge {
    double a, b, c, d, e;
} FloatLarge;
