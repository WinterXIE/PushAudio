//
//  BPAudioManager.h
//  PushAudioDemo
//
//  Created by Winter on 2018/5/31.
//  Copyright © 2018年 www.bestpay.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

// 播放完成的callback
typedef void (^BPAudioPlayCompleted)(void) ;

// 播放管理类
@interface BPAudioManager : NSObject

+ (instancetype)sharedPlayer ;
- (void) playPushInfo:(NSDictionary *)userInfo completed:(BPAudioPlayCompleted)completed ;

@end
