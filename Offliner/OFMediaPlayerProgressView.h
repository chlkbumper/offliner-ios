//
//  OFMediaPlayerProgressView.h
//  Offliner
//
//  Created by Guillaume on 10/08/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFMediaPlayerProgressView : UIView {
    NSTimeInterval totalTimeInterval;
    NSTimeInterval currentTimeInterval;
    NSTimeInterval playableTimeInterval;
}

@property (nonatomic) float trackWidth;

@property (strong, nonatomic) UIPanGestureRecognizer * knobGestureRecognizer;

@property (strong, nonatomic) UIView* knob;
@property (strong, nonatomic) UIView* knobContainerView;
@property (strong, nonatomic) UIView* fullTrack;
@property (strong, nonatomic) UIView* playableTrack;
@property (strong, nonatomic) UIView* track;
@property (strong, nonatomic) UILabel* currentTimeLabel;
@property (strong, nonatomic) UILabel* totalTimeLabel;


-(void)setCurrentTime:(NSTimeInterval)currentTime withKnob:(BOOL)shouldSetKnob;
-(void)setTotalTime:(NSTimeInterval)totalTime;
-(void)setPlayableTime:(NSTimeInterval)playable;

-(void)changeFrame:(CGRect)frame animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (id)initWithFrame:(CGRect)frame currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime andKnobGestureRecognizerTarget:(id)gestureTarget;


@end
