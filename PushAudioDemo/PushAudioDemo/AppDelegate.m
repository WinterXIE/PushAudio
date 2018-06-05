//
//  AppDelegate.m
//  PushAudioDemo
//
//  Created by Winter on 2018/5/31.
//  Copyright © 2018年 www.bestpay.com.cn. All rights reserved.
//

#import "AppDelegate.h"
#import "BPAudioManager.h"
@import UserNotifications ;


@interface AppDelegate ()

@end

@implementation AppDelegate





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    

    //  iOS 10的注册变化了，自己网上找啊，😂
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])    {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert) categories:nil];
        
        [application registerForRemoteNotifications];
        
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge                                       |UIRemoteNotificationTypeSound                                      |UIRemoteNotificationTypeAlert)];
    }
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"deviceToken success %@",deviceToken) ;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"deviceToken fail %@",error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[BPAudioManager sharedPlayer] playPushInfo:userInfo completed:nil] ;
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    // 未经过扩展推送处理并且app处于前台时播放语音。其他状态，就播放推送里的那个sound文件吧
//    if([userInfo objectForKey:@"hasHandled"] == nil && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//        [[BPAudioManager sharedPlayer] playPushInfo:userInfo completed:nil] ;
//    }
//}

/*
 
/我； d'/c；
 
 
 
 
{
    aps =     {
        alert = "XXX到账一笔";
        sound = "tts_default.mp3";
        amount= "0.25"
    };
}
 
 
 
 
 
 
 */



@end
