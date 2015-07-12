//
//  OFJSONToolbox.m
//  Offliner
//
//  Created by Guillaume Cendre on 18/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFJSONToolbox.h"

@implementation OFJSONToolbox


+(void)returnJSONwithParam:(NSDictionary *)parameters andEndpointString:(NSString *)urlString WithHandler:(void(^)(__weak id result))handler
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSDictionary * params = parameters;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsondata length]] forHTTPHeaderField:@"Content-Length"];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:jsondata];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           if(error == nil)
                                                           {
                                                               id returnedObject = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableLeaves error:nil];
                                                               handler(returnedObject);
                                                           }
                                                           else{
                                                               NSLog(@"error %@",error);
                                                           }
                                                       }];
    [dataTask resume];
}



@end
