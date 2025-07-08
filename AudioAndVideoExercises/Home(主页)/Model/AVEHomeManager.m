//
//  AVEHomeManager.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEHomeManager.h"

@implementation AVEHomeManager

+ (void)getUserPhotoAlbumPermissions:(void(^)(PHAuthorizationStatus status))complete
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(status);
        });
    }];
}

+ (void)customAlertEvent:(NSString *)message superVC:(UIViewController *)superVC actionBlock:(void (^ __nullable)(UIAlertAction *action))actionBlock
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:actionBlock];
    [alertC addAction:action];
    [superVC presentViewController:alertC animated:YES completion:nil];
}

@end
