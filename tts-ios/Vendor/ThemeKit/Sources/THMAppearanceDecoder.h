//
//  THMAppearanceDecoder.h
//  ThemeKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(AppearanceDecoder)
@interface THMAppearanceDecoder : NSObject

- (id<UIAppearance> _Nullable)appearanceFromKeyPath:(NSString *)keyPath error:(NSError * __autoreleasing *)error NS_SWIFT_NAME(appearanceFromKeyPath(_:));

@end

NS_ASSUME_NONNULL_END
