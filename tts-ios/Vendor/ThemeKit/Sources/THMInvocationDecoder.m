//
//  THMInvocationDecoder.m
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

#import "THMInvocationDecoder.h"

static NSString * const THMInvocationDecoderErrorDomain = @"THMInvocationDecoderErrorDomain";

NS_ENUM(NSInteger, THMInvocationDecoderError) {
    THMInvocationDecoderErrorInvalidInvocation
};

@implementation THMInvocationDecoder

- (NSInvocation * _Nullable)invocationWithTarget:(id)target object:(NSArray *)object error:(NSError * __autoreleasing *)error {
    if (object.count <= 1) {
        if (error != NULL) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't create invocation from object %@", object]};
            *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
        }
        return nil;
    }
    
    SEL selector = NSSelectorFromString(object[0]);
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature == nil) {
        if (error != NULL) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't create method signature from selector %@", NSStringFromSelector(selector)]};
            *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
        }
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    [invocation retainArguments];
    
    if (invocation == nil) {
        if (error != NULL) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't create invocation from selector %@", NSStringFromSelector(selector)]};
            *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
        }
        return nil;
    }
    
    for (NSInteger i = 1; i < object.count; i++) {
        id argument = object[i];
        NSInteger argumentIndex = i + 1;
        if ([argument isKindOfClass:[NSNumber class]]) {
            double value = [(NSNumber *)argument integerValue];
            [invocation setArgument:&value atIndex:argumentIndex];
        } else if ([argument isKindOfClass:[NSString class]] || [argument isKindOfClass:[NSDate class]]) {
            [invocation setArgument:&argument atIndex:argumentIndex];
        } else if ([argument isKindOfClass:[NSArray class]] && [(NSArray *)argument count] == 2) {
            NSString *transformerName = [(NSArray *)argument firstObject];
            if (![transformerName isKindOfClass:[NSString class]]) {
                if (error != NULL) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't create transformer from object %@", transformerName]};
                    *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
                }
                return nil;
            }
            Class transformerClass = NSClassFromString(transformerName);
            NSValueTransformer *transformer = [transformerClass new];
            if (![transformer isKindOfClass:[NSValueTransformer class]]) {
                if (error != NULL) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Transformer %@ is should be kind of NSValueTransformer class", transformer]};
                    *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
                }
                return nil;
            }
            
            
            NSString *value = [(NSArray *)argument lastObject];
            id object = [transformer transformedValue:value];
            [invocation setArgument:&object atIndex:argumentIndex];
        } else {
            if (error != NULL) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't create argument from object %@", argument]};
                *error = [NSError errorWithDomain:THMInvocationDecoderErrorDomain code:THMInvocationDecoderErrorInvalidInvocation userInfo:userInfo];
            }
            return nil;
        }
    }
    
    return invocation;
}

@end
