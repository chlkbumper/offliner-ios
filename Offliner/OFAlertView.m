//
//  OFAlertView.m
//  Offliner
//
//  Created by Guillaume on 02/08/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFAlertView.h"

@implementation OFAlertView

- (id)initWithOrigin:(CGPoint)origin options:(NSArray*)options andTitle:(NSString*)title
{

    int optionIndex = 0;
    int height = 60;
    
    NSLog(@"Height = %lu; Count = %lu", (height*[options count]) + ([options count]*10), (unsigned long)[options count]);
    
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, ((height+10)*[options count]) + 20)];
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]];
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, -5);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.7;
        
        // Initialization code
    }
    
    
    for (id option in options) {
        
        if ([option isKindOfClass:[NSString class]] ) {
            
            //height += 50;
            
            UIView* optionView = [[UIView alloc] initWithFrame:CGRectMake(0, ((height+10) * optionIndex) + 20, [UIScreen mainScreen].bounds.size.width, height)];
            optionView.backgroundColor = [UIColor greenColor];
            [optionView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1]];

            //optionView.layer.cornerRadius = 2;
            optionView.layer.shadowColor = [[UIColor blackColor] CGColor];
            optionView.layer.shadowOffset = CGSizeMake(0, 1);
            optionView.layer.shadowRadius = 1;
            optionView.layer.shadowOpacity = .1;
            
            
            [self addSubview:optionView];
            
            if ([option isEqualToString:@"separator"]) {
                
            } else if ([option isEqualToString:@"download-video"]){
                
            }
            
            optionIndex++;
            
        }
        
    }
    
    //height = 200;
    

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
