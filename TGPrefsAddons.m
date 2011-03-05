#import "Preferences.h"

@implementation TGPrefsAddons

- (id)init {
	if ((self = [super init])) {
		self.navigationItem.title = [sharedTaskToggle localizedString:@"Toggle Extensions"];
		fileManager = [[NSFileManager alloc] init];
	}
	return self;
}

- (void)loadView {
	self.tableView.allowsSelection = NO;
	[super loadView];
}

- (void)viewDidLoad {
	NSMutableArray *tempExtensions = [NSMutableArray array];
	[[fileManager contentsOfDirectoryAtPath:sharedTaskToggle.extensionPath error:nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (([[obj pathExtension] isEqualToString:@"plist"])
		&& ([sharedTaskToggle.essentialExtensions indexOfObjectIdenticalTo:obj] == NSNotFound)) {
			NSLog(@"contents:  %@ %@ %@", obj, [obj pathExtension], [obj stringByDeletingPathExtension]);

			NSString *extName = [obj stringByDeletingPathExtension];
			NSString *extFileName = [extName stringByAppendingPathExtension:@"dylib"];
			NSString *extPath = [sharedTaskToggle.extensionPath stringByAppendingPathComponent:extFileName];
			NSNumber *extExists = [NSNumber numberWithBool:[fileManager fileExistsAtPath:extPath]];
			
			NSMutableDictionary *dictionaryToAdd = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				extName, @"Name",
				extPath, @"Path",
				extExists, @"Enabled",
				[NSNumber numberWithBool:NO], @"Changed",
			nil];
			
			[tempExtensions addObject:dictionaryToAdd];
		}
	}];
	extensions = [[NSArray alloc] initWithArray:tempExtensions];
}

- (void)dealloc {
	[fileManager release]; fileManager = nil;
	[extensions release]; extensions = nil;
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [extensions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSDictionary *myDict = [extensions objectAtIndex:indexPath.row];
	cell.textLabel.text = [myDict objectForKey:@"Name"];
	
	UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
 	[mySwitch addTarget:self action:@selector(_toggleSettingsChanged:) forControlEvents:UIControlEventValueChanged];
	mySwitch.tag = indexPath.row;
	mySwitch.on = [[myDict objectForKey:@"Enabled"] boolValue];
	cell.accessoryView = mySwitch;
	[mySwitch release];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)_toggleSettingsChanged:(UISwitch *)sender {
	NSMutableDictionary *myDict = [extensions objectAtIndex:sender.tag];
	if ([[myDict objectForKey:@"Changed"] boolValue]) {
		_numberChanged--;
		[myDict setObject:[NSNumber numberWithBool:NO] forKey:@"Changed"];
	} else {
		_numberChanged++;
		[myDict setObject:[NSNumber numberWithBool:YES] forKey:@"Changed"];
	}
	[myDict setObject:([NSNumber numberWithBool:sender.on]) forKey:@"Enabled"];
	if (_numberChanged > 0) {
		if ((_numberChanged == 1) || (_buttonsChanged == NO)) {
	        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(settingsConfirmButtonClicked:)];
	        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(settingsConfirmButtonClicked:)];
	        cancelButton.tag = 0;
	        respringButton.tag = 1;
	        [self.navigationItem setLeftBarButtonItem:respringButton animated:YES];
	        [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
	        [respringButton release];
	        [cancelButton release];
	        _buttonsChanged = YES;
		}
	} else {
		[self cancel:NO];
	}
}

- (void) settingsConfirmButtonClicked:(UIBarButtonItem *)button {
    [self navigationButtonPressed:button.tag];
}

- (void)cancel:(BOOL)usesBackup {
	if (usesBackup) {
		for (int i=0; i < [self.tableView numberOfRowsInSection:0]; i++) {
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
				UISwitch *aSwitch = (UISwitch *)cell.accessoryView;
				if ([[[extensions objectAtIndex:i] objectForKey:@"Changed"] boolValue]) {
					[aSwitch setOn:![[[extensions objectAtIndex:i] objectForKey:@"Enabled"] boolValue] animated:YES];
					[self _toggleSettingsChanged:aSwitch];
				}
			}
		}
	}

	[[self navigationItem] setLeftBarButtonItem:nil animated:YES];
	[[self navigationItem] setRightBarButtonItem:nil animated:YES];
	_buttonsChanged = NO;
}

- (BOOL)shouldOverrideNavigationButtons {
	return (_numberChanged > 0);
}

- (void)navigationButtonPressed:(int)tag {
    if (tag == 0) {
        [self cancel:YES];
        return;
    } else {
		if (_numberChanged == 0)
			return;

		_numberChanged = 0;

		for (NSMutableDictionary *myDict in extensions) {
			if ([[myDict objectForKey:@"Changed"] boolValue]) {
				NSString *extName = [myDict objectForKey:@"Name"];				
				NSString *command = [NSString stringWithFormat:@"/usr/libexec/tasktoggle/setuid /usr/libexec/tasktoggle/toggle_dylib.sh %@", extName];
				system([command UTF8String]);
			}
		}
		[[CPDistributedMessagingCenter centerNamed:@"dizzytech.tasktoggle"] sendMessageName:@"respring" userInfo:nil];
	}
}

@end