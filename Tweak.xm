#import "Tweak.h"
#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

//#include <dlfcn.h>
#include <sys/stat.h>
#include <notify.h>
#define CHUseSubstrate

DZTaskToggleController *sharedTaskToggle;

CHDeclareClass(SBAppSwitcherController);
CHDeclareClass(SBAppSwitcherBarView);
CHDeclareClass(SBIcon);
CHDeclareClass(SBUIController);
CHDeclareClass(SpringBoard);

#define SBApp (SpringBoard *)[CHClass(SpringBoard) sharedApplication]

@implementation DZTaskToggleController

+(DZTaskToggleController *)sharedController {
	if (!sharedTaskToggle) {
		sharedTaskToggle = [[DZTaskToggleController alloc] init];
	}
	return sharedTaskToggle;
}

-(id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		if (!(_preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:self.settingsFilePath]))
			_preferences = [[NSMutableDictionary alloc] init];

	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	[_preferences release]; _preferences = nil;
	[_mainBundle release]; _mainBundle = nil;
	
	[super dealloc];
}

-(NSString *)localizedString:(NSString *)aString {  // Kindly ask the pseudo-bundle at /Library/TaskToggle for some strings
	NSString *retr = [self.mainBundle localizedStringForKey:aString value:nil table:nil];
	if (retr)
		return retr;
	return aString;
}

- (void)didReceiveMemoryWarning { // Get rid of the buttons, etc.

}

// Preferences

- (id)objectForPreference:(NSString *)preference {
	id value = [_preferences objectForKey:preference];
	return value;
}

- (void)setObject:(id)value forPreference:(NSString *)preference {
	if (value)
		[_preferences setObject:value forKey:preference];
	else
		[_preferences removeObjectForKey:preference];
	if ([preference isEqualToString:@"TaskToggleEnabledToggles"]) {
		[self reloadToggles];
	}
	[self writePreferences];
}

- (void)writePreferences {
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)self.settingsFilePath, kCFURLPOSIXPathStyle, NO);
	CFWriteStreamRef stream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, url);
	CFRelease(url);
	CFWriteStreamOpen(stream);
	CFPropertyListWriteToStream((CFPropertyListRef)_preferences, stream, kCFPropertyListBinaryFormat_v1_0, NULL);
	CFWriteStreamClose(stream);
	CFRelease(stream);
	chmod([self.settingsFilePath UTF8String], S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH); 
	
}

-(void)reset {
	[_preferences removeAllObjects];
	[self writePreferences];
	[self fancyRespring];
}

// Paths

- (NSString *)settingsFilePath {
	return @"/var/mobile/Library/Preferences/TaskToggle.plist";
}

- (NSString *)togglePath {
	return @"/Library/TaskToggle/Toggles";
}

- (NSString *)extensionPath {
	return @"/Library/MobileSubstrate/DynamicLibraries";
}

- (NSString *)themePath {
	return @"/Library/TaskToggle/Themes";
}

- (NSString *)commandPath {
	return @"/Library/TaskToggle/Commands";
}

- (NSString *)currentThemePath {
	NSString *theme = [self objectForPreference:@"TaskToggleTheme"];
	if (theme == nil) {
		[self setObject:@"Default" forPreference:@"TaskToggleTheme"];
		theme = @"Default";
	}
	return [[self themePath] stringByAppendingPathComponent:theme];
}

// Utilities

