//
//  ViewController.m
//  Offliner
//
//  Created by Guillaume Cendre on 17/07/2014.
//  Copyright (c) 2014 Guillaume Cendre. All rights reserved.
//

#import "OFMainViewController.h"

#define APP_DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)


@interface OFMainViewController ()
            

@end

@implementation OFMainViewController
@synthesize tableView = _tableView, titleLabel, audioPlayer, banner = _banner;


bool menuShown = false;

bool alreadyDownloading = false;
bool shouldStopDownload = false;
bool retrievingContent  = false;
bool shouldDownload = true;

bool isReadyForNextThumbnail = YES;
NSString* focusedThumbnail;

bool wantsVideo = true;
bool everLoaded = false;
bool everDone = false;

bool tileExpanded = false;

bool collapsing = false;

int actionOption;

float cellHeight = 140;


NSString* videoBaseURL = @"http://www.youtube.com/watch?v=";
NSString* popularVideosURL = @"https://www.googleapis.com/youtube/v3/videos?part=snippet&maxResults=30&chart=mostpopular&key=AIzaSyB0PSVFuoLqoCmnCyf8FeTVsXc70XtbKNg";

-(void)viewDidAppear:(BOOL)animated {
    
    [self refreshCachedFilesList];
    
    [UIView animateWithDuration:0.8 animations:^{
        //overlayView.frame = CGRectMake(0, 0, 320, (320*9)/16);
        overlayView.alpha = 0;
    }];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    actionOption = (int) nil;
    
    NSLog(@"View did load");
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:containerView];
    
    
    [titleLabel removeFromSuperview];
    [containerView addSubview:titleLabel];
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) ];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0;
    
    UIButton* overlayDismisser = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayDismisser.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    overlayDismisser.backgroundColor = [UIColor clearColor];
    overlayDismisser.alpha = 1;
    [overlayDismisser addTarget:self action:@selector(cancelOption) forControlEvents:UIControlEventTouchUpInside];
    
    [overlayView addSubview:overlayDismisser];
    
    [containerView addSubview:overlayView];
    
    
    hasAFocusedCell = false;
    
    _banner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _banner.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 50);
    _banner.alpha = 0;
    _banner.delegate = self;
    
    [containerView addSubview:_banner];
    
    [_tableView setContentSize:CGSizeMake(_tableView.contentSize.width, _tableView.contentSize.height+50)];
    
    tableViewAI = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    tableViewAI.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    [containerView addSubview:tableViewAI];
    [containerView sendSubviewToBack:tableViewAI];
    [tableViewAI startAnimating];
    
    
    menuOptions = [[NSArray alloc] initWithObjects:@"Popular", @"Search", @"My Videos", nil];

    
    

    
    
    
    context = [CIContext contextWithOptions:nil];
    
    NSString* encodedQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)query, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    youtubeRequestURL = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=15&q=%@&key=AIzaSyB0PSVFuoLqoCmnCyf8FeTVsXc70XtbKNg", encodedQuery];
    
    
    //titleLabel.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.alpha = 0;
    titleLabel.font = [UIFont fontWithName:@"OpenSans-CondensedLightItalic" size:25];
    self.titleLabel.text = [@"Popular" uppercaseString];
    titleLabel.numberOfLines = 1;
    titleLabel.minimumScaleFactor = 8./titleLabel.font.pointSize;
    titleLabel.adjustsFontSizeToFitWidth = YES;

    
    
    cells = [[NSMutableArray alloc] init];

    backend = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    backend.delegate = self; backendJSON.delegate = self;
    backend.hidden = YES;
    

    [containerView addSubview:backend];
    [containerView addSubview:backendJSON];
    
    CAGradientLayer* statusBarGradient = [OFGraphicsToolbox statusBarGradient];
    statusBarGradient.frame = CGRectMake(0, 0, 320, 80);
    [containerView.layer insertSublayer:statusBarGradient atIndex:0];
    
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.alpha = 0;
    _tableView.separatorColor = [UIColor clearColor];
    //_tableView.delaysContentTouches = NO;
    [_tableView setShowsVerticalScrollIndicator:NO];
    [containerView addSubview:_tableView];
    [containerView sendSubviewToBack:_tableView];
    [containerView setBackgroundColor:[UIColor colorWithWhite:0.05 alpha:1]];
    self.view.backgroundColor = [UIColor blackColor];
    
    /**
     *      POPULAR, SEARCH, MY VIDEOS
     **/
    [self populateTableViewWithContentOfAPICall:nil];
    /**
     *
     **/

    
    menuButtonView = [[OFMenuButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64) paddingLeft:5 paddingTop:9 width:36 height:42];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuButtonView.frame.size.width, menuButtonView.frame.size.height);
    [menuButton addTarget:self action:@selector(menuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    menuButtonView.alpha = 1;

    
    [menuButtonView addSubview:menuButton];
    [containerView addSubview:menuButtonView];

    [self refreshCachedFilesList];
    
    //////////    FAIS ÇA !!!!!! FAIT LE PAYANT ET GRATUIT AVEC DE LA PUB
    //////////    BASÈ SUR OFFLIBERTY en WebView stringByEvaluatingJavascript pour soumettre les vidéos et avoir les liens
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)refreshCachedFilesList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *err;
    
    cachedFiles = [[NSMutableArray alloc] init];
    
    
    
    int fileIndex = 0;
    for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err]) {
        NSLog(@"%@", object);
        if (object != nil) {
            
        
            [cachedFiles addObject:object];

            /*if ([[object substringFromIndex:[object length] - 5] isEqualToString:@"plist"]) {

                [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(triggerThumbnailDownloadTryForId:) userInfo:[object substringToIndex:[object length] - 6] repeats:YES];

                
            }*/
            ///////  FORCE REFRESH THUMBNAILS
            
        }
        NSError *error;

        /////////ONLY KEEP 4 FILES /// FOR DEBUGGING PURPOSES ONLY
        //if (fileIndex > 4) {
        //[[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:object] error:&error];
        //}
        
        if (error) {
            NSLog(@"%@", error);
        }
        fileIndex++;
    }
    
    if (err) { NSLog(@"%@", err); }
}


-(void)triggerThumbnailDownloadTryForId:(NSTimer*)sender {
    
    NSString* focusedThumbnailNode = sender.userInfo;
    
    if (isReadyForNextThumbnail) {
        
        NSMutableURLRequest* thumbnailExctraction = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", focusedThumbnailNode]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [thumbnailExctraction setTimeoutInterval:20.0];
        
        thumbnailURLRequest  = thumbnailExctraction;
        thumbnailURLConnection = [[NSURLConnection alloc] initWithRequest:thumbnailURLRequest delegate:self startImmediately:YES];
        
        focusedThumbnail = focusedThumbnailNode;
        
        NSLog(@"Downloading thumbnail at address %@", [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", focusedThumbnailNode]);
        
        isReadyForNextThumbnail = NO;
        [sender invalidate];
        
    }

    
}


-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    [UIView animateWithDuration:0.8 animations:^{
        _banner.alpha = 1;
        _banner.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, 320, 50);
    }];
    NSLog(@"Ad successfuly downloaded");
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%@", error);
}

-(void)populateTableViewWithContentOfAPICall:(NSString*)scheme {
    
    
    NSMutableURLRequest* request;
    if (scheme == nil) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:popularVideosURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    } else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:scheme] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    }

    //request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:youtubeRequestURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    /*NSError* requestError;
    NSURLResponse *urlResponse = nil;*/
    
    youtubeAPIConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    
    
    
}

-(void)cancelOption {
    for (OFAlertView* alertView in self.view.subviews) {
        if ([alertView isKindOfClass:[OFAlertView class]]) {
            
            CABasicAnimation* dismiss = [CABasicAnimation animationWithKeyPath:@"position"];
            dismiss.fromValue = [NSValue valueWithCGPoint:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height-(alertView.frame.size.height/2))];
            dismiss.toValue = [NSValue valueWithCGPoint:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height+(alertView.frame.size.height/2))];
            dismiss.duration = 0.3;
            dismiss.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            dismiss.removedOnCompletion = false;
            dismiss.fillMode = kCAFillModeForwards;
            
            [alertView.layer addAnimation:dismiss forKey:@"position"];
            
            [UIView animateWithDuration:0.4 animations:^{
                overlayView.alpha = 0;
            } completion:^(BOOL finished) {
                [alertView removeFromSuperview];
                [containerView setUserInteractionEnabled:YES];
            }];
            
            CABasicAnimation* popBack = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            popBack.fromValue = [NSNumber numberWithFloat:0.9];
            popBack.toValue = [NSNumber numberWithFloat:1];
            popBack.duration = 0.3;
            popBack.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
            popBack.removedOnCompletion = false;
            popBack.fillMode = kCAFillModeForwards;
            
            [containerView.layer addAnimation:popBack forKey:@"transform.scale"];
        
        }
    }
}

-(void)setupMainMenu {
    
    int index = 0;
    int labelHeight = (([UIScreen mainScreen].bounds.size.height - 200)/[menuOptions count]);
    
    for (id option in menuOptions) {
        
        UIView* optionView  = [[UIView alloc] initWithFrame:CGRectMake(/*titleLabel.frame.origin.x + */30, (index * labelHeight)+100, [UIScreen mainScreen].bounds.size.width - (2*30), labelHeight)];
        
        optionView.tag = 98;

        UILabel* optionName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, optionView.frame.size.width, labelHeight)];
        //optionName.frame = CGRectMake(0, 0, optionView.frame.size.width, labelHeight);
        optionName.textColor = [UIColor whiteColor];
        optionName.backgroundColor = [UIColor clearColor];
        optionName.text = [option uppercaseString];
        optionName.font = [UIFont fontWithName:@"OpenSans-CondensedLightItalic" size:25];
        optionName.textAlignment = NSTextAlignmentCenter;
        optionName.shadowOffset = CGSizeMake(0, 1);
        optionName.shadowColor = [UIColor blackColor];
        
        optionName.tag = index;

        
        UIButton* optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        optionView.backgroundColor = [UIColor clearColor];
        optionButton.frame = optionName.frame;
        
        
        
        if (index == 2) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSError *err;
            
            if ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err] count] == 0) {
                //optionButton.enabled = NO;
                [optionButton addTarget:self action:@selector(noDownloadedFileAlert) forControlEvents:UIControlEventTouchUpInside];
                optionName.textColor = [UIColor colorWithWhite:1 alpha:.5];
            } else {
                [optionButton addTarget:self action:@selector(tappedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
                [optionButton addTarget:self action:@selector(dragExitMenuButton:) forControlEvents:UIControlEventTouchDragExit];
                [optionButton addTarget:self action:@selector(touchDownMenuButton:) forControlEvents:UIControlEventTouchDown];
                [optionButton addTarget:self action:@selector(touchDownMenuButton:) forControlEvents:UIControlEventTouchDragEnter];
            }
            
        } else {
            [optionButton addTarget:self action:@selector(tappedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
            [optionButton addTarget:self action:@selector(dragExitMenuButton:) forControlEvents:UIControlEventTouchDragExit];
            [optionButton addTarget:self action:@selector(touchDownMenuButton:) forControlEvents:UIControlEventTouchDown];
            [optionButton addTarget:self action:@selector(touchDownMenuButton:) forControlEvents:UIControlEventTouchDragEnter];
        }
        
        
        [optionView addSubview:optionName];
        [optionView addSubview:optionButton];
        
        [mainMenuView addSubview:optionView];
        
        index++;
    }
    
}

-(void)dragExitMenuButton:(id)sender  {
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[[sender superview] layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1] withDuration:0.15];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}



