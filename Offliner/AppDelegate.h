//
//  AppDelegate.h
//  Offliner
//
//  Created by Guillaume Cendre on 17/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>


@property (strong, nonatomic) AVAudioPlayer* appAudioPlayer;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) bool isPlaying;

-(void)startPlayingTrack;


@end

