//
//  AppDelegate.m
//  TGChat
//
//  Created by tango on 16/12/16.
//  Copyright © 2016年 tango. All rights reserved.
//

#import "AppDelegate.h"
#import "TGChatListController.h"
#import "TGChatManage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    TGChatListController *chat = [[TGChatListController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chat];
    self.window.rootViewController = nav;
    
    //账号guo1 guo2
    [[TGChatManage sharedManager] initNet];
    [[TGChatManage sharedManager] loginWithUsername:@"guo2" password:@"123456"];
    
    return YES;
}
                          
// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
  [[EMClient sharedClient] applicationWillEnterForeground:application];
}

@end
