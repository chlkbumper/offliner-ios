//
//  OFContentViewController.m
//  Offliner
//
//  Created by Guillaume on 28/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFContentViewController.h"

#define APP_DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)


@interface OFContentViewController ()

@end

@implementation OFContentViewController
@synthesize mediaId = mediaId, isDownloaded = isDownload, moviePlayer = moviePlayer, isPreparedToPlay, currentPlaybackRate, currentPlaybackTime;


-(void)stop {}
-(void)beginSeekingBackward {}
-(void)beginSeekingForward {}
-(void)play {}
-(void)endSeeking {}
-(void)prepareToPlay {}
-(void)pause {}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithVideoId:(NSString*)videoId {
    
    self = [super init];
    if (self) {
        mediaId = videoId;
    }
    return self;
}


-(instancetype)initWithVideoId:(NSString*)videoId local:(BOOL)isLocal {
    
    self = [super init];
    if (self) {
        local = YES;
        mediaId = videoId;
        isDownload = YES;
    }
    return self;
}

bool controlsShown = true;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([APP_DELEGATE isPlaying]) {
        [[APP_DELEGATE appAudioPlayer] stop];
    }
    
    slidingKnob = false;
    
    optionsWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    optionsWrapper.backgroundColor = [UIColor clearColor];
    
    if ([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft || [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
        statusBarGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
        trackGradient.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-60, [UIScreen mainScreen].bounds.size.width, 60);
    } else {
        statusBarGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 40);
        trackGradient.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height, 60);
    }
    
    trackGradient = [OFGraphicsToolbox trackGradient];
    statusBarGradient = [OFGraphicsToolbox statusBarGradient];
    
    [[optionsWrapper layer] addSublayer:statusBarGradient];
    [[optionsWrapper layer] addSublayer:trackGradient];
    
    
    
    
    
    showOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showOptionsButton.backgroundColor = [UIColor clearColor];
    showOptionsButton.frame = optionsWrapper.frame;
    [showOptionsButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    
    dismissOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissOptionsButton.backgroundColor = [UIColor clearColor];
    dismissOptionsButton.frame = optionsWrapper.frame;
    [dismissOptionsButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    
    [optionsWrapper addSubview:dismissOptionsButton];
    [optionsWrapper sendSubviewToBack:dismissOptionsButton];
    
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playPauseButton.alpha = 0;
    playPauseButton.frame = CGRectMake(0, 0, 100, 100);
    playPauseButton.center = optionsWrapper.center;
    //playPauseButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    playPauseButton.backgroundColor = [UIColor clearColor];
    playPauseButton.showsTouchWhenHighlighted = NO;
    [playPauseButton addTarget:self action:@selector(reversePlaybackState) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setImage:[UIImage imageNamed:@"Play_Button.png"] forState:UIControlStateNormal];
    [self addBasicTouchAnimationsToObject:playPauseButton];
    
    
    closePlayerContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 40, 40)];
    closePlayerContainerView.backgroundColor = [UIColor clearColor];
    
    closePlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closePlayerButton.alpha = 0;
    closePlayerButton.frame = CGRectMake(0, 0, 40, 40);
    closePlayerButton.backgroundColor = [UIColor clearColor];
    [closePlayerButton addTarget:self action:@selector(closePlayer) forControlEvents:UIControlEventTouchUpInside];
    [self addBasicTouchAnimationsToObject:closePlayerButton];
    
    [UIView animateWithDuration:.4 animations:^{
        playPauseButton.alpha = .5;
        closePlayerButton.alpha = 1;
    }];
    
    closePlayerView = [[OFExitPlayerView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [closePlayerContainerView addSubview:closePlayerView];
    [closePlayerContainerView addSubview:closePlayerButton];
    
    track = [[OFMediaPlayerProgressView alloc] initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height-70, [UIScreen mainScreen].bounds.size.width - (2*10), 50) currentTime:0 totalTime:[moviePlayer duration] andKnobGestureRecognizerTarget:self];
    
    [optionsWrapper addSubview:closePlayerContainerView];
    [optionsWrapper addSubview:playPauseButton];
    [optionsWrapper addSubview:track];
    
    [self.view addSubview:optionsWrapper];
    [self.view addSubview:showOptionsButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareChanged) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    
    animationManager = [[OFUIAnimationManager alloc] init];
    
    [self setupMoviePlayerView];
    
    if (isDownload) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString* filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", mediaId]];
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:local ? [NSURL fileURLWithPath:filePath] : [NSURL URLWithString:filePath]];
        //moviePlayer= [[MPMoviePlayerController alloc] initWithContentURL:<#(NSURL *)#>
        
        NSLog(@"%@", filePath);
        
        [self setupMoviePlayerView];
        
    } else {
        
        NSMutableURLRequest* videoExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://54.76.165.18/index.php"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [videoExtractRequest setHTTPMethod:@"POST"];
        [videoExtractRequest setHTTPBody:[[NSString stringWithFormat:@"id=%@&operation=url_extraction&format=mp4&uuid=%@", mediaId, APP_DELEGATE.uuid] dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"HTTP Body: \"%@\"", [[NSString alloc] initWithData:[videoExtractRequest HTTPBody] encoding:NSUTF8StringEncoding]);
        
        videoURLExtractorConnection = [[NSURLConnection alloc] initWithRequest:videoExtractRequest delegate:self startImmediately:YES];
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPMoviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    
}

-(void)knobGestureRecognizer:(UIPanGestureRecognizer*)recognizer {

    //NSLog(@"%@", recognizer.stat);
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        slidingKnob = true;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        slidingKnob = false;
        
        [moviePlayer setCurrentPlaybackTime:([moviePlayer duration]*(slidedKnobPosition/[track trackWidth]))];
        NSLog(@"%f*(%f/%f) = %f", [moviePlayer duration], slidedKnobPosition, [track trackWidth], [moviePlayer duration]*(slidedKnobPosition/[track trackWidth]));
        
        //slidedKnobPosition = 0;
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    //NSLog(@"Translation: (%f, %f)", translation.x, translation.y);
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y);
    slidedKnobPosition += translation.x;
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
}


