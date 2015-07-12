//
//  OFGraphicsToolbox.m
//  Offliner
//
//  Created by Guillaume Cendre on 21/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFGraphicsToolbox.h"

@implementation OFGraphicsToolbox

+(CABasicAnimation*)standardizedAnimation:(CABasicAnimation*)animation from:(NSNumber*)fromValue to:(NSNumber*)toValue withDuration:(double)duration {
    
    //CABasicAnimation* newAnimation = animation;
    
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    //animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = false;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
    
    return animation;
    
}


+(CAGradientLayer*)statusBarGradient {
    
    UIColor *topColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    UIColor *bottomColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}


+(CAGradientLayer*)trackGradient {
    
    UIColor *topColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    UIColor *bottomColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}


+(CAGradientLayer*)videoThumbnailGradient {
    
    UIColor *topColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    UIColor *bottomColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}


+(CAGradientLayer*)videoBackgroundGradient {
    
    UIColor *topColor = [UIColor colorWithRed:90/255.0 green:3/255.0 blue:0 alpha:1];
    //UIColor *bottomColor = [UIColor colorWithWhite:0.2 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:159/255.0 green:26/255.0 blue:9/255.0 alpha:1];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}

@end
