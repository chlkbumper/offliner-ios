//
//  OFMenuButton.m
//  Offliner
//
//  Created by Guillaume Cendre on 19/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFMenuButton.h"

@implementation OFMenuButton

- (instancetype)initWithFrame:(CGRect)frame paddingLeft:(float)paddingLeft paddingTop:(float)paddingTop width:(float)width height:(float)height
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(paddingLeft*2, paddingTop*2, frame.size.width - (2*paddingLeft), frame.size.height - (2*paddingTop))];
        topRow =    [[UIView alloc] initWithFrame:CGRectMake(containerView.frame.size.width * 0.2, containerView.frame.size.height * 0.27, containerView.frame.size.width * 0.6, 2)];
        midRow =    [[UIView alloc] initWithFrame:CGRectMake(containerView.frame.size.width * 0.2, containerView.frame.size.height * 0.50, containerView.frame.size.width * 0.6, 2)];
        bottomRow = [[UIView alloc] initWithFrame:CGRectMake(containerView.frame.size.width * 0.2, containerView.frame.size.height * 0.73, containerView.frame.size.width * 0.6, 2)];
        
        topRow.backgroundColor = [UIColor whiteColor];
        midRow.backgroundColor = [UIColor whiteColor];
        bottomRow.backgroundColor = [UIColor whiteColor];
        
        containerView.backgroundColor = [UIColor clearColor];
        
        [containerView addSubview:topRow];
        [containerView addSubview:midRow];
        [containerView addSubview:bottomRow];
        
        [self roundView:topRow];
        [self roundView:midRow];
        [self roundView:bottomRow];
        
        
        [self addSubview:containerView];
        
        // Initialization code
    }
    return self;
}

-(void)roundView:(UIView*)view {
    view.layer.cornerRadius = 1.5;
}

-(void)buttonPressed {}

-(void)userTapped {
    if (foldedState) {
        foldedState = false;
    } else {
        foldedState = true;
    }
}

-(void)toTripleBar {
    
    CABasicAnimation *topBarBackHorizontal = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    topBarBackHorizontal = [OFGraphicsToolbox standardizedAnimation:topBarBackHorizontal from:[NSNumber numberWithFloat:3*(M_PI/4)] to:[NSNumber numberWithFloat:0] withDuration:0.3];
    [topRow.layer addAnimation:topBarBackHorizontal forKey:@"transform.rotation.z"];
    
    
    CABasicAnimation *topBarMidToTop = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    topBarMidToTop = [OFGraphicsToolbox standardizedAnimation:topBarMidToTop from:[NSNumber numberWithFloat:(containerView.frame.size.height/4)-1] to:[NSNumber numberWithFloat:0] withDuration:0.3];
    [topRow.layer addAnimation:topBarMidToTop forKey:@"transform.translation.y"];
    
    
    CABasicAnimation *botBarBackHorizontal = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    botBarBackHorizontal = [OFGraphicsToolbox standardizedAnimation:botBarBackHorizontal from:[NSNumber numberWithFloat:M_PI/4] to:[NSNumber numberWithFloat:0] withDuration:0.3];
    [bottomRow.layer addAnimation:botBarBackHorizontal forKey:@"transform.rotation.z"];
    
    
    CABasicAnimation *botBarMidToBot = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    botBarMidToBot = [OFGraphicsToolbox standardizedAnimation:botBarMidToBot from:[NSNumber numberWithFloat:0-(containerView.frame.size.height/4)] to:[NSNumber numberWithFloat:0] withDuration:0.3];
    [bottomRow.layer addAnimation:botBarMidToBot forKey:@"transform.translation.y"];
    
    
    
    CABasicAnimation *midBarAppear = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    midBarAppear = [OFGraphicsToolbox standardizedAnimation:midBarAppear from:[NSNumber numberWithFloat:0] to:[NSNumber numberWithFloat:1] withDuration:0.4];
    [midRow.layer addAnimation:midBarAppear forKey:@"transform.scale"];
    
    
}

-(void)toCross {
    
    
    CABasicAnimation *topBarHorizToVertic = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    topBarHorizToVertic = [OFGraphicsToolbox standardizedAnimation:topBarHorizToVertic from:[NSNumber numberWithFloat:0] to:[NSNumber numberWithFloat:3*(M_PI/4)] withDuration:0.3];
    [topRow.layer addAnimation:topBarHorizToVertic forKey:@"transform.rotation.z"];
    
    
    CABasicAnimation *topBarTopToMid = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    topBarTopToMid = [OFGraphicsToolbox standardizedAnimation:topBarTopToMid from:[NSNumber numberWithFloat:0] to:[NSNumber numberWithFloat:(containerView.frame.size.height/4)-1] withDuration:0.3];
    [topRow.layer addAnimation:topBarTopToMid forKey:@"transform.translation.y"];
    
    
    CABasicAnimation *botBarHorizToVertic = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    botBarHorizToVertic = [OFGraphicsToolbox standardizedAnimation:botBarHorizToVertic from:[NSNumber numberWithFloat:0] to:[NSNumber numberWithFloat:M_PI/4] withDuration:0.3];
    [bottomRow.layer addAnimation:botBarHorizToVertic forKey:@"transform.rotation.z"];
    
    
    CABasicAnimation *botBarBotToMid = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    botBarBotToMid = [OFGraphicsToolbox standardizedAnimation:botBarBotToMid from:[NSNumber numberWithFloat:0] to:[NSNumber numberWithFloat:0-(containerView.frame.size.height/4)] withDuration:0.3];
    [bottomRow.layer addAnimation:botBarBotToMid forKey:@"transform.translation.y"];
    
    

    CABasicAnimation *midBarDisappear = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    midBarDisappear = [OFGraphicsToolbox standardizedAnimation:midBarDisappear from:[NSNumber numberWithFloat:1] to:[NSNumber numberWithFloat:0] withDuration:0.4];
    [midRow.layer addAnimation:midBarDisappear forKey:@"transform.scale"];
    
}



-(void)addAnimation:(id)sender {
    
    NSDictionary* objects = [sender userInfo];
    
    [[[objects objectForKey:@"view"] layer] addAnimation:[objects objectForKey:@"animation"] forKey:[objects objectForKey:@"keyPath"]];
    
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
