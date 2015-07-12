//
//  AppDelegate.m
//  Offliner
//
//  Created by Guillaume Cendre on 17/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate
@synthesize appAudioPlayer, uuid, isPlaying;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    isPlaying = false;
    
    /*CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    uuid = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);*/
    
    uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];

    
    //////DEEBUUUUUUUUG
    //////DEEEEBUG
    
    //NSLog(@"UUID = %@", uuid);
    
    appAudioPlayer = [[AVAudioPlayer alloc] init];
    return YES;
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isPlaying = false;
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

-(void)startPlayingTrack {
    
    //NSString* filename = [NSString stringWithFormat:@"%@",[appAudioPlayer.url path]];

    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
