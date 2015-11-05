//
//  ViewController.m
//  BlocBrowser
//
//  Created by Venugopal Narayanabhatla on 11/2/15.
//  Copyright © 2015 Venugopal Narayanabhatla. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>
 #import "AwesomeFloatingToolbar.h"


 @interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

 @property (nonatomic, strong) WKWebView *webView;
 @property (nonatomic, strong) UITextField *textField;

//@property (nonatomic, strong) UIButton *backButton;
//@property (nonatomic, strong) UIButton *forwardButton;
//@property (nonatomic, strong) UIButton *stopButton;
//@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
 @property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;


#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")



@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];

}


- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}


- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:NSLocalizedString(@"Back", @"Back command")]) {
        [self.webView goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward command")]) {
        [self.webView goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop command")]) {
        [self.webView stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload command")]) {
        [self.webView reload];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    UIView *mainView = [UIView new];
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    
      for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar])  {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}



- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // First, calculate some dimensions.
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);

    
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    // Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    // Ensure URL is properly ending .com
    
    if ([URLString hasSuffix:@".com"]){
        
        
        NSURL *URL = [NSURL URLWithString:URLString];
        
        
        
        if (!URL.scheme) {
            // The user didn't type http: or https:
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
        
        if (URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webView loadRequest:request];
        }
    }
    
    //If text entered does not end with .com treat it as a search string for google url. Additionally if the string has empty spaces replace with +
    else
    {
        NSString *gSearch = @"http://www.google.com/search?q=";
        NSString *refinedURLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", gSearch,refinedURLString ]];
        
        
        
        if (!URL.scheme) {
            // The user didn't type http: or https:
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
        
        if (URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webView loadRequest:request];
        }
        
    }
    
    return NO;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView.title copy];
    if ([webpageTitle length]) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.URL.absoluteString;
    }
    
    if (self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];

}




@end