-(void)tappedMenuButton:(id)sender {
    
    
    int optionIndex = 0;
    for (UILabel* label in [[sender superview] subviews]) { if ([label isKindOfClass:[UILabel class]]) {
        int index = 0;
        for (id option in menuOptions) {
            if ([[option uppercaseString] isEqualToString:label.text]) {
                optionIndex = index;
            }
            index++;
        }
    } }
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[[sender superview] layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1.1] withDuration:0.15];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
    
    
    CABasicAnimation* backToIdleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backToIdleAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:1.2] to:[NSNumber numberWithFloat:1] withDuration:0.3];
    
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(addAnimationFromUserInfo:) userInfo:@{@"keyPath":@"transform.scale",
                                                                                                                      @"animation":backToIdleAnimation,
                                                                                                                      @"layer":[[sender superview] layer]} repeats:NO];
    
    
    [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        /*[sender superview].frame = CGRectMake(titleLabel.frame.origin.x - (([sender superview].frame.size.width - titleLabel.frame.size.width)/2),
                                              titleLabel.frame.origin.y - (([sender superview].frame.size.height - titleLabel.frame.size.height)/2),
                                              [sender superview].frame.size.width, [sender superview].frame.size.height);*/
        
    } completion:^(BOOL finished) {
        NSLog(@"ACTION !");
        if (optionIndex == 1) {
            searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(60, titleLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width-(2*60), titleLabel.frame.size.height)];
            searchTextField.background = nil;
            searchTextField.backgroundColor = [UIColor clearColor];
            searchTextField.font = [UIFont fontWithName:@"OpenSans-CondensedLightItalic" size:25];
            searchTextField.textAlignment = NSTextAlignmentCenter;
            searchTextField.textColor = [UIColor whiteColor];
            searchTextField.returnKeyType = UIReturnKeySearch;
            searchTextField.delegate = self;

            searchTextField.minimumFontSize = 19;
            searchTextField.adjustsFontSizeToFitWidth = YES;
            
            suggestionsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height - (64+216))];
            [mainMenuView addSubview:suggestionsScrollView];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:searchTextField];
            
            [mainMenuView addSubview:searchTextField];
            
            [UIView animateWithDuration:0.3 animations:^{
                [[sender superview] setAlpha:0];
            }];
            
            [searchTextField becomeFirstResponder];
        } else {
            titleLabel.text = [[menuOptions objectAtIndex:optionIndex] uppercaseString];
            focusedOptionIndex = optionIndex;
            [self performMenuOption];
            [menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }];

    int index = 0;
    for (UIView* view in [[[sender superview] superview] subviews]) { if ([view isKindOfClass:[UIView class]]) {
        if (view.tag == 98 && view != [sender superview]) {
            [UIView animateWithDuration:0.3 delay:0.2 * index options:UIViewAnimationOptionCurveEaseIn animations:^{
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+ 100, view.frame.size.width, view.frame.size.height);
                view.alpha = 0;
            } completion:nil];
            index++;
        }
    }}
}



-(void)touchDownMenuButton:(id)sender {
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:1] to:[NSNumber numberWithFloat:0.8] withDuration:0.2];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
    
}

-(void)addAnimationFromUserInfo:(id)sender {
    [[[sender userInfo] objectForKey:@"layer"] addAnimation:[[sender userInfo] objectForKey:@"animation"] forKey:[[sender userInfo] objectForKey:@"keyPath"]];
}


-(void)textFieldChanged:(UITextField*)textField {
    searchTextField.text = [searchTextField.text uppercaseString];
    
    if (![searchTextField.text isEqualToString:@""] && [searchTextField.text length] <= 20) {
    NSString* encodedQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)searchTextField.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    NSString* queryURL = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=%@", encodedQuery];
    
    NSError* err;
    NSString* suggestions = [NSString stringWithContentsOfURL:[NSURL URLWithString:queryURL] encoding:NSUTF8StringEncoding error:&err];
        NSData* jsonData = [suggestions dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData != nil) {
    NSMutableArray* jsonYoutubeAPIResult = [NSJSONSerialization JSONObjectWithData:[suggestions dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&err];
    
    int index = 0;
    for (id view in [suggestionsScrollView subviews]){
        if ([view isKindOfClass:[UIView class]]) {
        [UIView animateWithDuration:0.1 delay:0.01*index options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [view setFrame:CGRectMake([view frame].origin.x+60, [view frame].origin.y, [view frame].size.width, [view frame].size.height)];
            [view setAlpha:0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
        index++;
        }
    }
    
        int suggestionIndex = 0;
    for (id suggestion in [jsonYoutubeAPIResult objectAtIndex:1]) {
        
        UIView* suggestionView = [[UIView alloc] initWithFrame:CGRectMake(suggestionsScrollView.frame.origin.x, 40*suggestionIndex, suggestionsScrollView.frame.size.width, 40)];
        suggestionsScrollView.backgroundColor = [UIColor clearColor];
        
        
        UILabel* suggestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, suggestionView.frame.size.width, suggestionView.frame.size.height)];
        suggestionLabel.text = [suggestion uppercaseString];
        suggestionLabel.backgroundColor = [UIColor clearColor];
        suggestionLabel.textColor = [UIColor colorWithWhite:.9 alpha:.9];
        suggestionLabel.font = [UIFont fontWithName:@"OpenSans-CondensedLightItalic" size:21];
        suggestionLabel.textAlignment = NSTextAlignmentCenter;
        
        UIButton* suggestionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        suggestionButton.backgroundColor = [UIColor clearColor];
        suggestionButton.frame = suggestionLabel.frame;
        [suggestionButton addTarget:self action:@selector(selectSuggestion:) forControlEvents:UIControlEventTouchUpInside];
        [suggestionButton addTarget:self action:@selector(touchDownSuggestion:) forControlEvents:UIControlEventTouchDown];
        [suggestionButton addTarget:self action:@selector(touchOutsideSuggestion:) forControlEvents:UIControlEventTouchDragExit];
        [suggestionButton addTarget:self action:@selector(touchDownSuggestion:) forControlEvents:UIControlEventTouchDragEnter];
        
        
        [suggestionView addSubview:suggestionLabel];
        [suggestionView addSubview:suggestionButton];
        [suggestionsScrollView setContentSize:CGSizeMake(suggestionsScrollView.frame.size.width, (40*suggestionIndex)+64)];
        [suggestionsScrollView addSubview:suggestionView];
        
        suggestionIndex++;
    }
    
    if (err) {NSLog(@"%@", err);}
    
            
    } else {
        int index = 0;
        for (id view in [suggestionsScrollView subviews]){
            if ([view isKindOfClass:[UIView class]]) {
                /*[UIView animateWithDuration:0.02 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [view setFrame:CGRectMake([view frame].origin.x+20, [view frame].origin.y, [view frame].size.width, [view frame].size.height)];
                    [view setAlpha:0];
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];*/
                [view setAlpha:0];
                index++;
            }
        }

    }
    }
}

-(void)selectSuggestion:(id)sender {
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[[sender superview] layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    //NSLog(@"State : %@", [[[sender superview] layer] animationForKey:@"transform.scale"] ]);
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1.1] withDuration:0.15];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
    
    
    CABasicAnimation* backToIdleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backToIdleAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:1.2] to:[NSNumber numberWithFloat:1] withDuration:0.3];
    
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(addAnimationFromUserInfo:) userInfo:@{@"keyPath":@"transform.scale",
                                                                                                                      @"animation":backToIdleAnimation,
                                                                                                                      @"layer":[[sender superview] layer]} repeats:NO];
    
    for (UILabel* suggestionLabel in [[sender superview] subviews]) { if ([suggestionLabel isKindOfClass:[UILabel class]]) {
      
        searchTextField.text = [suggestionLabel.text uppercaseString];
    
    } }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(textFieldChanged:) userInfo:nil repeats:NO];
}

-(void)touchDownSuggestion:(id)sender {
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:1] to:[NSNumber numberWithFloat:0.8] withDuration:0.2];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}


