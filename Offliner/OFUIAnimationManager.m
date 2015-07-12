//
//  OFUIAnimationManager.m
//  Offliner
//
//  Created by Guillaume on 29/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFUIAnimationManager.h"

@implementation OFUIAnimationManager

-(void)touchDown:(id)sender {
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    if (value == 0) { value = 1; }
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:.90] withDuration:0.25];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}

-(void)restore:(id)sender {
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1] withDuration:0.25];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}

-(void)touchUp:(id)sender {


    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1.05] withDuration:0.2];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
    
    
    CABasicAnimation* backToIdleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backToIdleAnimation = [OFGraphicsToolbox standardizedAnimation:backToIdleAnimation from:[NSNumber numberWithFloat:1.05 ] to:[NSNumber numberWithFloat:1] withDuration:0.2];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(addAnimationFromUserInfo:) userInfo:@{@"keyPath":@"transform.scale",
                                                                                                                      @"animation":backToIdleAnimation,
                                                                                                                      @"layer":[sender layer]} repeats:NO];

}

-(void)addAnimationFromUserInfo:(id)sender {
    [[[sender userInfo] objectForKey:@"layer"] addAnimation:[[sender userInfo] objectForKey:@"animation"] forKey:[[sender userInfo] objectForKey:@"keyPath"]];
}

@end
