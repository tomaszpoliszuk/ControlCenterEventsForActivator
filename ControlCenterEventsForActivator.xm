#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

#include <dispatch/dispatch.h>
#include <objc/runtime.h>

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *ControlCenterOpened = @"Control Center Opened";
static NSString *ControlCenterClosed = @"Control Center Closed";

@interface ControlCenterDataSource : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation ControlCenterDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
+ (void)load {
	[self sharedInstance];
}
- (id)init {
	if (self = [super init]) {
		[LASharedActivator registerEventDataSource:self forEventName:ControlCenterOpened];
		[LASharedActivator registerEventDataSource:self forEventName:ControlCenterClosed];
	}
	return self;
}
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:ControlCenterOpened]) {
		return @"Opened";
	} else if ([eventName isEqualToString:ControlCenterClosed]) {
		return @"Closed";
	}
	return @" ";
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Control Center";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if ([eventName isEqualToString:ControlCenterOpened]) {
		return @"Open Control Center";
	} else if ([eventName isEqualToString:ControlCenterClosed]) {
		return @"Close Control Center";
	}
	return @" ";
}
- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:ControlCenterOpened];
	[LASharedActivator unregisterEventDataSourceWithEventName:ControlCenterClosed];
	[super dealloc];
}
@end

%hook SBControlCenterController
- (void)_willPresent {
	LASendEventWithName(ControlCenterOpened);
}

//	TODO - add support for iOS 11+ using _didDismiss because _willDismiss exists only in iOS 13+
//	- (void)_didDismiss {
//		LASendEventWithName(ControlCenterClosed);
//	}

//	iOS 13+
- (void)_willDismiss {
	LASendEventWithName(ControlCenterClosed);
}
%end
