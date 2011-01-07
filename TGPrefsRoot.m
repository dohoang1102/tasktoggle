#import "Preferences.h"

@implementation TGPrefsRoot

-(id)init {
	if ((self = [super init])) {
		self.navigationItem.title = [sharedTaskToggle localizedString:@"TaskToggle"];
		self.tableView.rowHeight = 60.0f;
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
	case 0: return 3; break;
	case 1: return 3; break;
	case 2: return 2; break;
	default: return 0; break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return [sharedTaskToggle localizedString:@"TaskToggle Setup"]; break;
		case 1: return [sharedTaskToggle localizedString:@"System Options"]; break;
		case 2: return [sharedTaskToggle localizedString:@"Miscellaneous"]; break;
		default: return nil; break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Manage Toggles"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Which buttons will be shown"];
			break;
			}
			case 1: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Set Theme"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"How the switcher will appear"];
			break;
			}
			case 2: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"TaskToggle Preferences"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Other built-in options"];
			break;
			}
			default: break;
		}
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Hidden Apps"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Safely hide apps from SpringBoard"];
			break;
			}
			case 1: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Toggle Extensions"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Disable Cydia Substrate extensions"];
			break;
			}
			case 2: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"System Options"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"OS tweaks unrelated to TaskToggle"];
			break;
			}
			default: break;
		}
	} else if (indexPath.section == 2) {
		switch (indexPath.row) {
			case 0: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Reset TaskToggle"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Set all preferences to their default."];
				cell.accessoryType = UITableViewCellAccessoryNone;
			break;
			}
			case 1: {
				cell.textLabel.text = [sharedTaskToggle localizedString:@"Get More Toggles"];
				cell.detailTextLabel.text = [sharedTaskToggle localizedString:@"Find TaskToggle add-ons in Cydia!"];
			break;
			}
			default: break;
		}
	} 
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TGPrefsViewController *new = nil;
	if (indexPath.section == 0) {
		switch (indexPath.row) {
				//TGPrefsPoofDataSource *preDataSource = [[TGPrefsPoofDataSource alloc] init];
				//[self.view.window setUserInteractionEnabled:NO];
				//[preDataSource preloadToggleStates];				
				//UITableView *preTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
				//preDataSource.tableView = preTableView;
				//preTableView.dataSource = preDataSource;
				//[self.view.window setUserInteractionEnabled:YES];
				//controller = [[[TGPrefsPoof alloc] initWithPreloadedTableView:preTableView] autorelease];
			case 0: new = [TGPrefsToggles controller]; break;
			case 1: new = [TGPrefsTheme controller]; break;
			case 2: new = [TGPrefsSelf controller]; break;
			default: break;
		}
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0: new = [TGPrefsPoof controller]; break;
			case 1: new = [TGPrefsAddons controller]; break;
			case 2: new = [TGPrefsSystem controller]; break;
			default: break;
		}
	} else if (indexPath.section == 2) {
		switch (indexPath.row) {
			case 0: { 
				UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:[sharedTaskToggle localizedString:@"Reset Warning"] message:@"Are you sure you want to reset TaskToggle?  SpringBoard will restart immediately." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
				[resetAlert show];
				[resetAlert release];
			}
			break;
			case 1: {
				TGPrefsWeb *web = [TGPrefsWeb controller];
				web.navigationItem.title = [sharedTaskToggle localizedString:@"More Toggles"];
				[web loadURL:sharedTaskToggle.moreTogglesURL];
				new = web;
				break;
			}
			default: break;
		}
	}
	if (!new)
		return;
	[self pushController:new];
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[CPDistributedMessagingCenter centerNamed:@"dizzytech.tasktoggle"] sendMessageName:@"resetPreferences" userInfo:nil];
	}
}

@end