-(void)touchOutsideSuggestion:(id)sender {
    
    NSLog(@"Touched up outside !!");
    
    float value = [[[[[sender superview] layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1] withDuration:0.2];
    
    [[[sender superview] layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![searchTextField.text isEqualToString:@""]) {
        stringToSearch = searchTextField.text;
        [searchTextField resignFirstResponder];
        focusedOptionIndex = 1;
        if ([searchTextField.text length] > 22) {
            [titleLabel setText:[NSString stringWithFormat:@"%@...", [[searchTextField.text substringToIndex:19] uppercaseString]]];
        } else {
            titleLabel.text = [searchTextField.text uppercaseString];
        }
        titleLabel.frame = CGRectMake(100, 20, [UIScreen mainScreen].bounds.size.width-(2*100), titleLabel.frame.size.height);
        [self performMenuOption];
    }
    return YES;
}

-(void)noDownloadedFileAlert {
    UIAlertView* noDownloadedFile = [[UIAlertView alloc] initWithTitle:@"No Cached Video" message:@"You didn't cache any video. Tap the download button on the right of the video you want, then choose a format." delegate:self cancelButtonTitle:@"Fuck you" otherButtonTitles: nil];
    [noDownloadedFile show];
}

-(void)performMenuOption {
    
    switch (focusedOptionIndex) {
        case 0:{ //POPULAR VIDEOS
            [self populateTableViewWithContentOfAPICall:nil]; //Will show popular by default if param is nil
            [UIView animateWithDuration:0.5 animations:^{
                _tableView.alpha = 0;
                tableViewAI.alpha = 1;
            }];
        break;}
        case 1: {//SEARCH
            if (![titleLabel.text isEqualToString:@""]) {
                NSString* encodedQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)stringToSearch, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
                youtubeRequestURL = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=15&q=%@&key=AIzaSyB0PSVFuoLqoCmnCyf8FeTVsXc70XtbKNg", encodedQuery];
                [self populateTableViewWithContentOfAPICall:youtubeRequestURL];
                [menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                [UIView animateWithDuration:0.5 animations:^{
                    _tableView.alpha = 0;
                    tableViewAI.alpha = 1;
                }];
            }
            break;}
        case 2: //MY VIDEOS
            [self reloadCells];
            NSLog(@"Selected \"My Videos\"");
            break;
        default: //There seem to be a problem...
            break;
    }
    
}

-(void)downloadButtonTapped:(id)sender {


    actionOption = 0; //38mpreviously nil or null
    
    for (UILabel* label in [[sender superview] subviews]) {
        if ([label isKindOfClass:[UILabel class]]) {
            if (label.hidden) {
                //NSLog(@"Should download video with ID: %@", label.text);
                focusedVideo = label.text;
            }
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *err;
    
    
    cachedFiles = [[NSMutableArray alloc] init];
    
    shouldDownload = YES;
    
    
    if (!alreadyDownloading && shouldDownload) {
        
        int possiblePlaybacks = 0;
        
        int fileIndex = 0;
        for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err]) {
            
            if ([[object substringToIndex:([object length]-4)] isEqualToString:focusedVideo] && ![[object substringFromIndex:([object length]-4)] isEqualToString:@".jpg"]) {
                possiblePlaybacks++;
            }
            
            NSError *error;

            if (error) {
                NSLog(@"%@", error);
            }
            fileIndex++;
        }
        
        NSLog(@"%i possible playbacks", possiblePlaybacks);
        
        if (possiblePlaybacks == 1) {
            NSString* format = @"";
            NSString* toDownload = @"";
            for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err]) {
                if ([[object substringToIndex:([object length]-4)] isEqualToString:focusedVideo]) {
                    if ([[object substringFromIndex:([object length]-4)] isEqualToString:@".mp3"]) {
                        format = @"an Audio file";
                        toDownload = @"Video";
                    } else if ([[object substringFromIndex:([object length]-4)] isEqualToString:@".mp4"]) {
                        format = @"a Video file";
                        toDownload = @"Audio";
                    }
                }
            }
            
            optionAlertView = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"This video is already cached, as %@", format] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:[NSString stringWithFormat:@"Remove %@", [toDownload isEqualToString:@"Audio"] ? @"Video" : @"Audio"]  otherButtonTitles:[NSString stringWithFormat:@"Play %@", [toDownload isEqualToString:@"Audio"] ? @"Video" : @"Audio"], [NSString stringWithFormat:@"Download %@", toDownload], nil];
            optionAlertView.tag = 201;
            [optionAlertView showInView:self.view];
            shouldDownload = false;
        } else if (possiblePlaybacks == 2) {
            optionAlertView = [[UIActionSheet alloc] initWithTitle:@"This video is already cached, as both Audio and Video files" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove file"  otherButtonTitles:@"Play Audio", @"Play Video", nil];
            optionAlertView.tag = 202;
            [optionAlertView showInView:self.view];
            shouldDownload = false;
        } else if (possiblePlaybacks == 0) {
        
            optionAlertView = [[UIActionSheet alloc] initWithTitle:@"Choose a format" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Audio", @"Video", nil];
            optionAlertView.tag = 1;
            [optionAlertView showInView:self.view];
        }
        
        
        focusedElements = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", nil];
        
        
        
        for (UIProgressView* progress in [[sender superview] subviews]) {
            if ([progress isKindOfClass:[UIProgressView class]] && progress != nil) {
                [focusedElements setObject:progress atIndexedSubscript:0];
            }
        }
        
        for (UIActivityIndicatorView* activity in [[sender superview] subviews]) {
            if ([activity isKindOfClass:[UIActivityIndicatorView class]] && activity != nil) {
                [focusedElements setObject:activity atIndexedSubscript:1];
            }
        }
        
        for (UIButton* downloadButton in [[sender superview] subviews]) {
            if ([downloadButton isKindOfClass:[UIButton class]] && downloadButton != nil) {
                if (downloadButton.frame.origin.x == 250) {
                    [focusedElements setObject:downloadButton atIndexedSubscript:2];
                }
            }
        }
        
        for (UILabel* downloadProgress in [[sender superview] subviews]) {
            if ([downloadProgress isKindOfClass:[UILabel class]] && downloadProgress != nil) {
                //NSLog(@"Found a label (text = %@)", downloadProgress.text);
                if (downloadProgress.tag == 90) {
                    [focusedElements setObject:downloadProgress atIndexedSubscript:3];
                } else if (downloadProgress.tag == 98) {
                    [focusedElements setObject:downloadProgress atIndexedSubscript:4];
                }
            }
        }
        
        CABasicAnimation* scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = [NSNumber numberWithFloat:1];
        scale.toValue = [NSNumber numberWithFloat:0.9];
        scale.duration = 0.3;
        scale.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
        scale.removedOnCompletion = false;
        scale.fillMode = kCAFillModeForwards;
        
        [containerView.layer addAnimation:scale forKey:@"transform.scale"];

        
        [UIView animateWithDuration:0.4 animations:^{
            overlayView.alpha = .3;
            //alertView.center = CGPointMake(alertView.center.x, alertView.center.y-(alertView.frame.size.height/2));
        } completion:^(BOOL finished){
            [containerView setUserInteractionEnabled:NO];
        }];
        
        
    } else if (alreadyDownloading && shouldDownload) {
        alreadyDownloadingWarning = [[UIAlertView alloc] initWithTitle:@"Already downloading" message:@"Sorry, but you can only save one video at a time. However, you can stop the other task by clicking \"Stop\"." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Stop downloading", nil];
        [alreadyDownloadingWarning show];
    }

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Clicked button at index %li", (long)buttonIndex);
    if (alertView == alreadyDownloadingWarning) {
        if (buttonIndex == 0) {
        } else {
        
            shouldStopDownload = true;
            alreadyDownloading = false;
        
            [[focusedElements objectAtIndex:0] setProgress:1 animated:YES];
        
            [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [[focusedElements objectAtIndex:0] setAlpha:0];
                [[focusedElements objectAtIndex:1] setAlpha:0];
                [[focusedElements objectAtIndex:2] setAlpha:1];
            } completion:^(BOOL finished){
            
            }];
        }
    } else if (alertView == connectionProblem) {
        errorsCount = 0;
        
        if (alertView.tag == 101) {
            [self setupMainMenu];
            [menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 202) {
        if (buttonIndex == 0) {
            optionAlertView = [[UIActionSheet alloc] initWithTitle:@"Which file do you want to remove ?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Both" otherButtonTitles:@"Video", @"Audio", nil];
            optionAlertView.tag = 303;
            [optionAlertView showInView:self.view];
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if (buttonIndex == 1) {
            [self playFileFromURL:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", focusedVideo]]];
        }
        if (buttonIndex == 2) {
            OFContentViewController* videoPlayerController = [[OFContentViewController alloc] initWithVideoId:focusedVideo local:YES];
            [self presentViewController:videoPlayerController animated:YES completion:nil];
        }
        
        if (buttonIndex == 3 || buttonIndex == 2 || buttonIndex == 1) {
            [UIView animateWithDuration:0.3 animations:^{ overlayView.alpha = 0; }];
            
            containerView.userInteractionEnabled = YES;
            
            CABasicAnimation* popBack = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            popBack.fromValue = [NSNumber numberWithFloat:0.9];
            popBack.toValue = [NSNumber numberWithFloat:1];
            popBack.duration = 0.3;
            popBack.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
            popBack.removedOnCompletion = false;
            popBack.fillMode = kCAFillModeForwards;
            
            [containerView.layer addAnimation:popBack forKey:@"transform.scale"];
        }
    } else {
    
        if (actionSheet.tag == 303) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            if (buttonIndex == 0) {
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", focusedVideo]] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", focusedVideo]] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", focusedVideo]] error:nil];
                [UIView animateWithDuration:0.4 animations:^{
                    [[focusedElements objectAtIndex:2] setImage:[UIImage imageNamed:@"ActionButton_Idle.png"] forState:UIControlStateNormal];
                    [[focusedElements objectAtIndex:4] setAlpha:0];
                }];

            } else if (buttonIndex == 1) {
                [[focusedElements objectAtIndex:4] setText:@"AUDIO"];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", focusedVideo]] error:nil];
            } else if (buttonIndex == 2) {
                [[focusedElements objectAtIndex:4] setText:@"VIDEO"];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", focusedVideo]] error:nil];
            }
            
            int objsCount = 0;
            for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]) {
                if ([object isKindOfClass:[NSString class]]){
                    if ([[object substringToIndex:([object length]-4)] isEqualToString:@".mp3"]){ objsCount++;
                    } else if ([[object substringToIndex:([object length]-4)] isEqualToString:@".mp4"]) { objsCount++;
                    } else if ([[object substringToIndex:([object length]-6)] isEqualToString:@".plist"]) { objsCount++; }
                }
            }
            if (objsCount == 1) {
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", focusedVideo]] error:nil];
            }
            
            
        }
    
        if (actionSheet.tag == 1) {
        
        switch (buttonIndex) {
            case 0: {
                
                wantsVideo = false;
                
                NSMutableURLRequest* audioExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://52.16.179.235/"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
                [audioExtractRequest setHTTPMethod:@"POST"];
                [audioExtractRequest setHTTPBody:[[NSString stringWithFormat:@"operation=file_relocation&format=mp3&id=%@&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]] dataUsingEncoding:NSUTF8StringEncoding]];
                [audioExtractRequest setTimeoutInterval:20.0];
                //NSLog(@"HTTP Body: \"id=%@\"", focusedVideo);
                mediaURLRequest  = audioExtractRequest;
                mediaURLConnection = [[NSURLConnection alloc] initWithRequest:audioExtractRequest delegate:self startImmediately:YES];
                
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
                NSLog(@"INDEX 0");
                //break;
                
            } break;
            case 1: {
                wantsVideo = true;
                
                NSMutableURLRequest* videoExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://52.16.179.235/index.php"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
                [videoExtractRequest setHTTPMethod:@"POST"];
                [videoExtractRequest setHTTPBody:[[NSString stringWithFormat:@"operation=file_relocation&format=mp4&id=%@&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]] dataUsingEncoding:NSUTF8StringEncoding]];
                //NSLog(@"HTTP Body: \"id=%@&operation=url_extraction&format=mp4\"", focusedVideo);
                mediaURLRequest = videoExtractRequest;
                mediaURLConnection = [[NSURLConnection alloc] initWithRequest:videoExtractRequest delegate:self startImmediately:YES];
                
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
                
                NSLog(@"INDEX 1");
            } break;
        }

        
        NSLog(@"%li", (long)buttonIndex);
        
        if (buttonIndex != 2) {
        alreadyDownloading = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            [[focusedElements objectAtIndex:0] setAlpha:1];
            [[focusedElements objectAtIndex:0] setProgress:0.1 animated:YES];
            [[focusedElements objectAtIndex:1] setAlpha:1];
            [[focusedElements objectAtIndex:2] setAlpha:0];
            
            
        }];
            
        }
        
        

    }
    
        if (actionSheet.tag == 201) {
        
        if (buttonIndex == 0) {
            
            //Wants t
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            if ([[[actionSheet buttonTitleAtIndex:1] substringFromIndex:([[actionSheet buttonTitleAtIndex:1] length] - 5)] isEqualToString:@"Audio"]) {
                [[focusedElements objectAtIndex:2] setImage:[UIImage imageNamed:@"ActionButton_Idle.png"] forState:UIControlStateNormal];
                [[focusedElements objectAtIndex:4] setAlpha:0];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", focusedVideo]] error:nil];
            } else if ([[[actionSheet buttonTitleAtIndex:1] substringFromIndex:([[actionSheet buttonTitleAtIndex:1] length] - 5)] isEqualToString:@"Video"]) {
                [[focusedElements objectAtIndex:2] setImage:[UIImage imageNamed:@"ActionButton_Idle.png"] forState:UIControlStateNormal];
                [[focusedElements objectAtIndex:4] setAlpha:0];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", focusedVideo]] error:nil];
            }
            
            NSLog(@"Remove");
            
        } else if (buttonIndex == 1) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            //Wants to play
            if ([[[actionSheet buttonTitleAtIndex:1] substringFromIndex:([[actionSheet buttonTitleAtIndex:1] length] - 5)] isEqualToString:@"Audio"]) {
                [self playFileFromURL:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", focusedVideo]]];
            } else if ([[[actionSheet buttonTitleAtIndex:1] substringFromIndex:([[actionSheet buttonTitleAtIndex:1] length] - 5)] isEqualToString:@"Video"]) {
                OFContentViewController* videoPlayerController = [[OFContentViewController alloc] initWithVideoId:focusedVideo local:YES];
                [self presentViewController:videoPlayerController animated:YES completion:nil];
            }
            //NSLog(@"PLAY");
        } else if (buttonIndex == 2) {
            if (!alreadyDownloading) {
                
                NSLog(@"Download %@", [[actionSheet buttonTitleAtIndex:2] substringFromIndex:([[actionSheet buttonTitleAtIndex:2] length] - 5)]);
                if ([[[actionSheet buttonTitleAtIndex:2] substringFromIndex:([[actionSheet buttonTitleAtIndex:2] length] - 5)] isEqualToString:@"Audio"]) {
                    wantsVideo = false;
                
                    NSMutableURLRequest* audioExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://52.16.179.235/"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
                    [audioExtractRequest setHTTPMethod:@"POST"];
                    [audioExtractRequest setHTTPBody:[[NSString stringWithFormat:@"operation=file_relocation&format=mp3&id=%@&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]] dataUsingEncoding:NSUTF8StringEncoding]];
                    [audioExtractRequest setTimeoutInterval:20.0];
                    //NSLog(@"HTTP Body: \"id=%@\"", focusedVideo);
                    mediaURLRequest  = audioExtractRequest;
                    mediaURLConnection = [[NSURLConnection alloc] initWithRequest:audioExtractRequest delegate:self startImmediately:YES];
                
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
                } else if ([[[actionSheet buttonTitleAtIndex:2] substringFromIndex:([[actionSheet buttonTitleAtIndex:2] length] - 5)] isEqualToString:@"Video"]) {
                    wantsVideo = true;
                
                    NSMutableURLRequest* videoExtractRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://52.16.179.235/index.php"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
                    [videoExtractRequest setHTTPMethod:@"POST"];
                    [videoExtractRequest setHTTPBody:[[NSString stringWithFormat:@"operation=file_relocation&format=mp4&id=%@&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]] dataUsingEncoding:NSUTF8StringEncoding]];
                    //NSLog(@"HTTP Body: \"id=%@&operation=url_extraction&format=mp4\"", focusedVideo);
                    mediaURLRequest = videoExtractRequest;
                    mediaURLConnection = [[NSURLConnection alloc] initWithRequest:videoExtractRequest delegate:self startImmediately:YES];
                    
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
                }
                
                alreadyDownloading = YES;
            
                [UIView animateWithDuration:0.5 animations:^{
                    [[focusedElements objectAtIndex:0] setAlpha:1];
                    [[focusedElements objectAtIndex:0] setProgress:0.1 animated:YES];
                    [[focusedElements objectAtIndex:1] setAlpha:1];
                    [[focusedElements objectAtIndex:2] setAlpha:0];
                
                
                }];
            }
        }
        
    }
    
    if (actionSheet == suboptionAlertView) {
        
        
        
        
        
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{ overlayView.alpha = 0; }];
    
    containerView.userInteractionEnabled = YES;
    
    CABasicAnimation* popBack = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    popBack.fromValue = [NSNumber numberWithFloat:0.9];
    popBack.toValue = [NSNumber numberWithFloat:1];
    popBack.duration = 0.3;
    popBack.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
    popBack.removedOnCompletion = false;
    popBack.fillMode = kCAFillModeForwards;
    
    [containerView.layer addAnimation:popBack forKey:@"transform.scale"];
        
    }
    
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet { focusedVideo = @"";

    [UIView animateWithDuration:0.3 animations:^{ overlayView.alpha = 0; }];
    
    containerView.userInteractionEnabled = YES;
    
    CABasicAnimation* popBack = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    popBack.fromValue = [NSNumber numberWithFloat:0.9];
    popBack.toValue = [NSNumber numberWithFloat:1];
    popBack.duration = 0.3;
    popBack.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.34 :.01 :.69 :1.37];
    popBack.removedOnCompletion = false;
    popBack.fillMode = kCAFillModeForwards;
    
    [containerView.layer addAnimation:popBack forKey:@"transform.scale"];

}

-(void)menuButtonTapped {
    
    if (!menuShown) {
        
        
        mainMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        mainMenuView.alpha = 0;
        mainMenuView.backgroundColor = [UIColor clearColor];
        
        [self setupMainMenu];
        
        [containerView addSubview:mainMenuView];
        [containerView bringSubviewToFront:menuButtonView];
        
        [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    

        UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
        CGContextRef graphicContext = UIGraphicsGetCurrentContext();
        [containerView.layer renderInContext:graphicContext];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImage* blurredScreenshot = [self blurredImage:screenshot withBlurLevel:15];

        UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-70, -70, [UIScreen mainScreen].bounds.size.width+140, [UIScreen mainScreen].bounds.size.height+140)];
        blurredImageView.image = blurredScreenshot;
    
        [mainMenuView addSubview:blurredImageView];

        UIView* tintView = [[UIView alloc] initWithFrame:mainMenuView.frame];
        tintView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.2];
        
        [mainMenuView addSubview:tintView];
        
        [mainMenuView sendSubviewToBack:tintView];
        [mainMenuView sendSubviewToBack:blurredImageView];

        titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);
        
        [UIView animateWithDuration:0.3 animations:^{
            titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);
            mainMenuView.alpha = 1;
        }];
        
        [menuButtonView toCross];
        
        menuShown = true;
        
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            mainMenuView.alpha = 0;
            titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);

        } completion:^(BOOL finished){
            //[mainMenuView removeFromSuperview];
            for (UIImageView* screenshotImageView in [mainMenuView subviews]) {
                if ([screenshotImageView isKindOfClass:[UIImageView class]]) {
                    if (screenshotImageView.frame.size.height >= [[UIScreen mainScreen] bounds].size.height) {
                        [screenshotImageView removeFromSuperview];
                    }
                }
            }
            for (UIView* tintView in [mainMenuView subviews]) {
                if ([tintView isKindOfClass:[UIView class]]) {
                    if (tintView.frame.size.height >= [[UIScreen mainScreen] bounds].size.height) {
                        [tintView removeFromSuperview];
                    }
                }
            }
            for (UIView* view in [mainMenuView subviews]) {
                if ([view respondsToSelector:@selector(removeFromSuperview)]) {
                        [view removeFromSuperview];
                }
            }
        }];
        
        [menuButtonView toTripleBar];
        
        menuShown = false;
        
        [self setupMainMenu];
        [searchTextField resignFirstResponder];

    }
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    
    /*for (NSInteger* index in [_tableView numberOfRowsInSection:0]) {
        
    }*/
    
    //int rowXIndex = 0;
    
    [self imageScroll];
    
    
    
    
    if (!hasAFocusedCell && ([cells count] > (scrollView.contentOffset.y/cellHeight))) {
        
        int cellIndex = (scrollView.contentOffset.y/*-64*/)/cellHeight;
    
        for (UIView* view in [[cells objectAtIndex:(scrollView.contentOffset.y)/cellHeight] subviews]) {
            
            if ([view isKindOfClass:[UIView class]]) {

                for (UIView* informationView in [view subviews]) {
                    //NSLog(@"%@", informationView);
                    if (informationView.tag == 69) {
                        if (!tileExpanded) {
                            informationView.alpha = pow(1 - ((scrollView.contentOffset.y - (cellIndex * cellHeight)) / cellHeight), 3);
                        }
                    }
                }
                
                
            }
        }
        
        for (UITableViewCell* cell in cells) {
            if (cell.frame.origin.y > (scrollView.contentOffset.y + 64)) {
                for (UIView* view in cell.subviews) {
                    if ([view isKindOfClass:[UIView class]]) {
                        for (UIView* informationView in [view subviews]) {

                            if (informationView.tag == 69) {
                                [UIView animateWithDuration:0.2 animations:^{
                                    informationView.alpha = 1;
                                }];
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"Received response: %@", response);
    if (connection == youtubeAPIConnection) {
        youtubeResponseData = [[NSMutableData alloc] init];
    } else if (connection == fileDownloadConnection) {
        [UIView animateWithDuration:0.4 animations:^{
            [[focusedElements objectAtIndex:4] setAlpha:0];
        }];
        downloadedFile = [[NSMutableData alloc] init];
        sizeOfFileToDownload = [response expectedContentLength];
        //NSLog(@"Downloading a file of %f bytes", sizeOfFileToDownload);
        if (shouldStopDownload) {
            alreadyDownloading = false;
            [connection cancel];
        }
    } else if (connection == mediaURLConnection) {
        videoURL = [[NSMutableData alloc] init];
    } else if (connection == thumbnailURLConnection) {
        thumbnailData = [[NSMutableData alloc] init];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == youtubeAPIConnection) {
        [youtubeResponseData appendData:data];
    } else if (connection == fileDownloadConnection) {
        [downloadedFile appendData:data];
        downloadedBytes = [downloadedFile length];
        double progress = (downloadedBytes/sizeOfFileToDownload);
        //NSLog(@"Downloaded %f bytes %f", downloadedBytes, progress);
        [[focusedElements objectAtIndex:0] setProgress:0.1 + (progress*0.9) animated:YES];
        [[focusedElements objectAtIndex:3] setText:[NSString stringWithFormat:@"%i %%", (int)floorf(progress*100)]];
    } else if (connection == mediaURLConnection) {
        [videoURL appendData:data];
    } else if (connection == thumbnailURLConnection) {
        [thumbnailData appendData:data];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (errorsCount > 5 && error.code == -1001) {
        connectionProblem = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"We have noticed that your Internet connection seems poor. Please check your Internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [connectionProblem show];
        
    } else {
    
        if (error.code == -1001) { errorsCount += 1;  }
        
        if (error.code == -1002 || error.code == -1001 || error.code == -1000) {
            if (connection == fileDownloadConnection) {
                NSLog(@"Requested retry");
                /*if (errorsCount < 5) {
                    fileDownloadConnection = [[NSURLConnection alloc] initWithRequest:fileDownloadRequest delegate:self startImmediately:YES];
                }*/
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
            } else if (connection == youtubeAPIConnection) {
                [self populateTableViewWithContentOfAPICall:nil];
            } else if (connection == mediaURLConnection) {
                NSError* error;
                NSLog(@"Media URL Connection failed, requested retry");
                NSURL* videoPotentialURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://offliner.s3.amazonaws.com/%@.%@", focusedVideo, wantsVideo?@"mp3":@"mp4"]];
                if ([videoPotentialURL checkResourceIsReachableAndReturnError:&error]) {
                    //NSLog(@"%@", error);
                    NSLog(@"File exists ?");
                } else {
                    mediaURLConnection = [[NSURLConnection alloc] initWithRequest:mediaURLRequest delegate:self startImmediately:YES];
                }
            }
        }
        
        if (error.code == -1009) {
            connectionProblem = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"The Internet connection appears to be offline. At the moment, only the videos you chached are available. If you want to prowse the popular section, search videos or cache other ones, please check your Internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            connectionProblem.tag = 101;
            [connectionProblem show];
        }
        
        if (error.code == -1004) {
            connectionProblem = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"The Internet connection appears to be offline. At the moment, only the videos you chached are available. If you want to prowse the popular section, search videos or cache other ones, please check your Internet connection and retry." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            connectionProblem.tag = 102;
            [connectionProblem show];
            alreadyDownloading = NO;
            shouldDownload = YES;
            [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [[focusedElements objectAtIndex:0] setAlpha:0];
                [[focusedElements objectAtIndex:1] setAlpha:0];
                [[focusedElements objectAtIndex:2] setAlpha:1];
                [[focusedElements objectAtIndex:3] setAlpha:0];
            } completion:^(BOOL finished){
                [[focusedElements objectAtIndex:3] setText:@""];
                [[focusedElements objectAtIndex:3] setAlpha:1];
                [UIView animateWithDuration:0.4 animations:^{
                    [[focusedElements objectAtIndex:4] setAlpha:1];
                }];
            }];
        }
        
        NSLog(@"Failed to get datas with error : %@", error);
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (connection == youtubeAPIConnection) {
        [self reloadCells];
        [UIView animateWithDuration:1 animations:^(void) {
            _tableView.alpha = 1;
            tableViewAI.alpha = 0;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            menuButtonView.alpha = 1;
            titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);
            titleLabel.alpha = 1;
            titleLabel.textAlignment = NSTextAlignmentCenter;
        }];
    } else if (connection == fileDownloadConnection) {
        
        retrievingContent = false;

        NSData* downloadFileData = [[NSData alloc] initWithData:downloadedFile];
        [self saveFile:downloadFileData];
        
        NSString* httpBody;
        if (wantsVideo){
            httpBody = [NSString stringWithFormat:@"id=%@&operation=download_ended&format=mp4&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]];
        } else {
            httpBody = [NSString stringWithFormat:@"id=%@&operation=download_ended&format=mp3&user_uuid=%@", focusedVideo, [APP_DELEGATE uuid]];
        }
        
        NSMutableURLRequest* downloadEndedRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@""]];
        [downloadEndedRequest setHTTPMethod:@"POST"];
        [downloadEndedRequest setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self refreshCachedFilesList];

        
        NSString *fileFormat;
        if (wantsVideo) { fileFormat = @"mp4"; } else { fileFormat = @"mp3"; }
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //[self playFileFromURL:downloadedFileLocation];
        
        
        alreadyDownloading = NO;
        shouldDownload = YES;
        
        [[focusedElements objectAtIndex:0] setProgress:1 animated:YES];
        
        int availablePlaybacks = 0;
        
        for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]) {
            if ([[object substringToIndex:([object length]-4)] isEqualToString:focusedVideo]) {
                //NSLog(@"%@ (%@)", [object substringToIndex:([object length]-4)], object);
                //[cachedFiles addObject:object];
                availablePlaybacks++;
            }
        }
        
        for (NSString* file in cachedFiles) {
            if ([file isKindOfClass:[NSString class]]) { if ([[file substringToIndex:[file length]-4] isEqualToString:focusedVideo]) {
                [[focusedElements objectAtIndex:2] setImage:[UIImage imageNamed:@"ActionButton_Cached"] forState:UIControlStateNormal];
                if (wantsVideo) {
                    [[focusedElements objectAtIndex:4] setText:@"VIDEO"];
                } else {
                    [[focusedElements objectAtIndex:4] setText:@"AUDIO"];
                }
                if (availablePlaybacks == 2) {
                    [[focusedElements objectAtIndex:4] setText:@"BOTH"];
                }
                [[focusedElements objectAtIndex:4] setAlpha:0];
            } }
        }
        
        [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [[focusedElements objectAtIndex:0] setAlpha:0];
            [[focusedElements objectAtIndex:1] setAlpha:0];
            [[focusedElements objectAtIndex:2] setAlpha:1];
            [[focusedElements objectAtIndex:3] setAlpha:0];
        } completion:^(BOOL finished){
            [[focusedElements objectAtIndex:3] setText:@""];
            [[focusedElements objectAtIndex:3] setAlpha:1];
            [UIView animateWithDuration:0.4 animations:^{
                [[focusedElements objectAtIndex:4] setAlpha:1];
            }];
        }];
    } else if (connection == mediaURLConnection) {
        
        NSString* url = [[NSString alloc] initWithData:videoURL encoding:NSUTF8StringEncoding];
        NSLog(@"Extracted video URL: %@", url);
        
        mediaURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [mediaURLRequest setHTTPMethod:@"GET"];
        
        shouldDownload = true;
        shouldStopDownload = false;
        
        fileDownloadConnection = [[NSURLConnection alloc] initWithRequest:mediaURLRequest delegate:self startImmediately:YES];
        
        ///LAUNCH fileDownload connection with retrieved URL
        
    }
    else if (connection == thumbnailURLConnection) {
        
        [self saveThumbnailWithData:thumbnailData forId:focusedThumbnail];
        isReadyForNextThumbnail = YES;
        
    }
}
-(NSURLRequest*)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    //NSLog(@"%@, %@, %@", connection, request, response);
    return request;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cells count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"Requested cell height");
    
    if (collapsing) {
        
    }
    
    if (indexPath.row == focusedCell && hasAFocusedCell && !collapsing) {

        //NSLog(@"FOCUSED Cell %i has a height of %f", indexPath.row, [UIScreen mainScreen].bounds.size.height);
        return [UIScreen mainScreen].bounds.size.height;
    }
    
    if (indexPath.row == 0) {
        return cellHeight + 64;
    }
    
    return cellHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    //NSLog(@"%@", cellIdentifier);
    
    UITableViewCell *cell;
    
    //NSLog(@"Created cell");
    
    if (indexPath.row < [cells count]) {
        
        //NSLog(@"There is a cell at requested index %i", indexPath.row);
        
        cell = [cells objectAtIndex:indexPath.row];
        
        for (UILabel* subview in cell.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                //NSLog(@"Found label with text: %@", subview.text);
            }
        }
        
    }
    
    return cell;
    
}


-(void)playButtonPressed:(id)sender {
    
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1.15] withDuration:0.15];
    
    CABasicAnimation* releaseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    releaseAnimation = [OFGraphicsToolbox standardizedAnimation:releaseAnimation from:[NSNumber numberWithFloat:1.1] to:[NSNumber numberWithFloat:1] withDuration:0.2];
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(addAnimationFromUserInfo:) userInfo:@{@"keyPath":@"transform.scale", @"animation":releaseAnimation, @"layer":[sender layer]} repeats:NO];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
    
    NSString* videoID = @"";
    for (UIView* informationsView in [[sender superview] subviews]) { if ([informationsView isKindOfClass:[UIView class]]) { if (informationsView.tag == 69) {
        for (UILabel* videoIdLabel in [informationsView subviews]) {
            if (videoIdLabel.hidden) { videoID = videoIdLabel.text; }
        }
    }}}
    
    NSLog(@"videoID = %@", videoID);
    
    [UIView animateWithDuration:0.6 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        overlayView.alpha = 1;
        overlayView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:nil];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(launchVideo:) userInfo:@{@"id":videoID} repeats:NO];
    
}
-(void)playButtonDragExit:(id)sender {
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    
    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:1] withDuration:0.2];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}
