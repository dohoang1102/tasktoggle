#import "Preferences.h"
#import <CaptainHook/CaptainHook.h>

@implementation TGPrefsBase

@synthesize viewController = _viewController;

- (id)initForContentSize:(CGSize)size {
	self = ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)]) ? [super initForContentSize:size] : [super init];
	if (self) {
		_contentSize = size;
	}
	return self;
}

- (void)dealloc {
	_viewController.delegate = nil;
	self.viewController = nil;
	[super dealloc];
}

- (TGPrefsViewController *)viewController {
	if (!_viewController) {
		self.viewController = [TGPrefsRoot controller];
		self.viewController.delegate = self;
	}
	return _viewController;
}

- (void)setViewController:(TGPrefsViewController *)vc {
	if (![vc isEqual:_viewController]) {
		// Don't waste time; don't send messages to _viewController if it's not anything
		if (_viewController) {
			_viewController.delegate = nil;
			[_viewController release];
		}
		_viewController = [vc retain];
		if (_viewController) {
			UIView *theView = vc.view;
			theView.frame = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
			theView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			vc.delegate = self;
		}
	}
}

- (void)pushViewController:(TGPrefsViewController *)vc {
	TGPrefsBase *newController = [[TGPrefsBase alloc] initForContentSize:_contentSize];
	vc.delegate = newController;
	newController.viewController = vc;
	newController.parentController = self;
	newController.rootController = self.rootController;
	[self pushController:newController];
	[self.viewController retain];
	[newController release];
}

-(id)navigationTitle {
	return self.viewController.navigationItem.title;
}

-(id)navigationItem {
	return self.viewController.navigationItem;
}

-(id)view {
	return self.viewController.view;
}

-(void)navigationBarButtonClicked:(int)tag {
	if ([self.viewController shouldOverrideNavigationButtons])
		[self.viewController navigationButtonPressed:tag];
	else
		[super navigationBarButtonClicked:tag];
}

/*-(void)viewDidBecomeVisible {
	[self.viewController viewDidAppear:YES];
	[super viewDidBecomeVisible];
}

-(void)viewWillBecomeVisible:(void*)view {
	[self.viewController viewWillAppear:YES];
	[super viewWillBecomeVisible:view];
}*/

-(void)suspend {
	NSLog(@"Settings will suspend while TGPrefs is up.");
	//UINavigationController *navigationController = [(id)[UIApplication sharedApplication] rootController];
	//while ([navigationController.topViewController isKindOfClass:self])
	//	[navigationController popViewControllerAnimated:NO];
	[super suspend];
}

@end

/*
// in a protocol: -(void)viewWillRedisplay;
// in a protocol: -(void)didLock;
// in a protocol: -(void)willUnlock;
// in a protocol: -(void)didUnlock;
// in a protocol: -(void)didWake;

*/

CHConstructor
{
	CHAutoreleasePoolForScope();
	NSLog(@"TGPrefs: Loaded in settings");
	//[[NSNotificationCenter defaultCenter] addObserver:[ActivatorPSViewControllerHost class] selector:@selector(popAllControllers) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
}