- (BOOL)isPad {
	UIDevice *device = [UIDevice currentDevice];
	return (device.userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

- (NSURL *)moreTogglesURL {
	UIDevice *device = [UIDevice currentDevice];	
	NSString *url = [NSString stringWithFormat:@"http://rpetri.ch/cydia/activator/actions/?udid=%@&idiom=%d&version=%@&activator=%d", device.uniqueIdentifier, (NSInteger)[self isPad], device.systemVersion, [self version]];
	return [NSURL URLWithString:url];
}

- (NSInteger)numPages {
	return 1;
}

- (NSBundle *)mainBundle {
	if (!_mainBundle) {
		_mainBundle = [NSBundle bundleWithPath:@"/Library/TaskToggle"];
	}
	return _mainBundle;
}

- (DZTaskToggleVersion) version {
	return DZTaskToggleVersion_0_5;
}

- (NSString *)versionAsString {
	switch (self.version) {
		case DZTaskToggleVersion_0_5: return @"v0.5 Alpha"; break;
		case DZTaskToggleVersion_1_0: return @"v1.0"; break;
		case DZTaskToggleVersion_1_5: return @"v1.5"; break;
		default: return @"Beta"; break;
	}
}

-(NSString *)copyrightMessage { // Self-explanatory
	return [NSString stringWithFormat:@"%@ %@\n\u00A9 2011 Dizzy Technology\n%@", [self localizedString:@"TaskToggle"], self.versionAsString, [self localizedString:@"LOCALIZATION_ABOUT"]];
}

- (NSString *)imageForToggleNamed:(NSString *)name enabled:(BOOL)isEnabled {
	NSString *pathInTheme = [self.currentThemePath stringByAppendingPathComponent:name];
	NSString *imageURL;
	BOOL isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathInTheme isDirectory:&isDir] && isDir) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[pathInTheme stringByAppendingPathComponent:@"off.png"]] && !isEnabled)
			imageURL = [pathInTheme stringByAppendingPathComponent:@"off.png"];
		else
			imageURL = [pathInTheme stringByAppendingPathComponent:@"on.png"];
	} else 
		imageURL = [self.currentThemePath stringByAppendingPathComponent:(isEnabled ? @"blankon.png" : @"blankoff.png")];
	return [[NSFileManager defaultManager] fileExistsAtPath:imageURL] ? imageURL : nil;
}

// Actions

- (void)reloadToggles {
	NSLog(@"TaskToggle sez:  I would refresh the toggles right now!");
	[[DZTaskToggleView sharedView] addFarRightButtons];
}

- (void)removeBannedTogglesFromArray:(NSMutableArray *)array {
	//Data plan
	//Brightness (if iPad or iPhone with DarkMalloc's extension)
	//Volume (if iPad or iPhone without DM's extension)
}

- (NSArray *)essentialExtensions {
	return [NSArray arrayWithObjects:@"WinterBoard", @"PreferenceLoader", @"TaskToggle", @"DisplayStack", @"Activator", @"IconSuppoert", @"libstatusbar", nil];
}

- (void)refreshSpringBoardIcons {
	NSLog(@"Refreshing hidden icons...");
	notify_post("com.libhide.hiddeniconschanged");
}

- (void)fancyRespring {
	UIWindow *mainWindow = CHIvar(CHSharedInstance(SBUIController), _window, UIWindow *);
	mainWindow.userInteractionEnabled = NO;
    
	UIWindow *ultimateBlocker = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ultimateBlocker.windowLevel = 2000;
    ultimateBlocker.hidden = NO;
	UIView *blockerFade = [[UIView alloc] initWithFrame:ultimateBlocker.frame];
    blockerFade.alpha = 0.0;
    blockerFade.backgroundColor = [UIColor blackColor];
	[ultimateBlocker addSubview:blockerFade];
	[blockerFade release];
	[UIView animateWithDuration:1.5
		animations:^{ blockerFade.alpha = 1.0; }
		completion:^(BOOL finished){ 
			if ([SBApp respondsToSelector:@selector(relaunchSpringboard)]) 
				[SBApp relaunchSpringBoard];
			else
				system("killall -9 SpringBoard");
	}];
}

- (void)activateTogglesWithThemeName:(NSString *)theme {
	NSLog(@"Activating with theme:  %@", theme);
	if (theme) {
		
	}
	NSLog(@"Variables:  %p %p", SBApp, CHSharedInstance(SBUIController));
	[CHSharedInstance(SBUIController) activateSwitcher];
	//SBAppSwitcherBarView *bar = CHIvar(CHSharedInstance(SBAppSwitcherController), _bottomBar, SBAppSwitcherBarView *);
	//UIScrollView *scroll = CHIvar(bar, _scrollView, UIScrollView *);
	//[scroll setContentOffset:CGPointMake(0,0) animated:NO];	
}

// Button actions