-(void)playButtonDown:(id)sender {
    CABasicAnimation* pushAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    

    float value = [[[[sender layer] animationForKey:@"transform.scale"] valueForKey:@"toValue"] floatValue];
    if (value == 0) { value = 1; }
    
    NSLog(@"pushAnimation.fromValue = %f", value);

    pushAnimation = [OFGraphicsToolbox standardizedAnimation:pushAnimation from:[NSNumber numberWithFloat:value] to:[NSNumber numberWithFloat:.8] withDuration:0.2];
    
    [[sender layer] addAnimation:pushAnimation forKey:@"transform.scale"];
}

-(void)launchVideo:(id)sender {
    
    NSString* videoID = [[sender userInfo] objectForKey:@"id"];
    
    OFContentViewController* videoPlayerController = [[OFContentViewController alloc] initWithVideoId:videoID];
    [self presentViewController:videoPlayerController animated:YES completion:nil];
    
}


-(void)reloadCells {
    
    titleLabel.frame = CGRectMake(100, 20, [[UIScreen mainScreen] bounds].size.width - (200), 44);
    
    NSMutableDictionary* parsedIds = [[NSMutableDictionary alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    
    
    NSLog(@"%@", cachedFiles);
    
    cells = [[NSMutableArray alloc] init];
    
    int videoIndex;

    if (focusedOptionIndex != 2) {
        
        ////////////
        //////////// IF (IN POPULAR) || (IN SEARCH)
        ////////////
        NSError* er;
        NSMutableDictionary* jsonYoutubeAPIResult = [NSJSONSerialization JSONObjectWithData:youtubeResponseData options:NSJSONReadingAllowFragments error:&er];
        

        
        videoIndex = 0;
        for (id video in [jsonYoutubeAPIResult objectForKey:@"items"]) {
       
            //NSLog(@"%@", jsonYoutubeAPIResult);

            NSString * videoId = @"";
            if ([[video objectForKey:@"id"] isKindOfClass:[NSString class]]) {
                videoId = [video objectForKey:@"id"];
            } else {
                videoId = [[video objectForKey:@"id"] objectForKey:@"videoId"];
            }
            
            
            NSString * channelTitle = @"";
            if ([[[video objectForKey:@"snippet"] objectForKey:@"channelTitle"] isEqualToString:@""]) {
                channelTitle = @"Unknown user";
            } else {
                channelTitle = [[video objectForKey:@"snippet"] objectForKey:@"channelTitle"];
            }
            
            
            
            UITableViewCell* cell = [self cellWithTitle:[[video objectForKey:@"snippet"] objectForKey:@"title"]
                                            channelName:channelTitle
                                                 cached:NO
                                            description:[[video objectForKey:@"snippet"] objectForKey:@"description"]
                                                videoId:videoId
                                       thumbnailAddress:[[[[video objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"high"] objectForKey:@"url"]
                                             videoIndex:videoIndex];
            
            //[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d", videoIndex]];
            [cell setClipsToBounds:YES];
            cell.backgroundColor = [UIColor clearColor];
            cell.frame = CGRectMake(0, 0, 320, /*rowHeight*/[UIScreen mainScreen].bounds.size.height);
            cell.tag = videoIndex;
            
            if (cell) {
                [cells setObject:cell atIndexedSubscript:videoIndex];
            }
            
            videoIndex++;
            
            if (videoIndex == [[jsonYoutubeAPIResult objectForKey:@"items"] count]) {
                [_tableView reloadData];
            }
            
            //videoIndex++;
            
        }
    
    } else {
        
        ////////////
        ////////////IF (INMYVIDEOS)
        ////////////
        
        videoIndex = 0;
        
        
        for (id video in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]) {
            
            
            if (![parsedIds objectForKey:[video substringToIndex:[video length]-4]]) {
                
                NSString* videoId = [video substringToIndex:[video length]-4];
                
                NSString* infoPlistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", videoId]];
                
                
                NSDictionary* videoInformationsResponse = [[NSDictionary alloc] initWithContentsOfFile:infoPlistPath];
                
                //NSLog(@"%@", videoInformationsResponse);
                
                [parsedIds setObject:[video substringToIndex:[video length]-4] forKey:[video substringToIndex:[video length]-4]];
                for (id video in [videoInformationsResponse objectForKey:@"items"]) {
                    
                    
                    NSString * videoId = @"";
                    if ([[video objectForKey:@"id"] isKindOfClass:[NSString class]]) {
                        videoId = [video objectForKey:@"id"];
                    } else {
                        videoId = [[video objectForKey:@"id"] objectForKey:@"videoId"];
                    }
                    
                    
                    NSString * channelTitle = @"";
                    if ([[[video objectForKey:@"snippet"] objectForKey:@"channelTitle"] isEqualToString:@""]) {
                        channelTitle = @"Unknown user";
                    } else {
                        channelTitle = [[video objectForKey:@"snippet"] objectForKey:@"channelTitle"];
                    }
                    
                    
                    UITableViewCell* cell = [self cellWithTitle:[[video objectForKey:@"snippet"] objectForKey:@"title"]
                                                    channelName:channelTitle
                                                         cached:NO
                                                    description:[[video objectForKey:@"snippet"] objectForKey:@"description"]
                                                        videoId:videoId
                                               thumbnailAddress:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", videoId]]
                                             /*[[[[video objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"high"] objectForKey:@"url"]*/
                                                     videoIndex:videoIndex];
                    
                    //[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d", videoIndex]];
                    [cell setClipsToBounds:YES];
                    cell.backgroundColor = [UIColor clearColor];
                    cell.frame = CGRectMake(0, 0, 320, /*rowHeight*/[UIScreen mainScreen].bounds.size.height);
                    cell.tag = videoIndex;
                    
                    if (cell) {
                        [cells setObject:cell atIndexedSubscript:videoIndex];
                    }
                    
                    videoIndex++;
                    
                    [_tableView reloadData];
                    
                    NSLog(@"%li", (long)[_tableView numberOfRowsInSection:0]);
                    
                }
                
                [UIView animateWithDuration:1 animations:^(void) {
                    _tableView.alpha = 1;
                    tableViewAI.alpha = 0;
                }];
                [UIView animateWithDuration:0.5 animations:^{
                    menuButtonView.alpha = 1;
                    //titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 20, titleLabel.frame.size.width, 44);
                    titleLabel.alpha = 1;
                }];
                
                
            }
        }
    }
    
    
    [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [_tableView setContentSize:CGSizeMake(_tableView.contentSize.width, (videoIndex*cellHeight)+50+64)];
    [self imageScroll];
    
}


-(UITableViewCell*)cellWithTitle:(NSString*)title channelName:(NSString*)channelName cached:(BOOL)cached description:(NSString*)description videoId:(NSString*)videoId thumbnailAddress:(NSString*)address videoIndex:(int)videoIndex {


    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d", videoIndex]];
    
    
    CAGradientLayer* cellGradient = [OFGraphicsToolbox videoBackgroundGradient];
    cellGradient.frame = CGRectMake(0, 0, 320, cellHeight);
    
    if (videoIndex == 0) {
        cellGradient.frame = CGRectMake(0, 0, 320, cellHeight + 64);
    }

    [[cell layer] insertSublayer:cellGradient atIndex:0];
        
    UIView *informationsWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    informationsWrapper.backgroundColor = [UIColor clearColor];
    informationsWrapper.tag = 69;
        
    UITextView* descriptionLabel = [[UITextView alloc] initWithFrame:CGRectMake(30, cellHeight, 320-(2*30), [UIScreen mainScreen].bounds.size.height > 480 ? 200 : 130)];
    if (videoIndex == 0){
        descriptionLabel.frame = CGRectMake(30, cellHeight + 64, 320-(2*30), [UIScreen mainScreen].bounds.size.height > 480 ? 200 : 130);
    }
    descriptionLabel.textAlignment = NSTextAlignmentJustified;
    descriptionLabel.text = description;
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.tag = 71;
    descriptionLabel.showsVerticalScrollIndicator = NO;
    descriptionLabel.alpha = 0;
    descriptionLabel.editable = NO;
    descriptionLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        
        
    [informationsWrapper addSubview:descriptionLabel];
        
        
        
    UIImageView* backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(-10, -50, 340, cellHeight+50)];
    

    if (videoIndex == 0) { backgroundImage.frame = CGRectMake(-20, -20, 360, cellHeight+64+(50*2)); }
    backgroundImage.clipsToBounds = YES;
    [backgroundImage setBackgroundColor:[UIColor colorWithRed:159/255.0 green:26/255.0 blue:9/255.0 alpha:1]];
    [backgroundImage setBackgroundColor:[UIColor darkGrayColor]];
    
    if ([[address substringToIndex:4] isEqualToString:@"http"]) {
        [backgroundImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:address]]]];
    } else {
        [backgroundImage setImage:[UIImage imageWithContentsOfFile:address]];
        NSLog(@"Address of video %@ is \"%@\"", videoId, address);
    }
    
    
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    backgroundImage.alpha = 0.9;
    backgroundImage.clipsToBounds = YES;
        
    backgroundImage.layer.shadowColor = [[UIColor blackColor] CGColor];
    backgroundImage.layer.shadowRadius = 1;
    backgroundImage.layer.shadowOpacity = 1;
    backgroundImage.layer.shadowOffset = CGSizeMake(0,2);
        
    backgroundImage.layer.shouldRasterize = YES;
    backgroundImage.layer.rasterizationScale = 2;
    
    backgroundImage.tag = videoIndex;
    NSLog(@"Setting cell with videoIndex = %i", videoIndex);
    
        
        
    CIImage *inputImage = [[CIImage alloc] initWithImage:backgroundImage.image];
    CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIColorControls"];
    [exposureAdjustmentFilter setDefaults];
    [exposureAdjustmentFilter setValue:inputImage forKey:@"inputImage"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:1.1f] forKey:@"inputSaturation"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:1.3f] forKey:@"inputContrast"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:0.2f] forKey:@"inputBrightness"];
    CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
    CIContext *ct = [CIContext contextWithOptions:nil];
    backgroundImage.image = [UIImage imageWithCGImage:[ct /*Or context ?*/ createCGImage:outputImage fromRect:outputImage.extent]];
        
    [cell addSubview:backgroundImage];
        
    UIView* shadowView = [[UIView alloc] initWithFrame:/*backgroundImage.frame*/CGRectMake(0, 0, 320, cellHeight)];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.tag = 70;
        
    CAGradientLayer* thumbnailShadow = [OFGraphicsToolbox videoThumbnailGradient];
    thumbnailShadow.frame = backgroundImage.frame;
    [shadowView.layer addSublayer:thumbnailShadow];
        
    [cell addSubview:shadowView];
        
        
    UILabel* videoTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 320-(50+70), cellHeight * 0.7)];
    if (videoIndex == 0) { videoTitle.frame = CGRectMake(35, 64, 320-(50+70), cellHeight * 0.7); }
    videoTitle.numberOfLines = 3;
    videoTitle.shadowOffset = CGSizeMake(0, 1);
    videoTitle.shadowColor = [UIColor blackColor];
    videoTitle.backgroundColor = [UIColor clearColor];
    videoTitle.textColor = [UIColor whiteColor];
    videoTitle.text = title;
    videoTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        
    //videoTitle.layer.backgroundColor = [[UIColor redColor] CGColor];
        
    //videoTitle.numberOfLines = 0;
    NSString* string = title;
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 24.f;
    //style.maximumLineHeight = 25.f;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
    videoTitle.attributedText = [[NSAttributedString alloc] initWithString:string
                                                                    attributes:attributtes];
        //[videoTitle sizeToFit];
        
        
        
        
        
        
    UILabel *hiddenVideoIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    hiddenVideoIdLabel.hidden = YES;
    hiddenVideoIdLabel.text = videoId;
    
        
    UILabel* channelTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, cellHeight * 0.6, 320-(50+70), cellHeight * 0.3)];
    if (videoIndex == 0) { channelTitle.frame = CGRectMake(35, (cellHeight * 0.6) + 64, 320-(50+70), cellHeight - (cellHeight * 0.7)); }
    channelTitle.numberOfLines = 1;
    channelTitle.backgroundColor = [UIColor clearColor];
    channelTitle.textColor = [UIColor whiteColor];
    
    channelTitle.text = channelName;
    channelTitle.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    

    
    
        
    //NSLog(@"%f w/ height %f displays \"%@\"", channelTitle.frame.origin.y, channelTitle.frame.size.height,[[video objectForKey:@"snippet"] objectForKey:@"channelTitle"]);
    
    UIButton* actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (videoIndex == 0) { actionButton.frame = CGRectMake(250, (cellHeight * 0.30) + 64, cellHeight * 0.33, cellHeight * 0.33);
    } else {               actionButton.frame = CGRectMake(250, cellHeight * 0.30, cellHeight * 0.33, cellHeight * 0.33); }
    
    
    [actionButton setImage:[UIImage imageNamed:@"ActionButton_Idle.png"] forState:UIControlStateNormal];
    actionButton.backgroundColor = [UIColor clearColor];
        
        
        
    for (NSString* downloadedMedia in cachedFiles) {
            if ([videoId isEqualToString:[downloadedMedia substringToIndex:([downloadedMedia length]-4)]]) {
                [actionButton setImage:[UIImage imageNamed:@"ActionButton_Cached.png"] forState:UIControlStateNormal];
                //NSLog(@"Found an already cached video: \"%@\"", [[video objectForKey:@"snippet"] objectForKey:@"title"]);
            }
    }
        
        
        
    [actionButton addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    UILabel* downloadedMediaType = [[UILabel alloc] initWithFrame:CGRectMake(160, actionButton.frame.size.height + actionButton.frame.origin.y, 160 - (320 - (actionButton.frame.origin.x + actionButton.frame.size.width - 4)), 40)];
    downloadedMediaType.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    downloadedMediaType.textColor = [UIColor colorWithWhite:1 alpha:1];
    downloadedMediaType.textAlignment = NSTextAlignmentRight;
    downloadedMediaType.shadowColor = [UIColor blackColor];
    downloadedMediaType.shadowOffset = CGSizeMake(0, 1);
    downloadedMediaType.tag = 98;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    int availablePlaybacks = 0;
    
    for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]) {
        if ([[object substringToIndex:([object length]-4)] isEqualToString:videoId]) {
            //NSLog(@"%@ (%@)", [object substringToIndex:([object length]-4)], object);
            //[cachedFiles addObject:object];
            availablePlaybacks++;
        }
    }
    
    for (id downloadedMedia in cachedFiles) {
        //NSLog(@"Format: %@", [downloadedMedia substringToIndex:[downloadedMedia length]-4]);
            if ([videoId isEqualToString:[downloadedMedia substringToIndex:[downloadedMedia length]-4]]) {
                //NSLog(@"Format: %@", [downloadedMedia substringFromIndex:[downloadedMedia length]-3]);
                if ([[downloadedMedia substringFromIndex:[downloadedMedia length]-3] isEqualToString:@"mp3"]) {
                    downloadedMediaType.text = @"AUDIO";
                } else if ([[downloadedMedia substringFromIndex:[downloadedMedia length]-3] isEqualToString:@"mp4"]) {
                    downloadedMediaType.text = @"VIDEO";
                }
                if (availablePlaybacks == 3) {
                    downloadedMediaType.text = @"BOTH";
                }
            }
    }
        
        
    UIProgressView* downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    if (videoIndex == 0) {
        downloadProgressView.frame = CGRectMake(0, (cellHeight-2)+64, 320, 2);
    } else {
        downloadProgressView.frame = CGRectMake(0, cellHeight-2, 320, 2);
    }
    downloadProgressView.tintColor = [UIColor whiteColor];
    downloadProgressView.trackTintColor = [UIColor clearColor];
    downloadProgressView.alpha = 0;
        
        
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //spinner.frame = CGRectMake(downloadButton.frame.origin.x, downloadButton.frame.origin.y, spinner.frame.size.width, spinner.frame.size.height);
    //spinner.frame = CGRectMake(0, 0, spinner.frame.size.width, spinner.frame.size.height);
    spinner.center = actionButton.center;
    spinner.tintColor = [UIColor whiteColor];
    spinner.alpha = 0;
    spinner.hidesWhenStopped = NO;
    [spinner startAnimating];
        
        
        
    UIButton* watchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    watchButton.frame = CGRectMake(0, 0, actionButton.frame.origin.x, cellHeight);
    if (videoIndex == 0) { watchButton.frame = CGRectMake(0, 64, actionButton.frame.origin.x, cellHeight); }
    //watchButton.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:.5];
    watchButton.backgroundColor = [UIColor clearColor];
    [watchButton addTarget:self action:@selector(tappedTileButton:) forControlEvents:UIControlEventTouchUpInside];
        
    UIButton* playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (focusedCell == 0) { playButton.frame = CGRectMake((([UIScreen mainScreen].bounds.size.width/2)- ((cellHeight/2) - 15)) + 10,0,cellHeight,cellHeight);
    } else { playButton.frame = CGRectMake((([UIScreen mainScreen].bounds.size.width/2)- ((cellHeight/2) - 15)) + 10,0,cellHeight,cellHeight); }
    playButton.center = backgroundImage.center;
    playButton.alpha = 0;
    playButton.tag = 101;
    [playButton setBackgroundColor:[UIColor clearColor]];
    playButton.adjustsImageWhenHighlighted = NO;
    //playButton.backgroundColor = [UIColor greenColor];
    [playButton setImage:[UIImage imageNamed:@"Play2.png"] forState:UIControlStateNormal];
    [cell addSubview:playButton];
        
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [playButton addTarget:self action:@selector(playButtonDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [playButton addTarget:self action:@selector(playButtonDown:) forControlEvents:UIControlEventTouchDragEnter];
    [playButton addTarget:self action:@selector(playButtonDown:) forControlEvents:UIControlEventTouchDown];
        
    UILabel* downloadProgress = [[UILabel alloc] initWithFrame:CGRectMake(actionButton.frame.origin.x-(/*actionButton.frame.size.width+*/30),
                                                                              actionButton.frame.origin.y+actionButton.frame.size.height,
                                                                              actionButton.frame.size.width+30,
                                                                              30)];
    downloadProgress.text = @"";
    downloadProgress.textColor = [UIColor whiteColor];
    downloadProgress.shadowOffset = CGSizeMake(0, 1);
    downloadProgress.shadowColor = [UIColor blackColor];
    downloadProgress.backgroundColor = [UIColor clearColor];
    downloadProgress.textAlignment = NSTextAlignmentRight;
    downloadProgress.textColor = [UIColor whiteColor];
    downloadProgress.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    downloadProgress.tag = 90;
        
        
    [informationsWrapper addSubview:downloadProgress];
    [informationsWrapper addSubview:downloadedMediaType];
    [informationsWrapper addSubview:videoTitle];
    [informationsWrapper addSubview:channelTitle];
    [informationsWrapper addSubview:actionButton];
    [informationsWrapper addSubview:hiddenVideoIdLabel];
    [informationsWrapper addSubview:downloadProgressView];
    [informationsWrapper addSubview:watchButton];
    [informationsWrapper addSubview:spinner];
    
    [cell addSubview:informationsWrapper];
        
    [cell bringSubviewToFront:playButton];
        
    UIInterpolatingMotionEffect* xMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xMotion.minimumRelativeValue = @(-10);
    xMotion.maximumRelativeValue = @(10);
        
    UIInterpolatingMotionEffect* yMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yMotion.minimumRelativeValue = @(-10);
    yMotion.maximumRelativeValue = @(10);
        
        
    UIMotionEffectGroup* informationViewMotion = [UIMotionEffectGroup new];
    informationViewMotion.motionEffects = @[xMotion, yMotion];
        
        
    ///////////////////-------------------
        
        
    UIInterpolatingMotionEffect* imageViewXMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    imageViewXMotion.minimumRelativeValue = @(10);
    imageViewXMotion.maximumRelativeValue = @(-10);
        
    UIInterpolatingMotionEffect* imageViewYMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    imageViewYMotion.minimumRelativeValue = @(10);
    imageViewYMotion.maximumRelativeValue = @(-10);
        
        
    UIMotionEffectGroup* imageViewMotion = [UIMotionEffectGroup new];
    imageViewMotion.motionEffects = @[imageViewXMotion, imageViewYMotion];
        
        
    //[backgroundImage addMotionEffect:imageViewMotion];
    [informationsWrapper addMotionEffect:informationViewMotion];
        
    for (UIView *currentView in cell.subviews)
    {
        if([currentView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    
    return cell;

}



-(void)imageScroll {
    for (int i = 0; i < [_tableView numberOfRowsInSection:0]; i++) {
        
        //NSLog(@"Row at index %i has a height of %i px", [_tableView ]);
        CGRect rectOfCellInTableView = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        CGRect rectOfCellInSuperview = [_tableView convertRect:rectOfCellInTableView toView:[_tableView superview]];
        
        if (rectOfCellInSuperview.origin.y > -cellHeight && rectOfCellInSuperview.origin.y < [UIScreen mainScreen].bounds.size.height) {
            /*for (UIView* cellScrollView in [[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] subviews]) {

                
                
                for (UIImageView* thumbnail in [cellScrollView subviews]) {
                    
                    //NSLog(@"%@", thumbnail);
                    
                    if ([thumbnail isKindOfClass:[UIImageView class]]) {
                        
                        NSLog(@"UIImageView's tag %i", thumbnail.tag);
  

                        //NSLog(@"Resized an image");
                        if (i == 0) {
                            thumbnail.frame = CGRectMake(thumbnail.frame.origin.x, (-50*(rectOfCellInSuperview.origin.y/[UIScreen mainScreen].bounds.size.height))-((84/2)), thumbnail.frame.size.width, thumbnail.frame.size.height);
                        } else {
                            thumbnail.frame = CGRectMake(thumbnail.frame.origin.x, -50*(rectOfCellInSuperview.origin.y/[UIScreen mainScreen].bounds.size.height), thumbnail.frame.size.width, thumbnail.frame.size.height);
                        }
                    }
                }
            }*/
            NSLog(@"Cell %@ is in sightm<", [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]);
        }
        
        
    }
}

-(void)tappedTileButton:(id)sender {
    
    if (!tileExpanded) {
        
        UITableViewCell* tappedCell = (UITableViewCell*)[[[sender superview] superview] superview];
        
        int rowIndexPath = 0;
        collapsing = false;
        hasAFocusedCell = true;
        tileExpanded = true;
        
        int k = 0;
        for (UITableViewCell* listCell in cells) {
            if (listCell == tappedCell) {
                for (UIView* view in [[cells objectAtIndex:k] subviews]) {
                    if ([view isKindOfClass:[UIView class]]) {
                        for (UIView* informationView in [view subviews]) {
                            
                            if (informationView.tag == 69) {
                                [UIView animateWithDuration:0.2 animations:^{
                                    informationView.alpha = 1;
                                }];
                            }
                        }
                    }
                }
                rowIndexPath = k;
            }
            k++;
        }
        
        
        focusedCell = rowIndexPath;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [_tableView beginUpdates];
            [_tableView endUpdates];
            
            //titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y-30, titleLabel.frame.size.width, titleLabel.frame.size.height);
            menuButtonView.frame = CGRectMake(menuButtonView.frame.origin.x, menuButtonView.frame.origin.y-30, menuButtonView.frame.size.width, menuButtonView.frame.size.height);
            titleLabel.alpha = 0;
            menuButtonView.alpha = 0;

            
            for (UIImageView* thumbnail in [[[sender superview] superview] subviews]) { if ([thumbnail isKindOfClass:[UIImageView class]]) {
                thumbnail.frame= CGRectMake(0, 0, 320, (320*9)/16);
                if (focusedCell == 0) { thumbnail.frame = CGRectMake(0, 0, 320, (320*9)/16); }
                thumbnail.motionEffects = nil;
            } }
            
            for (UIButton* playButton in [[[sender superview] superview] subviews]) { if ([playButton isKindOfClass:[UIButton class]]) { if (playButton.tag == 101) {
                playButton.alpha = 1;
                NSLog(@"Set alpha");
                for (UIImageView* thumbnailImageView in [[[sender superview] superview] subviews]) { if ([thumbnailImageView isKindOfClass:[UIImageView class]]) {
                    playButton.center = CGPointMake(thumbnailImageView.center.x, thumbnailImageView.center.y);
                    [tappedCell bringSubviewToFront:playButton];
                    NSLog(@"Centered and brought to front");
                } }
            } } }
            
            for (UIView* informationView in [[[sender superview] superview] subviews]) {
                if ([informationView isKindOfClass:[UIView class]]) {
                    if (informationView.tag == 69) {
                        if (rowIndexPath == 0) {
                            informationView.frame = CGRectMake(informationView.frame.origin.x, ((320*9)/16)-(64-5), informationView.frame.size.width, informationView.frame.size.height);
                        
                        } else {
                            informationView.frame = CGRectMake(informationView.frame.origin.x, ((320*9)/16)+5, informationView.frame.size.width, informationView.frame.size.height);
                        }
                        //NSLog(@"Replaced informationView");
                        
                        for (UITextView* textView in [informationView subviews]) {
                            if ([textView isKindOfClass:[UITextView class]]) {
                                textView.alpha = 1;
                            }
                        }
                        
                        for (UIProgressView* progressView in [informationView subviews]) {
                            if ([progressView isKindOfClass:[UIProgressView class]]) {
                                if (rowIndexPath == 0) {
                                    progressView.frame = CGRectMake(0, 62, progressView.frame.size.width, progressView.frame.size.height);
                                } else {
                                    progressView.frame = CGRectMake(0, 0, progressView.frame.size.width, progressView.frame.size.height);
                                }
                            }
                        }

                    } else if (informationView.tag == 70) {
                        informationView.alpha = 0;
                        informationView.frame = CGRectMake(0, 0, 320, (320*9)/16);
                        
                        for (CAGradientLayer* gradient in [[informationView layer] sublayers]) { if ([gradient isKindOfClass:[CAGradientLayer class]]) {
                            gradient.frame = CGRectMake(0, 0, 320, (320*9)/16);
                        } }
                        
                        //NSLog(@"Hid informationView shadowView");
                    }
                    //NSLog(@"%i", informationView.tag);
                }
            }
            for (CAGradientLayer* layer in [[[[[sender superview] superview] superview] layer] sublayers]) { if ([layer isKindOfClass:[CAGradientLayer class]]) {
            
                layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                
            } }
        
            
            tappedCell.alpha = 1;
            
            } completion:^(BOOL finished)  {
                [_tableView beginUpdates];
                [_tableView endUpdates];
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:focusedCell inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }];

        //[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:focusedCell inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:focusedCell inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

        //[_tableView beginUpdates];
        //[_tableView endUpdates];
    
        [_tableView setScrollEnabled:NO];
    
        
        
    } else {
        
        collapsing = false;
        
        [self imageScroll];
        
        UITableViewCell* cell = (UITableViewCell*)[[[sender superview] superview] superview];
        long rowIndexPath = cell.tag;
        focusedCell = rowIndexPath;
        
        collapsing = true;

        [UIView animateWithDuration:0.3 animations:^{
            
            
            
            [_tableView beginUpdates];
            [_tableView endUpdates];
            
            
            for (UIButton* playButton in [[[sender superview] superview] subviews]) { if ([playButton isKindOfClass:[UIButton class]]) { if (playButton.tag == 101) {
                playButton.alpha = 0;
                NSLog(@"Set alpha");
                for (UIImageView* thumbnailImageView in [[[sender superview] superview] subviews]) { if ([thumbnailImageView isKindOfClass:[UIImageView class]]) {
                    playButton.center = CGPointMake(thumbnailImageView.center.x, thumbnailImageView.center.y);
                    [cell bringSubviewToFront:playButton];
                    NSLog(@"Centered and brought to front");
                } }
            } } }
            
            //titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 20, titleLabel.frame.size.width, titleLabel.frame.size.height);
            menuButtonView.frame = CGRectMake(menuButtonView.frame.origin.x, menuButtonView.frame.origin.y+30, menuButtonView.frame.size.width, menuButtonView.frame.size.height);
            titleLabel.alpha = 1;
            menuButtonView.alpha = 1;
            
            for (UIImageView* thumbnail in [[[sender superview] superview] subviews]) { if ([thumbnail isKindOfClass:[UIImageView class]]) {
                if (focusedCell == 0) {
                    thumbnail.frame= CGRectMake(-20, -50, 360, cellHeight+64+(50*2));
                } else {
                    thumbnail.frame= CGRectMake(-10, -50, 340, cellHeight+50);
                }
                
                for (UIButton* playButton in [thumbnail subviews]) { if ([playButton isKindOfClass:[UIButton class]]) {
                    [UIView animateWithDuration:0.3 animations:^{
                        playButton.alpha = 0;
                    }];
                } }
                
                UIInterpolatingMotionEffect* imageViewXMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                imageViewXMotion.minimumRelativeValue = @(10);
                imageViewXMotion.maximumRelativeValue = @(-10);
                
                UIInterpolatingMotionEffect* imageViewYMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                imageViewYMotion.minimumRelativeValue = @(10);
                imageViewYMotion.maximumRelativeValue = @(-10);
                
                
                UIMotionEffectGroup* imageViewMotion = [UIMotionEffectGroup new];
                imageViewMotion.motionEffects = @[imageViewXMotion, imageViewYMotion];
                //[thumbnail addMotionEffect:imageViewMotion];
                
                NSLog(@"Added motion effect");
                
            } }
            for (UIView* informationView in [[[sender superview] superview] subviews]) {
                if ([informationView isKindOfClass:[UIView class]]) {
                    if (informationView.tag == 69) {
                        informationView.frame = CGRectMake(informationView.frame.origin.x, 0, informationView.frame.size.width, informationView.frame.size.height);

                        for (UITextView* textView in [informationView subviews]) {
                            if ([textView isKindOfClass:[UITextView class]]) {
                                textView.alpha = 0;
                                if (focusedCell == 0) {
                                }
                            }
                        }
                        
                        for (UIProgressView* progressView in [informationView subviews]) {
                            if ([progressView isKindOfClass:[UIProgressView class]]) {
                                if (rowIndexPath == 0) {
                                    progressView.frame = CGRectMake(0, (cellHeight+64)-2, progressView.frame.size.width, progressView.frame.size.height);
                                } else {
                                    progressView.frame = CGRectMake(0, cellHeight-2, progressView.frame.size.width, progressView.frame.size.height);
                                }
                            }
                        }
                        
                    } else if (informationView.tag == 70) {
                        informationView.alpha = 1;
                        
                        if (focusedCell == 0) { informationView.frame = CGRectMake(0, 0, 320, cellHeight+64);
                        } else { informationView.frame = CGRectMake(0, 0, 320, cellHeight); }
                        
                        for (CAGradientLayer* gradient in [[informationView layer] sublayers]) { if ([gradient isKindOfClass:[CAGradientLayer class]]) {
                            if (focusedCell == 0) { gradient.frame = CGRectMake(0, 0, 320, cellHeight+104);
                            } else { gradient.frame = CGRectMake(0, 0, 320, cellHeight+40); }
                        } }
                        
                        //NSLog(@"Hid informationView shadowView");
                    }
                    //NSLog(@"%i", informationView.tag);
                }
            }
            for (CAGradientLayer* layer in [[[[[sender superview] superview] superview] layer] sublayers]) { if ([layer isKindOfClass:[CAGradientLayer class]]) {
                
                if (rowIndexPath == 0) { layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cellHeight+64);
                } else { layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cellHeight); }
                
            } }
            
            
        } completion:^(BOOL finished)  {
            
            
        }];
        
        
        if (rowIndexPath != 0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:focusedCell-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }

        
        [_tableView setScrollEnabled:YES];
        
        
        hasAFocusedCell = NO;
        tileExpanded = false;
        
        //[_tableView beginUpdates];
        //[_tableView endUpdates];
        
        
        
    }
    
    
    
    
    
    
    

    
}


