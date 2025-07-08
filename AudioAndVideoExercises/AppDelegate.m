//
//  AppDelegate.m
//  AudioAndVideoExercises
//
//  Created by 殇雪 on 2025/5/10.
//

#import "AppDelegate.h"
#import "AVEHomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[AVEHomeViewController alloc] init]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