-(void)showPowerMenu:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Power Options" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Power Off", @"Reboot", @"Safe Mode", @"Respring", nil];
	alert.tag = 1;
	[CHSharedInstance(SBUIController) dismissSwitcher];
	[alert show];
	[alert release];
}

-(void)showMoreMenu:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
	alert.tag = 2;
	[CHSharedInstance(SBUIController) dismissSwitcher];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 1: [SBApp powerDown]; break; // power off
			case 2: [SBApp reboot]; break; // reboot
			case 3: [SBApp relaunchSpringBoard]; break; // safe mode
			//case 4: [(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard]; break; // respring	
			case 4: [self fancyRespring]; break; // respring	
			default: case 0: [self activateTogglesWithThemeName:nil]; break; // cancel
		}
	} else if (actionSheet.tag == 2) {
		
	}
}

@end

@implementation DZTaskToggleView

@synthesize backgroundView = _backgroundView;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundView = [[UIView alloc] init];
		self.backgroundView.backgroundColor = [UIColor blueColor];
		self.backgroundView.alpha = 0.0;
		self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.backgroundView];
	}
	return self;
}

+ (DZTaskToggleView *)sharedView {
	if (!sharedToggleView) {
		sharedToggleView = [[DZTaskToggleView alloc] initWithFrame:CGRectMake(0,0,0,0)];
	}
	return sharedToggleView;
}

- (void)dealloc {
	[_backgroundView release]; _backgroundView = nil;
	[_powerButton release]; _powerButton = nil;
	[_powerButtonLabel release]; _powerButtonLabel = nil;
	[_moreButton release]; _moreButton = nil;
	[_moreButtonLabel release]; _moreButtonLabel = nil;
	[super dealloc];
}

- (void)addFarRightButtons {
	if (!_powerButton) { 
		_powerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_powerButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[_powerButton addTarget:sharedTaskToggle action:@selector(showPowerMenu:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_powerButton];
	}
	if (!_moreButton) { 
		_moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_moreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[_moreButton addTarget:sharedTaskToggle action:@selector(showMoreMenu:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_moreButton];
	}
	if (!_moreButtonLabel) {
		_moreButtonLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)] autorelease];
		_moreButtonLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_moreButtonLabel.textColor = [UIColor whiteColor];
		_moreButtonLabel.font = ([sharedTaskToggle isPad]) ? [UIFont boldSystemFontOfSize:11] : [UIFont boldSystemFontOfSize:10];
		_moreButtonLabel.textAlignment = UITextAlignmentCenter;
		_moreButtonLabel.shadowColor = [UIColor blackColor];
		_moreButtonLabel.shadowOffset = CGSizeMake(0,1);
		_moreButtonLabel.backgroundColor = [UIColor clearColor];
		_moreButtonLabel.text = @"More";
		[self addSubview:_moreButtonLabel];
	}
	if (!_powerButtonLabel) {
		_powerButtonLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)] autorelease];
		_powerButtonLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_powerButtonLabel.textColor = [UIColor whiteColor];
		_powerButtonLabel.font = ([sharedTaskToggle isPad]) ? [UIFont boldSystemFontOfSize:11] : [UIFont boldSystemFontOfSize:10];
		_powerButtonLabel.textAlignment = UITextAlignmentCenter;
		_powerButtonLabel.shadowColor = [UIColor blackColor];
		_powerButtonLabel.shadowOffset = CGSizeMake(0,1);
		_powerButtonLabel.backgroundColor = [UIColor clearColor];
		_powerButtonLabel.text = @"Power";
		[self addSubview:_powerButtonLabel];
	}
	
	NSString *powerButtonImagePath = [[sharedTaskToggle currentThemePath] stringByAppendingPathComponent:@"Power.png"];
	[_powerButton setImage:[UIImage imageWithContentsOfFile:powerButtonImagePath] forState:UIControlStateNormal];
	NSString *moreButtonImagePath = [[sharedTaskToggle currentThemePath] stringByAppendingPathComponent:@"Settings.png"];
	NSString *moreButtonDisabledImagePath = [[sharedTaskToggle currentThemePath] stringByAppendingPathComponent:@"SettingsNoUse.png"];
	[_moreButton setImage:[UIImage imageWithContentsOfFile:moreButtonImagePath] forState:UIControlStateNormal];
	[_moreButton setImage:[UIImage imageWithContentsOfFile:moreButtonDisabledImagePath] forState:UIControlStateDisabled];
	
	//116 px height
	if ([sharedTaskToggle isPad]) {
		_moreButton.frame = CGRectMake(self.frame.size.width - 34, 12, 30, 30);
		_moreButtonLabel.frame = CGRectMake(self.frame.size.width - 36, 44, 34, 12);
		_powerButton.frame = CGRectMake(self.frame.size.width - 34, 70, 30, 30);
		_powerButtonLabel.frame = CGRectMake(self.frame.size.width - 36, 102, 34, 12);
	} else {
		_moreButton.frame = CGRectMake(self.frame.size.width - 32, 6, 30, 30);
		_moreButtonLabel.frame = CGRectMake(self.frame.size.width - 34, 36, 34, 12);
		_powerButton.frame = CGRectMake(self.frame.size.width - 32, 50, 30, 30);
		_powerButtonLabel.frame = CGRectMake(self.frame.size.width - 34, 80, 34, 12);
	}
}


