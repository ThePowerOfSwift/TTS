//
//  THMPlistReader.h
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 chebur. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Theme)
@interface THMTheme : NSObject

- (BOOL)parsePlistAtPath:(NSString *)path error:(NSError * __autoreleasing *)error NS_SWIFT_NAME(parsePlist(path:));

- (BOOL)parseDictionary:(NSDictionary *)dictionary error:(NSError * __autoreleasing *)error NS_SWIFT_NAME(parseDictionary(_:));

@end

NS_ASSUME_NONNULL_END
