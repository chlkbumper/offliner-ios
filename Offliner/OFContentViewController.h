//
//  OFContentViewController.h
//  Offliner
//
//  Created by Guillaume on 28/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "OFUIAnimationManager.h"
#import "OFExitPlayerView.h"
#import "OFMediaPlayerProgressView.h"

#import "AppDelegate.h"


@interface OFContentViewController : UIViewController <MPMediaPlayback, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSURLConnection* videoURLExtractorConnection;
    NSMutableData* receivedVideoURL;
    OFUIAnimationManager* animationManager;

    UIView* optionsWrapper;
    UIButton* showOptionsButton;
    UIButton* dismissOptionsButton;
    
    UIButton* playPauseButton;
    
    UIButton* closePlayerButton;
    OFExitPlayerView* closePlayerView;
    UIView* closePlayerContainerView;
    
    CAGradientLayer* statusBarGradient;
    CAGradientLayer* trackGradient;
    
    NSTimer* optionsTimer;
    
    OFMediaPlayerProgressView* track;
    
    BOOL local;
    
    BOOL slidingKnob;
    float slidedKnobPosition;
}


-(instancetype)initWithVideoId:(NSString*)videoId;
-(instancetype)initWithVideoId:(NSString*)videoId local:(BOOL)isLocal;

@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property (nonatomic) bool isDownloaded;
@property (strong, nonatomic) NSString* mediaId;



@end
