//
//  AVEHomeManager.h
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVEHomeManager : NSObject

+ (void)getUserPhotoAlbumPermissions:(void(^)(PHAuthorizationStatus status))complete;

+ (void)customAlertEvent:(NSString *)message superVC:(UIViewController *)superVC actionBlock:(void (^ __nullable)(UIAlertAction *action))actionBlock;

@end

NS_ASSUME_NONNULL_END
