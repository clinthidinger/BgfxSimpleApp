//
//  AppDelegate.m
//  ArtHUD
//
//  Created by clint hidinger on 12/11/19.
//  Copyright © 2019 me. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"
#include "BgfxiOSAppLauncher.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Create window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Create and set root view controller
    GameViewController *viewController = [[GameViewController alloc] init];
    self.window.rootViewController = viewController;

    // Make window visible
    [self.window makeKeyAndVisible];

    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->applicationDidFinishLaunching();
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->applicationWillResignActive();
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->applicationDidEnterBackground();
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->applicationWillEnterForeground();
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    //float scaleFactor = [[UIScreen mainScreen] scale];
    app->applicationDidBecomeActive();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->shutdown();
}

- (void)viewDidLoad {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewDidLoad();
}

- (void)viewWillAppear:(BOOL)animated {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewWillAppear();
}

- (void)viewWillDisappear:(BOOL)animated {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewWillDisappear();
}

- (void)viewDidDisappear:(BOOL)animated {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewDidDisappear();
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewWillTransitionToSize();
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
//    {
//        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//        // do whatever
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
//    {
//
//    }];
//
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

//  withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    
//    //???
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//        [self.orientationDelegate didChangeToOrientation:orientation screenSize:size];
//    } completion:nil];
}

- (void)viewDidLayoutSubviews {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->viewDidLayoutSubviews();
}

- (void)didReceiveMemoryWarning {
    auto *app = BgfxiOSAppLauncher::instance().getApp();
    app->didReceivememoryWarning();
}

//-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
      //url is a local url of photo you've chosen, iOS copied it into document folder of your app
      //do what you want
//}

//application:openURL:sourceApplication:annotation:

// Use this to handle sending images to the app.
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // https://stackoverflow.com/questions/14877395/how-to-send-a-photo-to-my-app-from-default-ios-camera-app
    // UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    return false;
}


@end
