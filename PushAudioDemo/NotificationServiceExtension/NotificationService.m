//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by Winter on 2018/5/31.
//  Copyright © 2018年 www.bestpay.com.cn. All rights reserved.
//

#import "NotificationService.h"
#import "BPAudioManager.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //step1: 标记该推送已经在这里处理过了
    NSMutableDictionary *dict = [self.bestAttemptContent.userInfo mutableCopy] ;
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
    self.bestAttemptContent.userInfo = dict ;
    
    //step2: 忽略推送中的默认语音文件(有可能是那个recieved.mp3)
    self.bestAttemptContent.sound = [UNNotificationSound defaultSound] ;
    
    //step3: 处理推送信息，播放语音
    [[BPAudioManager sharedPlayer] playPushInfo:self.bestAttemptContent.userInfo completed:^{
        // 播放完成后，通知系统
        self.contentHandler(self.bestAttemptContent);
    }] ;
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end