-(BOOL)shouldAutorotate { return NO; }

-(UIImage*)blurredImage:(UIImage*)image withBlurLevel:(NSInteger)blur {

    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:kCIInputImageKey, inputImage, @"inputRadius", @(blur), nil];
    
    CIImage *outputImage = filter.outputImage;
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    return [UIImage imageWithCGImage:outImage];
}

-(UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }

-(void)saveThumbnailWithData:(NSData*)data forId:(NSString*)videoId {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", videoId]] atomically:YES];
    
}


-(void)saveFile:(NSData*)data {
    
    NSLog(@"Saving file from data");
    
    NSString *fileFormat;
    if (wantsVideo) { fileFormat = @"mp4"; } else { fileFormat = @"mp3"; }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    NSString *downloadedFileLocation = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", focusedVideo, fileFormat]];
    NSLog(@"Path = %@", downloadedFileLocation);
    [data writeToFile:downloadedFileLocation atomically:YES];
    
    
    NSError* infoError;
    NSString *videoInfosJSON = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&id=%@&key=AIzaSyB0PSVFuoLqoCmnCyf8FeTVsXc70XtbKNg", focusedVideo]] encoding:NSUTF8StringEncoding error:&infoError];
    
    NSMutableArray* videoInfos = [NSJSONSerialization JSONObjectWithData:[videoInfosJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&infoError];
    
    [videoInfos writeToFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", focusedVideo]] atomically:YES];
    
    isReadyForNextThumbnail = YES;
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(triggerThumbnailDownloadTryForId:) userInfo:focusedVideo repeats:YES];
    
    
}

-(void)playFileFromURL:(NSString*)filePath {
    
    //NSLog(@"Should play file from URL");
    
    filePath = [NSString stringWithFormat:@"%@", filePath];
    
    NSError *err;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //NSLog(@"File exists at path");
    } else {
        NSLog(@"File doesn't exist here: %@", filePath);
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:&err];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
    
    [APP_DELEGATE startPlayingTrack];
    
    APP_DELEGATE.appAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&err];
    
    //AppDelegate.audioPlayer.delegate = self;
    APP_DELEGATE.appAudioPlayer.numberOfLoops = 100;
    [APP_DELEGATE.appAudioPlayer prepareToPlay];
    [APP_DELEGATE.appAudioPlayer play];
    
    APP_DELEGATE.isPlaying = true;
    
    if (err != nil) {
        NSLog(@"%@", err);
    }
    
    [self refreshNowPlayingInfoCenterPreviousTrack:NO];
    
}

