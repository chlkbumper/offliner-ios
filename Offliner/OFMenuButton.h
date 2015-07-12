//
//  OFMenuButton.h
//  Offliner
//
//  Created by Guillaume Cendre on 19/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "OFGraphicsToolbox.h"



@interface OFMenuButton : UIView {
    
    BOOL foldedState;

    UIView* containerView, *topRow, *midRow, *bottomRow;

}


- (instancetype)initWithFrame:(CGRect)frame paddingLeft:(float)paddingLeft paddingTop:(float)paddingTop width:(float)width height:(float)height;


-(void)buttonPressed;
-(void)userTapped;
-(void)toCross;
-(void)toTripleBar;

@end
