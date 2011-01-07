#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <QuartzCore/QuartzCore.h>
#import "Tweak.h"

extern DZTaskToggleController *sharedTaskToggle;
@class TGPrefsViewController;
@protocol TGSwitchCellDelegate;

@protocol TGPrefsViewControllerDelegate <NSObject>
- (void)pushViewController:(TGPrefsViewController *)vc;
@end

@interface TGPrefsBase : PSViewController <TGPrefsViewControllerDelegate> {
@private
	TGPrefsViewController *_viewController;
	CGSize _contentSize;
}

- (id)initForContentSize:(CGSize)size;
@property (nonatomic, retain) TGPrefsViewController *viewController;

@end

@interface TGPrefsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> { 
	UITableView *_tableView;
	id<TGPrefsViewControllerDelegate> _delegate;
}

+ (id)controller;
- (void)pushController:(TGPrefsViewController *)vc;
- (BOOL)shouldOverrideNavigationButtons;
- (void)navigationButtonPressed:(int)tag;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) id<TGPrefsViewControllerDelegate> delegate;

@end

@interface TGPrefsRoot : TGPrefsViewController <UIAlertViewDelegate> {
}
@end

@interface TGPrefsToggles : TGPrefsViewController {
	NSFileManager *fileManager;
	NSMutableArray *_enabledToggles;
	NSMutableArray *_disabledToggles;
	NSInteger _cachedCount;
	BOOL _orderChanged;
	NSArray *_cachedArray;
}
@property (nonatomic, readonly) NSArray *toggleArray;
@property (nonatomic, retain) NSMutableArray *enabledToggles;
@property (nonatomic, retain) NSMutableArray *disabledToggles;
@end

@interface TGPrefsTheme : TGPrefsViewController {
	NSArray *_themeArray;
}
@property (nonatomic, retain) NSArray *themeArray;
@end

@interface TGPrefsSelf : TGPrefsViewController {
}
@end

@interface TGPrefsPoof : TGPrefsViewController {
}
@end

@interface TGPrefsAddons : TGPrefsViewController {
	NSFileManager *fileManager;
	int _numberChanged;
	NSArray *extensions;
	NSArray *extensionsBackup;
	NSMutableArray *enabledExtensions;
}
- (void)cancel:(BOOL)usesBackup;
- (void) navigationButtonPressed:(int)buttonIndex;
@end

@interface TGPrefsSystem : TGPrefsViewController {
}
@end

@interface TGPrefsWeb : TGPrefsViewController <UIWebViewDelegate> {
	UIActivityIndicatorView *_activityView;
	UIWebView *_webView;
}
- (void)loadURL:(NSURL *)url;
- (void)fixShadows;
@end

@interface TGSwitchCell : UITableViewCell {
@private
	id<TGSwitchCellDelegate> delegate;
	UISwitch *_switch;
}

@property (nonatomic, assign) id<TGSwitchCellDelegate> delegate;
@property (nonatomic, assign) BOOL on;
@end

@protocol TGSwitchCellDelegate <NSObject>
- (void)switchCell:(TGSwitchCell *)cell didChangeToValue:(id)newValue;
@end






//////

/*@interface TGPrefsPoofDataSource : ALApplicationTableDataSource <TGSwitchCellDelegate> {
	UITableView *_tableView;
	void *libhidehandle;
	BOOL (* isHidden)(NSString* Plist);
	BOOL isLoaded;
	NSArray *_preloadedStates;	
}

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, retain) NSArray *preloadedStates;

- (id)valueForDisplayIdentifier:(NSString *)displayIdentifier;
- (void)preloadToggleStates;

@end

//////

@interface TGPrefsPoof : TGPrefsViewController {
	TGPrefsPoofDataSource *_dataSource;
}

@property (nonatomic, readonly) TGPrefsPoofDataSource *dataSource;

- (id)initWithPreloadedTableView:(UITableView *)aTableView;

@end*/