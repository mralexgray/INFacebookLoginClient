//
//  INFacebookLoginClient.h
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

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@class INFacebookAccessToken;
@class INFacebookAccessTokenDebugInfo;
// Convenience class for assisting with the web-based Facebook login flow
@interface INFacebookLoginClient : AFHTTPClient

// Returns the Facebook client ID
@property (nonatomic, copy, readonly) NSString *clientID;

// Returns the Facebook client secret
@property (nonatomic, copy, readonly) NSString *clientSecret;

// Creates a new instance of `INFacebookLoginClient`
- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

// Constructs an authentication URL that can be opened in a web browser or WebView
//
// `redirectURI` - URL to redirect to once the user has submitted the form. Register a URL
// scheme for your app (http://stackoverflow.com/a/1991162/153112) and use that.
// IMPORTANT: This redirect URI must match what is set in https://developers.facebook.com/apps/.
//
// `permissions` - Array of NSString permission strings (optional)
//  Full list of permssions at https://developers.facebook.com/docs/facebook-login/permissions/
// 
- (NSURL *)authenticationURLForRedirectURI:(NSString *)redirectURI
							   permissions:(NSArray *)permissions;

// Creates an `INFacebookAccessToken` from a redirect URL that was opened by the Facebook
// login page. The Facebook login page should have been opened using the URL returned from
// a call to -authenticationURLForRedirectURI:state:permissions
- (void)requestAccessTokenForRedirectURL:(NSURL *)URL
								 success:(void(^)( INFacebookAccessToken *))success
								 failure:(void(^)( NSError *))failure;

// Asynchronously requests the debug information for an access token.
// Used to verify the validity of the token.
//
// `appToken` can be generated using these instructions:
// https://developers.facebook.com/docs/opengraph/howtos/publishing-with-app-token/
- (void)requestDebugInfoForAccessToken:(NSString *)token
							  appToken:(NSString *)appToken
							   success:(void(^)( INFacebookAccessTokenDebugInfo *))success
							   failure:(void(^)( NSError *))failure;
@end


// A model object class that represents an access token for the Facebook API
@interface INFacebookAccessToken : NSObject
// The OAuth access token used to access the Facebook API
@property (nonatomic, copy, readonly) NSString *accessToken;
// Date when the token expires
@property (nonatomic, strong, readonly) NSDate *expiryDate;
@end

// Model object class that represents debug information for an access token
// Useful for verifying the validity of an access token.

@interface INFacebookAccessTokenDebugInfo : NSObject
// App ID used to create the token
@property (nonatomic, strong, readonly) NSNumber *appID;
// Name of app used to create the token
@property (nonatomic, copy, readonly) NSString *appName;
// User ID that the access token was granted to
@property (nonatomic, strong, readonly) NSNumber *userID;
// Expiry date of the access token
@property (nonatomic, strong, readonly) NSDate *expiryDate;
// Date when the access token was issued
@property (nonatomic, strong, readonly) NSString *issueDate;
// Whether the access token is valid
@property (nonatomic, assign, readonly, getter = isValid) BOOL valid;
// Permissions available for the access token
@property (nonatomic, strong, readonly) NSArray *permissions;
// Arbitrary metadata
@property (nonatomic, strong, readonly) NSDictionary *metadata;
@end