@end


%hook SBAppSwitcherBarView

-(void)dealloc {
	[sharedToggleView release];
	sharedToggleView = nil;
	%orig;
}

-(unsigned)_pageCount {
	return %orig + [sharedTaskToggle numPages];
}

-(void)layoutSubviews {
	%orig;
	UIScrollView *scrollView = CHIvar(self, _scrollView, UIScrollView *);
	CGFloat offset = self.frame.size.width * [sharedTaskToggle numPages];
	for (UIView *subview in scrollView.subviews) {
		if (![subview isEqual:[DZTaskToggleView sharedView]]) {
			CGRect frame = subview.frame;
			frame.origin.x += offset;
			subview.frame = frame;
		}
	}
}

-(void)_positionAtFirstPage:(BOOL)firstPage {
	%orig;
	UIScrollView *scrollView = CHIvar(self, _scrollView, UIScrollView *);
	CGPoint newOffset = scrollView.contentOffset;
	newOffset.x += (self.frame.size.width * [sharedTaskToggle numPages]);
	scrollView.contentOffset = newOffset;		
}

-(void)_reflowContent:(BOOL)content {
	%orig;
	DZTaskToggleView *toggleView = [DZTaskToggleView sharedView];
	if (!toggleView.superview) {
		UIScrollView *scrollView = CHIvar(self, _scrollView, UIScrollView *);
		toggleView.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width * [sharedTaskToggle numPages], self.frame.size.height);
		[scrollView addSubview:toggleView];
		if (toggleView.subviews.count <= 1) {
			[sharedTaskToggle reloadToggles];
		}
	}
}

-(void)scrollViewDidScroll:(id)scrollView {
	%orig;
	UIView *bgView = [DZTaskToggleView sharedView].backgroundView;
	CGFloat compareX = bgView.frame.origin.x + bgView.frame.size.width; // ex. 1024
	CGFloat compareLeft = [scrollView contentOffset].x; // ex 1000
	if (compareX > 0)
		bgView.alpha = (compareX < compareLeft) ? 0.0 : (compareX - compareLeft)/compareX;
}

%end

static void SBSCompat_Respring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	NSLog(@"An SBSettings toggle has asked for a respring.	Not honoring at the moment.  %@ %@", object, info);
}

static void SBSCompat_RefreshToggles(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	NSLog(@"An SBSettings toggle has asked for a toggle refresh.  Not honoring at the moment.  %@ %@", object, info);
}

CHConstructor
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	sharedTaskToggle = [[DZTaskToggleController alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &SBSCompat_Respring, (CFStringRef) @"com.sbsettings.respring", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &SBSCompat_RefreshToggles, (CFStringRef)@"com.sbsettings.refreshalltoggles", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CHLoadLateClass(SBAppSwitcherBarView);
	CHLoadLateClass(SBAppSwitcherController);
	CHLoadLateClass(SBIcon);
	CHLoadLateClass(SBUIController);
	CHLoadLateClass(SpringBoard);
	[pool release];
}
