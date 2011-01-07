#import "Preferences.h"
#import "Tweak.h"
#import "TGSwitchCell.h"
#import <SpringBoard/SpringBoard.h>
#import <dlfcn.h>

@implementation TGPrefsPoofDataSource

@synthesize tableView = _tableView, preloadedStates = _preloadedStates;

- (void)preloadToggleStates {
	//NSNumber *iconSize = [NSNumber numberWithInteger:29];
	NSArray *descriptors = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[sharedTaskToggle localizedString:@"System Applications"], @"title",
			@"(isSystemApplication = TRUE) AND NOT (tags contains 'hidden')", @"predicate",
			//iconSize, @"icon-size",
			//@"TGSwitchCell", @"cell-class-name",
		nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[sharedTaskToggle localizedString:@"User Applications"], @"title",
			@"(isSystemApplication = FALSE) AND NOT (tags contains 'hidden')", @"predicate",
			//iconSize, @"icon-size",
			//@"TGSwitchCell", @"cell-class-name",
		nil], nil];
	NSLog(@"Blah.  %@", descriptors);
	//[self setSectionDescriptors:descriptors];
	// Hacky hacky hacky hax.
	NSInteger sections = [super numberOfSectionsInTableView:nil];
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:sections];
	int i;
	for (i = 0; i < sections; i++) {
		NSInteger rows = [super tableView:nil numberOfRowsInSection:i];
		NSMutableDictionary *myRows = [NSMutableDictionary dictionaryWithCapacity:rows];
		int j;
		for (j = 0; j < rows; j++) {
			NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
			NSString *identifier = [super displayIdentifierForIndexPath:myIndexPath];
			NSNumber *hidden = [self valueForDisplayIdentifier:identifier];
			[myRows setObject:hidden forKey:identifier];
		}
		[tempArray addObject:[[myRows copy] retain]];
	}
	self.preloadedStates = [tempArray copy];
	[tempArray release];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
	return cell;
}

- (id)valueForDisplayIdentifier:(NSString *)displayIdentifier {
	return [NSNumber numberWithBool:YES];
}

- (void)switchCell:(TGSwitchCell *)cell didChangeToValue:(id)newValue {
	if (libhidehandle == NULL) {
		libhidehandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	}
	if (libhidehandle != NULL) {
		NSIndexPath *myIndexPath = [_tableView indexPathForCell:cell];
		NSString *displayIdentifier = [self displayIdentifierForIndexPath:myIndexPath]; 
		BOOL newSet = [newValue boolValue];		
		BOOL (* operation)(NSString *appID) = (!newSet) ? dlsym(libhidehandle, "HideIconViaDisplayId") : dlsym(libhidehandle, "UnHideIconViaDisplayId");
		if (operation != NULL) {
			operation(displayIdentifier);
			NSMutableArray *tempCopy = [[NSMutableArray alloc] init];
			[tempCopy addObjectsFromArray:self.preloadedStates];
			
			NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
			[tempDict addEntriesFromDictionary:[tempCopy objectAtIndex:myIndexPath.section]];
			[tempDict setObject:newValue forKey:displayIdentifier];
			
			[tempCopy replaceObjectAtIndex:myIndexPath.section withObject:tempDict];
			self.preloadedStates = tempCopy;
			[tempDict release];
			[tempCopy release];
		}
	}	
}

- (void)dealloc {
	if (libhidehandle != NULL) {
		dlclose(libhidehandle);
		libhidehandle = NULL;
	}
	self.preloadedStates = nil;
	self.tableView = nil;
	[super dealloc];
}

@end

@implementation TGPrefsPoof

@synthesize dataSource = _dataSource;

- (id)init {
	if ((self = [super init])) {
		self.navigationItem.title = [sharedTaskToggle localizedString:@"Hidden Apps"];
	}
	return self;
}

- (id)initWithPreloadedTableView:(UITableView *)aTableView {
	if ((self = [self init])) {
		_tableView = aTableView;
		_dataSource = (id <TGSwitchCellDelegate, UITableViewDataSource>)_tableView.dataSource;
	}
	return self;
}

- (void)loadView {
	if (!_dataSource) {
		_dataSource = [[TGPrefsPoofDataSource alloc] init];
	}
	if (!_tableView) {
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		_dataSource.tableView = _tableView;
		_tableView.dataSource = _dataSource;
		_tableView.delegate = self;
	}
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_tableView setAllowsSelection:NO];
	self.view = _tableView;
}

- (void)dealloc {
	if (_dataSource) {
		[_dataSource release];
		_dataSource = nil;
	}
	[super dealloc];
}

- (void)viewDidUnload {
	if (_dataSource) {
		[_dataSource release];
		_dataSource = nil;
	}
	[super viewDidUnload];
}

@end

/*
	
	NSLog(@"Handle to libhide:  %p", libhidehandle);
	if (libhidehandle != NULL) {
		BOOL (*IsIconHidden)(NSString* Plist) = dlsym(libhidehandle, "IsIconHidden");
		BOOL (*libHideIcon)(NSString* Plist) = dlsym(libhidehandle, "HideIcon");
		BOOL (*libUnhideIcon)(NSString* Plist) = dlsym(libhidehandle, "UnHideIcon");
	}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[TGSwitchCell class]]) {
		[cell setDelegate:self];
		NSString *ident = [super displayIdentifierForIndexPath:indexPath];
		NSDictionary *cached = [self.preloadedStates objectAtIndex:indexPath.section];
		[cell setOn:[[cached objectForKey:ident] boolValue]];
	}
	return cell;
}

- (id)valueForDisplayIdentifier:(NSString *)displayIdentifier {
	if (libhidehandle == NULL) {
		libhidehandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	}
	
	if (libhidehandle != NULL) {
		if (isHidden == NULL) {
			isHidden = dlsym(libhidehandle, "IsIconHiddenDisplayId");
		}
		BOOL answer = YES;
		if (isHidden != NULL) {
			answer = !isHidden(displayIdentifier);
		}
		return [NSNumber numberWithBool:answer];
	}
	return [NSNumber numberWithBool:YES];
}
*/