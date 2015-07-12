//
//  OFGraphicsToolbox.h
//  Offliner
//
//  Created by Guillaume Cendre on 21/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface OFGraphicsToolbox : NSObject

+(CABasicAnimation*)standardizedAnimation:(CABasicAnimation*)inputAnimation from:(NSNumber*)fromValue to:(NSNumber*)toValue withDuration:(double)duration;

+(CAGradientLayer*)statusBarGradient;
+(CAGradientLayer*)trackGradient;
+(CAGradientLayer*)videoThumbnailGradient;
+(CAGradientLayer*)videoBackgroundGradient;


@end