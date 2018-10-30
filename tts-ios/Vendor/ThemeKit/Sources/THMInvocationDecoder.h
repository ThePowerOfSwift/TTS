//
//  THMInvocationDecoder.h
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(InvocationDecoder)
@interface THMInvocationDecoder : NSObject

- (NSInvocation * _Nullable)invocationWithTarget:(id)target object:(NSArray *)object error:(NSError * __autoreleasing *)error NS_SWIFT_NAME(invocation(target:object:));

@end

NS_ASSUME_NONNULL_END
