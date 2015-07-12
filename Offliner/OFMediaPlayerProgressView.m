//
//  OFMediaPlayerProgressView.m
//  Offliner
//
//  Created by Guillaume on 10/08/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFMediaPlayerProgressView.h"

@implementation OFMediaPlayerProgressView
@synthesize fullTrack, playableTrack, track, currentTimeLabel, totalTimeLabel, knob, knobGestureRecognizer, knobContainerView, trackWidth;


- (id)initWithFrame:(CGRect)frame currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime andKnobGestureRecognizerTarget:(id)gestureTarget
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        trackWidth = frame.size.width - 2* 50;
        
        fullTrack = [[UIView alloc] initWithFrame:CGRectMake(60, frame.size.height/2, frame.size.width - 2* 50, 1.5)];
        fullTrack.backgroundColor = [UIColor whiteColor];
        fullTrack.alpha = 0.3;
        
        track = [[UIView alloc] initWithFrame:CGRectMake(60, frame.size.height/2, 0, 1.5)];
        track.backgroundColor = [UIColor whiteColor];
        track.alpha = 1;
        
        playableTrack = [[UIView alloc] initWithFrame:CGRectMake(60, frame.size.height/2, 0, 1.5)];
        playableTrack.backgroundColor = [UIColor whiteColor];
        playableTrack.alpha = 0.2;
    
        
        knobContainerView = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, 45, 45)];
        knobContainerView.center = CGPointMake(currentTime, [UIScreen mainScreen].bounds.size.height/2);
        knobContainerView.backgroundColor = [UIColor clearColor];
        
        knob = [[UIView alloc ] initWithFrame:CGRectMake((knobContainerView.frame.size.width/2)-(15/2), (knobContainerView.frame.size.height/2)-(15/2), 15, 15)];
        //knob.center = CGPointMake(currentTime, [UIScreen mainScreen].bounds.size.height/2);
        knob.backgroundColor = [UIColor whiteColor];
        
        knob.layer.cornerRadius = knob.frame.size.width/2;
        knob.layer.shadowOffset = CGSizeMake(0, 1);
        knob.layer.shadowOpacity = .5;
        knob.layer.shadowRadius = 2;
        knob.layer.shadowColor = [[UIColor clearColor] CGColor];
        
        [knobContainerView addSubview:knob];
        
        currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, frame.size.height)];
        currentTimeLabel.text = [NSString stringWithFormat:@"%f", currentTime];
        currentTimeLabel.textColor = [UIColor whiteColor];
        currentTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
        
        totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(fullTrack.frame.origin.x+fullTrack.frame.size.width+10, 0, 50, frame.size.height)];
        totalTimeLabel.text = [NSString stringWithFormat:@"%f", totalTime];
        totalTimeLabel.textColor = [UIColor whiteColor];
        totalTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
        
        currentTimeLabel.shadowColor = [UIColor blackColor];
        currentTimeLabel.shadowOffset = CGSizeMake(0, 1);
        
        totalTimeLabel.shadowColor = [UIColor blackColor];
        totalTimeLabel.shadowOffset = CGSizeMake(0, 1);
        

        
        int minutes = floor((float)currentTime/60);
        int seconds = round((float)currentTime - minutes * 60);
        
        if (seconds < 10) {
            currentTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
        } else {
            currentTimeLabel.text = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
        }
        
        
        int totalMinutes = floor((float)totalTime/60);
        int totalSeconds = round((float)totalTime - totalMinutes * 60);
        
        if (totalSeconds < 10) {
            totalTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", totalMinutes, totalSeconds];
        } else {
            totalTimeLabel.text = [NSString stringWithFormat:@"%i:%i", totalMinutes, totalSeconds];
        }
        
        knobGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:gestureTarget action:@selector(knobGestureRecognizer:)];
        [knobContainerView addGestureRecognizer:knobGestureRecognizer];
        
        [self addSubview:currentTimeLabel];
        [self addSubview:totalTimeLabel];
        [self addSubview:track];
        [self addSubview:knobContainerView];
        [self addSubview:fullTrack];
        [self addSubview:playableTrack];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)knobGestureRecognizer:(UIGestureRecognizer*)recognizer {}

-(void)setCurrentTime:(NSTimeInterval)currentTime withKnob:(BOOL)shouldSetKnob {
    
    currentTimeInterval = currentTime;
    
    int minutes = floor((float)currentTime/60);
    int seconds = round((float)currentTime - minutes * 60);
    
    if (seconds < 10) {
        currentTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
    } else {
        currentTimeLabel.text = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
    }
    
    if (currentTime > 0) {
        track.frame = CGRectMake(track.frame.origin.x, track.frame.origin.y, (float)fullTrack.frame.size.width*((float)currentTime/(float)totalTimeInterval), 1.5);
        
        if (shouldSetKnob) {
            knobContainerView.center = CGPointMake(((float)fullTrack.frame.size.width*((float)currentTime/(float)totalTimeInterval)-(knob.frame.size.width/2))+fullTrack.frame.origin.x+(knob.frame.size.width/2), self.frame.size.height/2);
        }
    } else {
        track.frame = CGRectMake(track.frame.origin.x, track.frame.origin.y, 0, 1.5);
        if (shouldSetKnob) {
            knobContainerView.center = CGPointMake(track.frame.origin.x, self.frame.size.height/2);
        }
    }
    
}

-(void)setPlayableTime:(NSTimeInterval)playable {
    
    playableTimeInterval = playable;
    
    if (playable > 0) {
        playableTrack.frame = CGRectMake(fullTrack.frame.origin.x, fullTrack.frame.origin.y, fullTrack.frame.size.width*(playable/totalTimeInterval), 1.5);
    } else {
        playableTrack.frame = CGRectMake(fullTrack.frame.origin.x, fullTrack.frame.origin.y, 0, 1.5);
    }
}


-(void)setTotalTime:(NSTimeInterval)totalTime {
    
    totalTimeInterval = totalTime;
    
    if (totalTimeInterval == 0) {
        totalTimeLabel.text = @"--:--";
    } else {
    
        int totalMinutes = floor((float)totalTime/60);
        int totalSeconds = round((float)totalTime - totalMinutes * 60);
    
        if (totalSeconds < 10) {
            totalTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", totalMinutes, totalSeconds];
        } else {
            totalTimeLabel.text = [NSString stringWithFormat:@"%i:%i", totalMinutes, totalSeconds];
        }
    
    }
    
    //NSLog(@"Setting total time");
    
}

-(void)changeFrame:(CGRect)frame animated:(BOOL)animated duration:(NSTimeInterval)duration {
    
    track = [[UIView alloc] initWithFrame:CGRectMake(50, frame.size.height/2, frame.size.width - 2* 50, 0.5)];
    currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, frame.size.height)];
    totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(track.frame.origin.x+track.frame.size.width+10, 0, 50, frame.size.height)];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
