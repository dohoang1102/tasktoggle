#import "Preferences.h"

@implementation TGSwitchCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_switch = [[UISwitch alloc] initWithFrame:CGRectZero];
 		[_switch addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = _switch;   
	}
	return self;
}

- (void)dealloc {
	if (_switch) {
		[_switch release];
		_switch = nil;
	}
	[super dealloc];
}

- (void)valueChanged {
	id value = [NSNumber numberWithBool:_switch.on];
	[[self delegate] switchCell:self didChangeToValue:value];
}

- (void)setOn:(BOOL)isOn {
	if (isOn != _switch.on)
		_switch.on = isOn;
}

- (BOOL)on {
	return _switch.on;
}

@end