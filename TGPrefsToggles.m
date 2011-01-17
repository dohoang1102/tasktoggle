#import "Preferences.h"
#include <dlfcn.h>

@implementation TGPrefsToggles

@synthesize enabledToggles = _enabledToggles, disabledToggles = _disabledToggles; 

- (id)init {
	if ((self = [super init])) {
		self.navigationItem.title = [sharedTaskToggle localizedString:@"Manage Toggles"];
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.enabledToggles = [[NSMutableArray alloc] initWithArray:[sharedTaskToggle _getObjectForPreference:@"TaskToggleEnabledToggles"]];
		fileManager = [[NSFileManager alloc] init];

		NSMutableArray *tempArray = [NSMutableArray array];
		[[fileManager contentsOfDirectoryAtPath:sharedTaskToggle.togglePath error:nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *toggleLibPath = [[sharedTaskToggle.togglePath stringByAppendingPathComponent:obj] stringByAppendingPathComponent:@"Toggle.dylib"];
			void *dylib = dlopen([toggleLibPath UTF8String], RTLD_LAZY);
			if (dylib == NULL) return;
			void *is_capable = dlsym(dylib, "isCapable");
			if (is_capable == NULL) return;
			if (((BOOL (*)(void)) is_capable)()) {
				[tempArray addObject:[NSString stringWithString:[(NSString *)obj lastPathComponent]]];
		}}];
		[sharedTaskToggle removeBannedTogglesFromArray:tempArray];
		[tempArray removeObjectsInArray:self.enabledToggles];
		self.disabledToggles = tempArray;
		NSLog(@"Well:  %@", self.enabledToggles, self.disabledToggles);
	}
	return self;
}

- (void)dealloc {
	[fileManager release]; fileManager = nil;
	self.enabledToggles = nil;
	self.disabledToggles = nil;
	[_cachedArray release]; _cachedArray = nil;
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.enabledToggles.count + self.disabledToggles.count);
}

- (void)setEditing:(BOOL)isEditing animated:(BOOL)animated {
	[_tableView setEditing:isEditing animated:animated];
	[super setEditing:isEditing animated:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DZToggles"];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DZToggles"] autorelease];
		cell.indentationLevel = 1;
		[cell.contentView.layer addSublayer:[CALayer layer]];
		
		UISwitch *optionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 105, (cell.contentView.frame.size.height - 27) * 0.5, 97, 27)];
		optionSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[optionSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = optionSwitch;
		[optionSwitch release];
	}

	NSString *name;
	if (indexPath.row > self.enabledToggles.count) {
		name = [self.disabledToggles objectAtIndex:(indexPath.row - self.enabledToggles.count)];
	} else {
		name = [self.enabledToggles objectAtIndex:indexPath.row];
	}
	BOOL enabled = ([self.enabledToggles indexOfObject:name] != NSNotFound);
	cell.textLabel.text = name;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[(UISwitch *)cell.accessoryView setTag:indexPath.row];
	[(UISwitch *)cell.accessoryView setOn:enabled];
	
	NSString *imagePath = [sharedTaskToggle imageForToggleNamed:name enabled:enabled];
	if (imagePath) {
		cell.indentationWidth = 52.0f;
		CALayer *contentLayer = cell.contentView.layer;
		CALayer *imageLayer = [contentLayer.sublayers objectAtIndex:0];
		imageLayer.frame = CGRectMake(8.0f, 8.0f, 44.0f, 44.0f);
		imageLayer.contents = (id)[[UIImage imageWithContentsOfFile:imagePath] CGImage];
	}

	return cell;
}

- (void)switchAction:(id)sender {
	[self setEditing:NO animated:YES];
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[(UISwitch *)sender tag] inSection:0];
	NSIndexPath *newIndexPath;
	// NSInteger max = self.disabledToggles.count + self.enabledToggles.count;
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
	NSString *name = cell.textLabel.text;
	BOOL enabled;
	if ([self.enabledToggles indexOfObject:name] != NSNotFound) {
		[self.enabledToggles removeObject:name];
		[self.disabledToggles addObject:name];
		[self.disabledToggles sortUsingSelector:@selector(caseInsensitiveCompare:)];
		newIndexPath = [NSIndexPath indexPathForRow:[self.disabledToggles indexOfObject:name]+[self.enabledToggles count]-1 inSection:0];
		enabled = NO;
	} else {	
		[self.disabledToggles removeObject:name];
		[self.enabledToggles addObject:name];
		newIndexPath = [NSIndexPath indexPathForRow:[self.enabledToggles indexOfObject:name] inSection:0];
		enabled = YES;
	}
	[_tableView beginUpdates];
	[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oldIndexPath] withRowAnimation:UITableViewRowAnimationTop];
	[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
	
	/*NSMutableArray *tableUpdates = [NSMutableArray arrayWithCapacity:4];
	if (oldIndexPath.row != 0)
		[tableUpdates addObject:[NSIndexPath indexPathForRow:oldIndexPath.row-1 inSection:0]];
	if (oldIndexPath.row != max)
		[tableUpdates addObject:[NSIndexPath indexPathForRow:oldIndexPath.row+1 inSection:0]];
	if (newIndexPath.row != 0)
		[tableUpdates addObject:[NSIndexPath indexPathForRow:newIndexPath.row-1 inSection:0]];
	if (newIndexPath.row != max)
		[tableUpdates addObject:[NSIndexPath indexPathForRow:newIndexPath.row+1 inSection:0]];
	[_tableView reloadRowsAtIndexPaths:tableUpdates withRowAnimation:UITableViewRowAnimationFade];*/
	[_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	[_tableView endUpdates];
	[_tableView reloadData];
	[[cell.contentView.layer.sublayers objectAtIndex:0] setContents:(id)[[UIImage imageWithContentsOfFile:[sharedTaskToggle imageForToggleNamed:name enabled:enabled]] CGImage]];
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:self.enabledToggles, @"value", @"TaskToggleEnabledToggles", @"preference", nil];
	[[CPDistributedMessagingCenter centerNamed:@"dizzytech.tasktoggle"] sendMessageName:@"setObjectForPreference" userInfo:info];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row < self.enabledToggles.count);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.enabledToggles exchangeObjectAtIndex:toIndexPath.row withObjectAtIndex:fromIndexPath.row];	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:self.enabledToggles, @"value", @"TaskToggleEnabledToggles", @"preference", nil];
	[[CPDistributedMessagingCenter centerNamed:@"dizzytech.tasktoggle"] sendMessageName:@"setObjectForPreference" userInfo:info];
}

@end