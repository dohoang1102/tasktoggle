#import <UIKit/UIKit.h>

typedef enum {
    DZTaskToggleVersion_0_5 = 0050000,
    DZTaskToggleVersion_1_0 = 1000000,
    DZTaskToggleVersion_1_5 = 1050000
} DZTaskToggleVersion;

@interface DZTaskToggleController : NSObject <UIAlertViewDelegate>  {
	NSMutableDictionary *_preferences;
	NSBundle *_mainBundle;	
}

+(DZTaskToggleController *)sharedController;
-(NSString *)localizedString:(NSString *)aString;
-(void)_reset;
-(void)_writePreferences;
- (void)removeBannedTogglesFromArray:(NSMutableArray *)array;
- (void)_reloadToggles;
- (void)_refreshSpringBoardIcons;
- (void)fancyRespring;
- (void)activateToggles:(NSString *)theme;
- (NSString *)imageForToggleNamed:(NSString *)name enabled:(BOOL)isEnabled;

- (id)_getObjectForPreference:(NSString *)preference;
- (void)_setObject:(id)value forPreference:(NSString *)preference;

@property (nonatomic, readonly) NSBundle *mainBundle;


@property (nonatomic, readonly) NSString *settingsFilePath;
@property (nonatomic, readonly) NSString *togglePath;
@property (nonatomic, readonly) NSString *extensionPath;
@property (nonatomic, readonly) NSString *themePath;
@property (nonatomic, readonly) NSString *commandPath;
@property (nonatomic, readonly) NSString *currentThemePath;

@property (nonatomic, readonly) DZTaskToggleVersion version;
@property (nonatomic, readonly) NSString *versionAsString;
@property (nonatomic, readonly) NSString *copyrightMessage;
@property (nonatomic, readonly) NSURL *moreTogglesURL;
@property (nonatomic, readonly) NSArray *essentialExtensions;
@property (nonatomic, readonly) BOOL isPad;

@end

@interface DZTaskToggleView : UIView {
	UIView *_backgroundView;
	UIButton *_powerButton;
	UILabel *_powerButtonLabel;
	UIButton *_moreButton;
	UILabel *_moreButtonLabel;
}
+ (DZTaskToggleView *)sharedView;
- (void)addFarRightButtons;
@property (nonatomic, retain) UIView *backgroundView;
@end

DZTaskToggleView *sharedToggleView;