-(void)refreshNowPlayingInfoCenterPreviousTrack:(BOOL)previousTrack {
    
    
    NSString* videoID = [[[[APP_DELEGATE appAudioPlayer] url] lastPathComponent] substringToIndex:([[[[APP_DELEGATE appAudioPlayer] url] lastPathComponent] length] - 4)];
    NSLog(@"Playing \"%@\"", videoID);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDictionary* videoInfos = [[NSDictionary alloc] initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", videoID]]];
    //NSLog(@"%@", videoInfos);
    
    
    NSNumber* elapsedTime;
    
    if (previousTrack) {
        elapsedTime = [NSNumber numberWithDouble:0.0];
        [APP_DELEGATE.appAudioPlayer setCurrentTime:0.0];
    } else {
        elapsedTime = [NSNumber numberWithDouble:/*120.0*/APP_DELEGATE.appAudioPlayer.currentTime];
    }
    
    NSLog(@"startPlayingTrack = %@", APP_DELEGATE.appAudioPlayer.url);

    NSLog(@"Title: %@", [[[[[videoInfos objectForKey:@"items"] objectAtIndex:0] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"standard"]);
    
    MPMediaItemArtwork* artwork;
    if ([[NSURL URLWithString:[[[[[[videoInfos objectForKey:@"items"] objectAtIndex:0] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"standard"] objectForKey:@"url"]] checkResourceIsReachableAndReturnError:nil]) {
    
    artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[[[videoInfos objectForKey:@"items"] objectAtIndex:0] objectForKey:@"snippet"] objectForKey:@"thumbnails"] objectForKey:@"standard"] objectForKey:@"url"]]]]];
    
    } else{
        artwork = [[MPMediaItemArtwork alloc] init];
    }
    
    NSNumber* playbackRate = [NSNumber numberWithUnsignedInteger:1];
    
    NSArray *objectValues = [NSArray arrayWithObjects:
                             [[[[videoInfos objectForKey:@"items"] objectAtIndex:0] objectForKey:@"snippet"] objectForKey:@"title"],
                             [[[[videoInfos objectForKey:@"items"] objectAtIndex:0] objectForKey:@"snippet"] objectForKey:@"channelTitle"],
                             playbackRate,
                             [NSNumber numberWithDouble:/*120.0*/APP_DELEGATE.appAudioPlayer.duration],
                             elapsedTime,
                             artwork,
                             nil];
    
    NSArray *keys = [NSArray arrayWithObjects:
                     MPMediaItemPropertyTitle,
                     MPMediaItemPropertyArtist,
                     MPNowPlayingInfoPropertyPlaybackRate,
                     MPMediaItemPropertyPlaybackDuration,
                     MPNowPlayingInfoPropertyElapsedPlaybackTime,
                     MPMediaItemPropertyArtwork,
                     nil];
    
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:objectValues forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
        
    
}


-(void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [APP_DELEGATE.appAudioPlayer pause];
                [self refreshNowPlayingInfoCenterPreviousTrack:NO];
                NSLog(@"Pause");
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [APP_DELEGATE.appAudioPlayer play];
                [self refreshNowPlayingInfoCenterPreviousTrack:NO];
                NSLog(@"Play");
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [APP_DELEGATE.appAudioPlayer pause];
                [APP_DELEGATE.appAudioPlayer setCurrentTime:0];
                [self refreshNowPlayingInfoCenterPreviousTrack:YES];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                //[self nextTrack: nil];
                break;
                
            default:
                break;
        }
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