-(void)toggleControls {
    
    [optionsTimer invalidate];
    
    if (controlsShown) {
        controlsShown = false;
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            optionsWrapper.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:showOptionsButton];
        }];
    } else {
        controlsShown = true;
        optionsTimer =[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(toggleControls) userInfo:nil repeats:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            optionsWrapper.alpha = 1;
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:optionsWrapper];
        }];
    }
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation { return UIStatusBarAnimationFade; }
-(BOOL)prefersStatusBarHidden { if (controlsShown) { return NO; } else { return YES; } }



- (void)handleMPMoviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    NSDictionary *notificationUserInfo = [notification userInfo];
    NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            NSLog(@"playback failed with error description: %@", [mediaPlayerError description]);
            NSMutableURLRequest* videoExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://54.76.165.18/index.php"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
            [videoExtractRequest setHTTPMethod:@"POST"];
            [videoExtractRequest setHTTPBody:[[NSString stringWithFormat:@"id=%@&operation=file_relocation&format=mp4&uuid=%@", mediaId, APP_DELEGATE.uuid] dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"HTTP Body: \"%@\"", [[NSString alloc] initWithData:[videoExtractRequest HTTPBody] encoding:NSUTF8StringEncoding]);
            
            videoURLExtractorConnection = [[NSURLConnection alloc] initWithRequest:videoExtractRequest delegate:self startImmediately:YES];
        }
        else
        {
            NSLog(@"playback failed without any given reason");
        }
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == videoURLExtractorConnection) {
        [receivedVideoURL appendData:data];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == videoURLExtractorConnection) {
        receivedVideoURL = [[NSMutableData alloc] init];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == videoURLExtractorConnection) {
        NSLog(@"URL = %@", [[NSString alloc] initWithData:receivedVideoURL encoding:NSUTF8StringEncoding]);
        
        //if ()
        //NSLog(@"File exists ? %hhd", [[NSFileManager defaultManager] fileExistsAtPath:[[NSString alloc] initWithData:receivedVideoURL encoding:NSUTF8StringEncoding]]);
        
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[[NSString alloc] initWithData:receivedVideoURL encoding:NSUTF8StringEncoding]]];
        [self setupMoviePlayerView];
    }
}


-(void)prepareChanged {
    //NSLog(@"Prepare changed");
}


-(void)setupMoviePlayerView {
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    if ([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft || [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
        moviePlayer.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    } else {
        moviePlayer.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
    [playPauseButton setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];


    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateVideoCurrentTime) userInfo:nil repeats:YES];

    
    optionsTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(toggleControls) userInfo:nil repeats:NO];
    
    [self.view addSubview:moviePlayer.view];
    [self.view bringSubviewToFront:optionsWrapper];
    [self.view bringSubviewToFront:showOptionsButton];

}


-(void)reversePlaybackState {
    if (moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [moviePlayer pause];
        [playPauseButton setImage:[UIImage imageNamed:@"Play_Button.png"] forState:UIControlStateNormal];
    } else if (moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        [playPauseButton setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
        [moviePlayer play];
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateVideoCurrentTime) userInfo:nil repeats:YES];
    }
}

-(void)updateVideoCurrentTime {
    //NSLog(@"%f", [moviePlayer duration]);
    if (!slidingKnob) {
        [track setCurrentTime:[moviePlayer currentPlaybackTime] withKnob:YES];
    } else {
        [track setCurrentTime:[moviePlayer currentPlaybackTime] withKnob:NO];
    }
    [track setTotalTime:[moviePlayer duration]];
    [track setPlayableTime:[moviePlayer playableDuration]];
    
}

-(void)closePlayer {
    [moviePlayer stop];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(dismissMoviePlayerViewController) userInfo:nil repeats:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0;
    }];
}

-(void)dismissMoviePlayerViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [UIView animateWithDuration:duration animations:^{

        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            trackGradient.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height, 60);
            statusBarGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 40);
            moviePlayer.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            optionsWrapper.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            showOptionsButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            dismissOptionsButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            track.center = CGPointMake([UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width - (50/2));
        } else {
            trackGradient.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-60, [UIScreen mainScreen].bounds.size.width, 60);
            statusBarGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
            moviePlayer.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            optionsWrapper.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            showOptionsButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            dismissOptionsButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            track.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height - (50/2));
        }
        
        closePlayerContainerView.frame = CGRectMake(20, 30, 50, 50);
        playPauseButton.center = optionsWrapper.center;
        
        
    }];
    
}

-(void)addBasicTouchAnimationsToObject:(id)view {

    
        [view addTarget:animationManager action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [view addTarget:animationManager action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [view addTarget:animationManager action:@selector(touchDown:) forControlEvents:UIControlEventTouchDragEnter];
        [view addTarget:animationManager action:@selector(restore:) forControlEvents:UIControlEventTouchDragExit];

}






-(BOOL)shouldAutorotate { return YES; }


-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
