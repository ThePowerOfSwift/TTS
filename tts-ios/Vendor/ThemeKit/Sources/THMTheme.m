//
//  THMPlistParser.m
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 chebur. All rights reserved.
//

#import "THMTheme.h"
#import "THMAppearanceDecoder.h"
#import "THMInvocationDecoder.h"

static NSString * const THMPlistReaderErrorDomain = @"THMPlistReaderErrorDomain";

NS_ENUM(NSInteger, THMPlistReaderError) {
    THMPlistReaderErrorInvalidPlist
};

@implementation THMTheme

- (BOOL)parsePlistAtPath:(NSString *)path error:(NSError * __autoreleasing *)error {
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    if (dictionary == nil) {
        if (error != NULL) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't read plist at path %@", path]};
            *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
        }
        return NO;
    }
    
    return [self parseDictionary:dictionary error:error];
}
         
- (BOOL)parseDictionary:(NSDictionary *)dictionary error:(NSError * __autoreleasing *)error {
    NSArray *keys = dictionary.allKeys;
    for (NSInteger i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSArray *obj = dictionary[key];
        
        if (![key isKindOfClass:[NSString class]]) {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid appearance keypath type %@", key]};
                *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
            }
            return NO;
        }
        
        NSError *appearanceError;
        id<UIAppearance> appearance = [[THMAppearanceDecoder new] appearanceFromKeyPath:key error:&appearanceError];
        if (appearance == nil) {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid appearance keypath %@", key],
                                           NSUnderlyingErrorKey: appearanceError};
                *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
            }
            return NO;
        }
        
        // invocations array
        if (![obj isKindOfClass:[NSArray class]]) {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invocations list for keypath %@ should be NSArray", key]};
                *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
            }
            return NO;
        }
        
        // invocations
        for (NSInteger i = 0; i < obj.count; i++) {
            NSArray *object = obj[i];
            if (![object isKindOfClass:[NSArray class]]) {
                if (error != NULL) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invocation object at index %@ for keypath %@ should be NSArray", @(i), key]};
                    *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
                }
                return NO;
            }
            
            NSError *invocationError;
            NSInvocation *invocation = [[THMInvocationDecoder new] invocationWithTarget:appearance object:object error:&invocationError];
            if (invocation == nil) {
                if (error != NULL) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invocation object at index %@ for keypath %@ should be NSArray", @(i), key],
                                               NSUnderlyingErrorKey: invocationError};
                    *error = [NSError errorWithDomain:THMPlistReaderErrorDomain code:THMPlistReaderErrorInvalidPlist userInfo:userInfo];
                }
                return NO;
            }
            [invocation invoke];
        }
    }
    
    return YES;
}

@end
