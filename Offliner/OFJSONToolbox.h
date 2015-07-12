//
//  OFJSONToolbox.h
//  Offliner
//
//  Created by Guillaume Cendre on 18/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OFJSONToolbox : NSObject

+(void)returnJSONwithParam:(NSDictionary *)parameters andEndpointString:(NSString *)urlString WithHandler:(void(^)(__weak id result))handler;


@end
