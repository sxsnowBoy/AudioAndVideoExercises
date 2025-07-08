//
//  AVEHomeViewController.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AVEHomeViewController.h"
#import "AVEHomeManager.h"
#import "AVEPreliminaryDisplayViewController.h"

@interface AVEHomeViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation AVEHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)loadUI
{
    self.view.backgroundColor = UIColor.blackColor;
    
    UIButton *albumItem = [UIButton buttonWithType:UIButtonTypeCustom];
    albumItem.tag = 0;
    [albumItem setTitle:@"相册" forState:UIControlStateNormal];
    [albumItem setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    albumItem.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    albumItem.titleLabel.adjustsFontSizeToFitWidth = YES;
    [albumItem addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumItem];
    [albumItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
    UIButton *cameraItem = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraItem.tag = 1;
    [cameraItem setTitle:@"相机" forState:UIControlStateNormal];
    [cameraItem setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    cameraItem.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    cameraItem.titleLabel.adjustsFontSizeToFitWidth = YES;
    [cameraItem addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraItem];
    [cameraItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(albumItem.mas_bottom).offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
}

- (void)itemClick:(UIButton *)item
{
    UIImagePickerControllerSourceType type = item.tag == 0 ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    [AVEHomeManager getUserPhotoAlbumPermissions:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
            [self getVideoResourceEvent:type];
        } else {
            [AVEHomeManager customAlertEvent:@"无相册/相机权限,无法使用" superVC:self actionBlock:nil];
        }
    }];
}

- (void)getVideoResourceEvent:(UIImagePickerControllerSourceType)sourceType
{
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [AVEHomeManager customAlertEvent:@"改设备暂不支持这么获取视频文件" superVC:self actionBlock:nil];
        return;
    }
    
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = sourceType;
    vc.mediaTypes = @[UTTypeMovie.identifier];
    vc.videoQuality = UIImagePickerControllerQualityTypeHigh;
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined: // 未授予权限
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:vc animated:YES completion:nil];
                        });
                    }
                }];
            }
                break;
            case AVAuthorizationStatusAuthorized: // 已授予权限
            {
                [self presentViewController:vc animated:YES completion:nil];
            }
                break;
            case AVAuthorizationStatusDenied: // 已拒绝
            case AVAuthorizationStatusRestricted: // 应用无权使用
            {
                [AVEHomeManager customAlertEvent:@"请打开相机权限" superVC:self actionBlock:nil];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [self enterVideoPreView:videoURL];
    }];
}

- (void)enterVideoPreView:(NSURL *)url
{
    if (url == nil) {
        return;
    }
    AVEPreliminaryDisplayViewController *vc = [[AVEPreliminaryDisplayViewController alloc] init];
    vc.videoUrl = url;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
