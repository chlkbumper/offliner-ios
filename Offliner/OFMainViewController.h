//
//  ViewController.h
//  Offliner
//
//  Created by Guillaume Cendre on 17/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>

#import "AppDelegate.h"

#import "OFGraphicsToolbox.h"
#import "OFJSONToolbox.h"
#import "OFMenuButton.h"
#import "OFAlertView.h"

#import "OFContentViewController.h"


@interface OFMainViewController : UIViewController <  UIWebViewDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                UIActionSheetDelegate,
                                                UIAlertViewDelegate,
                                                UITextFieldDelegate,
                                                NSURLConnectionDelegate,
                                                NSURLConnectionDataDelegate,
                                                AVAudioPlayerDelegate,
                                                ADBannerViewDelegate>
{
    UIView* overlayView;
    
    UIView* containerView;
    
    CIContext* context;
    
    UIButton *searchButton, *myVideosButton, *playlistsButton, *settingsButton;
    UILabel  *searchLabel,  *myVideosLabel,  *playlistsLabel,  *settingsLabel;
    
    OFMenuButton *menuButtonView;
    UIView *mainMenuView;
    UIButton* menuButton;
    UITextField* searchTextField;
    UIScrollView* suggestionsScrollView;
    
    NSMutableArray* cells;
    NSMutableData *youtubeResponseData;
    
    NSString* youtubeRequestURL, * query;
    
    NSURLConnection *youtubeAPIConnection, *thumbnailURLConnection, *fileDownloadConnection, *mediaURLConnection;
    
    NSMutableData *downloadedFile, *videoURL, *thumbnailData;
    
    NSString *focusedVideo;
    
    NSMutableArray* focusedElements;
    
    UIWebView* backend, * backendJSON;
    
    NSArray *menuOptions;
    
    NSString* stringToSearch;
    
    double sizeOfFileToDownload, downloadedBytes;
    
    UIActivityIndicatorView* tableViewAI;
    
    int focusedOptionIndex;
    
    long focusedCell;
    bool hasAFocusedCell;
    
    NSMutableArray* cachedFiles;
    
    UIActionSheet* optionAlertView, * suboptionAlertView;
    
    NSMutableURLRequest* mediaURLRequest, * fileDownloadRequest, * thumbnailURLRequest;
    
    int errorsCount;
    
    UIAlertView* connectionProblem;
    UIAlertView* alreadyDownloadingWarning;
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) AVAudioPlayer* audioPlayer;

@property (strong, nonatomic) ADBannerView *banner;

@end

