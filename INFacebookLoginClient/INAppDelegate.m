//
//  INAppDelegate.m
//  INFacebookLoginClient
//
// Copyright (c) 2013, Indragie Karunaratne. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
// to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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