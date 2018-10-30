//
//  THMAppearanceDecoder.m
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

#import "THMAppearanceDecoder.h"

static NSString * const THMAppearanceDecoderErrorDomain = @"THMAppearanceDecoderErrorDomain";

NS_ENUM(NSInteger, THMAppearanceDecoderError) {
    THMAppearanceDecoderErrorInvalidKeyPath
};

@implementation THMAppearanceDecoder

- (id<UIAppearance>)appearanceFromKeyPath:(NSString *)keyPath error:(NSError * __autoreleasing *)error {
    NSArray *strings = [keyPath componentsSeparatedByString:@"/"];
    
    // transform key path to classes
    NSMutableArray *classes = [NSMutableArray new];
    for (NSInteger i = 0; i < strings.count; i++) {
        NSString *string = strings[i];
        BOOL isLastString = i == strings.count - 1;
        
        Class class = NSClassFromString(string);
        if (class == nil) {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't get class from string %@", string]};
                *error = [NSError errorWithDomain:THMAppearanceDecoderErrorDomain code:THMAppearanceDecoderErrorInvalidKeyPath userInfo:userInfo];
            }
            return nil;
        }
        
        if (isLastString) {
            if (![class conformsToProtocol:@protocol(UIAppearance)]) {
                if (error != NULL) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ should conform to UIAppearance protocol", string]};
                    *error = [NSError errorWithDomain:THMAppearanceDecoderErrorDomain code:THMAppearanceDecoderErrorInvalidKeyPath userInfo:userInfo];
                }
                return nil;
            }
        } else if (![class conformsToProtocol:@protocol(UIAppearanceContainer)]) {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Class %@ should conform to UIAppearanceContainer protocol", string]};
                *error = [NSError errorWithDomain:THMAppearanceDecoderErrorDomain code:THMAppearanceDecoderErrorInvalidKeyPath userInfo:userInfo];
            }
            return nil;
        }
        
        [classes addObject:class];
    }
    
    Class class = classes.lastObject;
    [classes removeLastObject];
    
    if (classes.count == 0) {
        return [(id<UIAppearance>)class appearance];
    } else {
        return [(id<UIAppearance>)class appearanceWhenContainedInInstancesOfClasses: classes];
    }
}

@end
