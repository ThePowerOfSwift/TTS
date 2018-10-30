//
//  THMStringToColorTransformer.m
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 chebur. All rights reserved.
//

#import "THMStringToColorTransformer.h"

static NSString * const THMStringToColorTransformerErrorDomain = @"THMStringToColorTransformerErrorDomain";

NS_ENUM(NSInteger, THMStringToColorTransformerError) {
    THMStringToColorTransformerErrorUnknownColorSpace,
    THMStringToColorTransformerErrorInvalidHexString
};

@implementation THMStringToColorTransformer

- (NSString *)stringFromColor:(UIColor *)color error:(NSError **)error {
    CGFloat red, green, blue, alpha;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:THMStringToColorTransformerErrorDomain code:THMStringToColorTransformerErrorUnknownColorSpace userInfo:nil];
        }
        return nil;
    }
    
    return [NSString stringWithFormat:@"#%02X%02X%02X#%02X", (unsigned int)red * 255, (unsigned int)green * 255, (unsigned int)blue * 255, (unsigned int)alpha * 255];
}

- (UIColor *)colorFromString:(NSString *)string error:(NSError **)error {
    unsigned int value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    if (![scanner scanHexInt:&value]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:THMStringToColorTransformerErrorDomain code:THMStringToColorTransformerErrorInvalidHexString userInfo:nil];
        }
        return nil;
    }
    
    unsigned int red   = ((value & 0xFF000000) >> 24);
    unsigned int green = ((value & 0x00FF0000) >> 16);
    unsigned int blue  = ((value & 0x0000FF00) >> 8);
    unsigned int alpha = ((value & 0x000000FF) >> 0);
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}

- (id)transformedValue:(id)value {
    NSString *string = value;
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return [self colorFromString:string error:nil];
}

- (id)reverseTransformedValue:(id)value {
    UIColor *color = value;
    if (![color isKindOfClass:[UIColor class]]) {
        return nil;
    }
    
    return [self stringFromColor:color error:nil];
}

@end
