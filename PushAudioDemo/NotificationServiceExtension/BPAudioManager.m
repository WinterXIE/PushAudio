//
//  BPAudioManager.m
//  PushAudioDemo
//
//  Created by Winter on 2018/5/31.
//  Copyright © 2018年 www.bestpay.com.cn. All rights reserved.
//

#import "BPAudioManager.h"

@import AVFoundation ;
@import MediaPlayer ;


@interface BPAudioManager() <AVAudioPlayerDelegate> {
    CGFloat userVolume ;
    int audioIndex ;
    NSMutableArray *audioFiles ;
}
@property(nonatomic, copy) BPAudioPlayCompleted completed ;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer ;
@end

@implementation BPAudioManager

+ (instancetype)sharedPlayer {
    static BPAudioManager *_instance = nil ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[BPAudioManager alloc] init] ;
    }) ;
    return _instance ;
}

- (void) playPushInfo:(NSDictionary *)userInfo completed:(BPAudioPlayCompleted)completed {
    
    //step1:
    NSDictionary *extras =  [userInfo objectForKey:@"aps"] ;
    
    

    
    //step2:处理并播放语音
    BOOL playaudio =  [[extras objectForKey:@"playaudio"] boolValue] ;
    if(playaudio) {
        NSString *amount = [extras objectForKey:@"amount"] ;
        amount = [NSString stringWithFormat:@"%.2f", (amount.doubleValue/100.0)] ;
        [self playMoneyReceived:amount completed:completed] ;
    }
    else if(completed != nil) {
        completed() ;
    }
}


- (void) playMoneyReceived:(NSString *)moneyAmount completed:(BPAudioPlayCompleted)completed {
    self.completed = completed ;
    
    // 将金额转换为对应的文字
    NSString* string = [self digitUppercase:moneyAmount] ;
    
    // 分解成mp3数组
    audioFiles = [[NSMutableArray alloc]init] ;
    [audioFiles addObject:@"tts_pre.mp3"] ;
    
    for (int i = 0; i < string.length; i++) {
        NSString * str = [string substringWithRange:NSMakeRange(i, 1)] ;
        
        if([str isEqualToString:@"零"]) {
            str = @"0" ;
        }
        else if([str isEqualToString:@"十"]) {
            str = @"ten" ;
        }
        else if([str isEqualToString:@"百"]) {
            str = @"hundred" ;
        }
        else if([str isEqualToString:@"千"]) {
            str = @"thousand" ;
        }
        else if([str isEqualToString:@"万"]) {
            str = @"ten_thousand" ;
        }
        else if([str isEqualToString:@"点"]) {
            str = @"dot" ;
        }
        else if([str isEqualToString:@"元"]) {
            str = @"yuan" ;
        }
        [audioFiles addObject:[NSString stringWithFormat:@"tts_%@.mp3", str]] ;
    }
    
    audioIndex = 0 ;
    [self activePlayback] ;
    [self setHighVolume] ;
    [self playAudioFiles] ;
}



// 设置高音量
- (void) setHighVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // 获取系统原来的音量，用于还原
    userVolume = volumeViewSlider.value;
    
    static float volume = 0.2f ;
    
    // 留点余地，设置0.9吧， 值在0.0～1.0之间
    if(userVolume < volume) {
        // 改变系统音量
        [volumeViewSlider setValue:volume animated:NO];
        // 发一个事件使之生效
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

// 设置回正常音量
- (void) setNormalVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    if(volumeViewSlider.value !=userVolume) {
        [volumeViewSlider setValue:userVolume animated:NO];
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}




// 播放声音文件
- (void) playAudioFiles {
    // 1.获取要播放音频文件的URL
    NSString *fileName = [audioFiles objectAtIndex:audioIndex] ;
    NSString *path = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], fileName] ;
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    // 2.创建 AVAudioPlayer 对象
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    // 4.设置循环播放
    self.audioPlayer.numberOfLoops = 0 ;
    self.audioPlayer.delegate = self;
    // 5.开始播放
    [self.audioPlayer prepareToPlay] ;
    [self.audioPlayer play];
}

// 播放完成回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    audioIndex += 1 ;
    if(audioIndex < audioFiles.count) {
        [self performSelectorOnMainThread:@selector(playAudioFiles) withObject:nil waitUntilDone:NO] ;
    }
    else {
        [self setNormalVolume] ;
        [self disactivePlayback] ;
        [self performSelectorOnMainThread:@selector(playCompleted) withObject:nil waitUntilDone:NO] ;
    }
}

// 播放完成
- (void) playCompleted {
    if(self.completed) {
        self.completed() ;
    }
}

- (void) activePlayback {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)disactivePlayback {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
}




-(NSString *)digitUppercase:(NSString *)numstr {
    NSArray *numberchar = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    NSArray *inunitchar = @[@"",@"十",@"百",@"千"];
    NSArray *unitname   = @[@"",@"万",@"亿"];
    
    NSString *valstr =[NSString stringWithFormat:@"%.2f",numstr.doubleValue] ;
    NSString *prefix = @"" ;
    
    // 将金额分为整数部分和小数部分
    NSString *head = [valstr substringToIndex:valstr.length - 2 - 1] ;
    NSString *foot = [valstr substringFromIndex:valstr.length - 2] ;
    if (head.length>8) {
        return nil ;//只支持到千万，抱歉哈
    }
    
    // 处理整数部分
    if([head isEqualToString:@"0"]) {
        prefix = @"0" ;
    }
    else {
        NSMutableArray *ch = [[NSMutableArray alloc]init] ;
        for (int i = 0; i < head.length; i++) {
            NSString * str = [NSString stringWithFormat:@"%x",[head characterAtIndex:i]-'0'] ;
            [ch addObject:str] ;
        }
        
        int zeronum = 0 ;
        for (int i = 0; i < ch.count; i++) {
            NSInteger index = (ch.count-1 - i)%4 ;       //取段内位置
            NSInteger indexloc = (ch.count-1 - i)/4 ;    //取段位置
            
            if ([[ch objectAtIndex:i]isEqualToString:@"0"]) {
                zeronum ++ ;
            }
            else {
                if (zeronum != 0) {
                    if (index != 3) {
                        prefix=[prefix stringByAppendingString:@"零"];
                    }
                    zeronum = 0;
                }
                prefix = [prefix stringByAppendingString:[numberchar objectAtIndex:[[ch objectAtIndex:i]intValue]]] ;
                prefix = [prefix stringByAppendingString:[inunitchar objectAtIndex:index]] ;
            }
            if (index == 0 && zeronum < 4) {
                prefix = [prefix stringByAppendingString:[unitname objectAtIndex:indexloc]] ;
            }
        }
    }
    
    
    //处理小数部分
    if([foot isEqualToString:@"00"]) {
        prefix = [prefix stringByAppendingString:@"元"] ;
    }
    else {
        prefix = [prefix stringByAppendingString:[NSString stringWithFormat:@"点%@元", foot]] ;
    }
    
    //
    if([prefix hasPrefix:@"1十"]) {
        prefix = [prefix stringByReplacingOccurrencesOfString:@"1十" withString:@"十"] ;
    }
    
    return prefix ;
}


@end
