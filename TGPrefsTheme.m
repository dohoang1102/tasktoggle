#import "Preferences.h"

@implementation TGPrefsTheme

@synthesize themeArray = _themeArray;

-(id)init {
	if ((self = [super init])) {
		self.navigationItem.title = [sharedTaskToggle localizedString:@"Set Theme"];
		NSFileManager *tempManager = [[NSFileManager alloc] init];
		NSMutableArray *tempArray = [NSMutableArray array];
		[[tempManager contentsOfDirectoryAtPath:sharedTaskToggle.themePath error:nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[tempArray addObject:[obj lastPathComponent]];
		}];
		self.themeArray = tempArray;
		[tempManager release];
	}
	return self;
}

- (void)dealloc {
	self.themeArray = nil;
	[super dealloc];
}

- (void)viewDidLoad {
	self.tableView.allowsSelection = YES;
	NSString *activeTheme = [[sharedTaskToggle currentThemePath] lastPathComponent];
	NSInteger row = [self.themeArray indexOfObjectIdenticalTo:activeTheme];
	NSIndexPath *activeIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
	[self.tableView selectRowAtIndexPath:activeIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [self.themeArray count];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[sharedTaskToggle setObject:[self.themeArray objectAtIndex:indexPath.row] forPreference:@"TaskToggleTheme"];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSString *themeName = [self.themeArray objectAtIndex:indexPath.row];
	[sharedTaskToggle activateTogglesWithThemeName:themeName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSString *cellName = [self.themeArray objectAtIndex:indexPath.row];
	cell.textLabel.text = cellName;
	NSString *path = [[sharedTaskToggle.themePath stringByAppendingPathComponent:cellName] stringByAppendingPathComponent:@"blankon.png"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:path];
	cell.imageView.frame = CGRectMake(8.0f, 8.0f, 44.0f, 44.0f);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	return cell;
}

@end