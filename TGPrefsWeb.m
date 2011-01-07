#import "Preferences.h"

@implementation TGPrefsWeb

- (id)init {
	if ((self = [super init])) {
		_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		_webView.backgroundColor = [UIColor groupTableViewBackgroundColor];
		_webView.delegate = self;
		
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityView.center = CGPointZero;
		_activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
		[_webView addSubview:_activityView];
		[_activityView release];
		
		[self fixShadows];
	}
	return self;
}

- (void)loadView {
	self.view = _webView;
}

- (void)dealloc {
	_webView.delegate = nil;
	[_webView stopLoading];
	[_activityView stopAnimating];
	[_webView release]; _webView = nil;
	[super dealloc];
}

- (void)loadURL:(NSURL *)url {
	[self fixShadows];
	[_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)fixShadows {
	for(UIView *aView in [[[_webView subviews] objectAtIndex:0] subviews]) { 
		if([aView isKindOfClass:[UIImageView class]]) { aView.hidden = YES; } 
	}  	
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	[self fixShadows];
	NSURL *url = [request URL];
	NSString *urlString = [url absoluteString];
	if ([urlString isEqualToString:@"about:blank"])
		return YES;
	if ([urlString hasPrefix:@"http://dizzytechnology.com/"])
		return YES;
	if ([urlString hasPrefix:@"http://dizzyte.ch/"])
		return YES;
	if ([urlString hasPrefix:@"http://rpetri.ch/"])
		return YES;
	[[UIApplication sharedApplication] openURL:url];
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self fixShadows];
	[_activityView stopAnimating];
	_activityView.hidden = YES;
}

@end