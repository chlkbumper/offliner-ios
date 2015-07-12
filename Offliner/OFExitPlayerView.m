//
//  OFExitButton.m
//  Offliner
//
//  Created by Guillaume on 30/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFExitPlayerView.h"

@implementation OFExitPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIView* leftPart = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.10, frame.size.width*0.5, frame.size.width*0.80, 2)];
        leftPart.backgroundColor = [UIColor whiteColor];
        leftPart.transform = CGAffineTransformMakeRotation(M_PI/4);
        
        UIView* rightPart = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.10, frame.size.width*0.5, frame.size.width*0.80, 2)];
        rightPart.backgroundColor = [UIColor whiteColor];
        rightPart.transform = CGAffineTransformMakeRotation(3*(M_PI/4));

        [self addSubview:leftPart];
        [self addSubview:rightPart];
        
    }
    return self;
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
