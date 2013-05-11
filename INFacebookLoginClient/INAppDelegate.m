//
//  INAppDelegate.m
//  INFacebookLoginClient
//
//  Created by Indragie Karunaratne on 2013-05-06.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INAppDelegate.h"
#import "INFacebookLoginClient.h"

static NSString * const INFacebookClientID = @"321217921339012";

@implementation INAppDelegate {
	INFacebookLoginClient *_client;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
}

- (IBAction)authenticate:(id)sender
{
	INFacebookLoginClient *client = [[INFacebookLoginClient alloc] initWithClientID:INFacebookClientID];
	// The redirect URI must match the one set at https://developers.facebook.com/apps/
	NSURL *authURL = [client authenticationURLForRedirectURI:@"in-facebook://auth" permissions:nil];
	[[NSWorkspace sharedWorkspace] openURL:authURL];
}
@end