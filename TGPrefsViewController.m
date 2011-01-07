#import "Preferences.h"

@implementation TGPrefsViewController

@synthesize delegate = _delegate, tableView = _tableView;

+(id)controller {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	return [super initWithNibName:nil bundle:nil];
}

-(void)dealloc {
	if (_tableView) {
		_tableView.delegate = nil;
		_tableView.dataSource = nil;
		self.tableView = nil;
	}
	[super dealloc];
}

-(void)loadView {
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	_tableView.rowHeight = 60.0f;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	self.view = self.tableView;
}

-(void)viewDidUnload {
	if (_tableView) {
		_tableView.delegate = nil;
		_tableView.dataSource = nil;
		self.tableView = nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section; {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [aTableView dequeueReusableCellWithIdentifier:@"TGGenericTableViewCell"] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TGGenericTableViewCell"] autorelease];
}

- (NSString *)tableView:(UITableView *)aTableView titleForFooterInSection:(NSInteger)section {
	if (section == ([self numberOfSectionsInTableView:aTableView] - 1))
		return [sharedTaskToggle copyrightMessage];
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didRecieveMemoryWarning {

}

-(void)pushController:(TGPrefsViewController *)vc {
	if (self.delegate) {
		[self.delegate pushViewController:vc];
	} else {
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (BOOL)shouldOverrideNavigationButtons {
	return NO;
}

- (void)navigationButtonPressed:(int)tag {
	
}

@end