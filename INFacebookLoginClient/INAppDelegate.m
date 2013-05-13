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

static NSString * const INFacebookClientID = @"_YOUR_FACEBOOK_CLIENT_ID_";
static NSString * const INFacebookClientSecret = @"_YOUR_FACEBOOK_CLIENT_SECRET";
static NSString * const INFacebookClientRedirectURI = @"_PATH_TO_HOSTED_facebook_auth_redirect.php_";

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
	[_client requestAccessTokenForRedirectURL:url success:^(INFacebookAccessToken *token) {
		self.label.stringValue = @"Authenticated";
		NSLog(@"%@", token);
	} failure:^(NSError *error) {
		NSLog(@"%@", error);
	}];
}

- (IBAction)authenticate:(id)sender
{
	_client = [[INFacebookLoginClient alloc] initWithClientID:INFacebookClientID clientSecret:INFacebookClientSecret];
	// The redirect URI must match the one set at https://developers.facebook.com/apps/
	// A PHP script is used as the redirect URI instead of directly going to the in-facebook://auth URL
	// because OAuth doesn't support non-HTTP redirect URIs. The PHP script extracts the query fragment
	// and forwards it to the actual URI (in-facebook://auth)
	NSURL *authURL = [_client authenticationURLForRedirectURI:INFacebookClientRedirectURI permissions:nil];
	[[NSWorkspace sharedWorkspace] openURL:authURL];
}
@end