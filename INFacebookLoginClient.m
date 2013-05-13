//
//  INFacebookLoginClient.m
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

#import "INFacebookLoginClient.h"
#import "AFJSONRequestOperation.h"
#import "RequestUtils.h"

static NSString * const INFacebookLoginClientOAuthBaseURL = @"https://www.facebook.com/dialog/";
static NSString * const INFacebookLoginClientGraphBaseURL = @"https://graph.facebook.com/";
static NSString * const INFacebookLoginClientErrorDomain = @"INFacebookLoginClientErrorDomain";

@interface INFacebookAccessToken ()
@property (nonatomic, copy, readwrite) NSString *accessToken;
@property (nonatomic, strong, readwrite) NSDate *expiryDate;
- (instancetype)initWithParameters:(NSDictionary *)parameters;
@end

@interface INFacebookAccessTokenDebugInfo ()
@property (nonatomic, strong, readwrite) NSNumber *appID;
@property (nonatomic, copy, readwrite) NSString *appName;
@property (nonatomic, strong, readwrite) NSNumber *userID;
@property (nonatomic, strong, readwrite) NSDate *expiryDate;
@property (nonatomic, strong, readwrite) NSString *issueDate;
@property (nonatomic, assign, readwrite, getter = isValid) BOOL valid;
@property (nonatomic, strong, readwrite) NSArray *permissions;
@property (nonatomic, strong, readwrite) NSDictionary *metadata;
- (instancetype)initWithParameters:(NSDictionary *)parameters;
@end

@interface  INFacebookLoginClient ()
@property (nonatomic, copy) NSString *stateVerificationUUID;
@property (nonatomic, copy) NSString *redirectURI;
@end

@implementation INFacebookLoginClient

#pragma mark - Initialization

- (instancetype)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret
{
	if ((self = [super initWithBaseURL:[NSURL URLWithString:INFacebookLoginClientGraphBaseURL]])) {
		NSParameterAssert(clientID);
		NSParameterAssert(clientSecret);
		_clientID = [clientID copy];
		_clientSecret = [clientSecret copy];
		[self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
		[self setDefaultHeader:@"Accept" value:@"text/plain"];
	}
	return self;
}

#pragma mark - Public API

- (NSURL *)authenticationURLForRedirectURI:(NSString *)redirectURI
							   permissions:(NSArray *)permissions
{
	NSParameterAssert(redirectURI);
	self.redirectURI = [redirectURI copy];
	self.stateVerificationUUID = [[NSUUID UUID] UUIDString];
	
	NSMutableDictionary *parameters = [@{@"client_id": self.clientID, @"state" : self.stateVerificationUUID, @"redirect_uri" : self.redirectURI} mutableCopy];
	if (permissions) parameters[@"scope"] = [permissions componentsJoinedByString:@","];
	
	NSString *query = [NSString URLQueryWithParameters:parameters];
	NSString *baseURLString = [NSString stringWithFormat:@"%@oauth", INFacebookLoginClientOAuthBaseURL];
	NSURL *baseURL = [NSURL URLWithString:baseURLString];
	return [baseURL URLWithQuery:query];
}

- (void)requestAccessTokenForRedirectURL:(NSURL *)URL
								 success:(void(^)( INFacebookAccessToken *))success
								 failure:(void(^)( NSError *))failure
{
	NSParameterAssert(URL);
	NSDictionary *parameters = [URL.query URLQueryParameters];
	NSString *state = parameters[@"state"];
	NSString *error = parameters[@"error"];
	if (error.length) {
		NSMutableDictionary *errorParameters = [NSMutableDictionary dictionaryWithCapacity:3];
		errorParameters[@"fb_error"] = error;
		
		NSString *errorReason = parameters[@"error_reason"];
		if (errorReason) errorParameters[NSLocalizedFailureReasonErrorKey] = errorReason;
		
		NSString *errorDescription = parameters[@"error_description"];
		if (errorDescription) errorParameters[NSLocalizedDescriptionKey] = errorDescription;
		
		NSError *error = [NSError errorWithDomain:INFacebookLoginClientErrorDomain code:0 userInfo:errorParameters];
		if (failure) failure(error);
	} else if (![state isEqualToString:_stateVerificationUUID]) {
		if (failure) failure(self.class.stateMismatchError);
	} else {
		[self getPath:@"oauth/access_token" parameters:@{@"client_id" : self.clientID, @"client_secret" : self.clientSecret, @"redirect_uri" : _redirectURI, @"code" : parameters[@"code"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
			NSDictionary *parameters = [response URLQueryParameters];
			INFacebookAccessToken *token = [[INFacebookAccessToken alloc] initWithParameters:parameters];
			if (success) success(token);
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (failure) failure(error);
		}];
	}
	_stateVerificationUUID = nil;
	_redirectURI = nil;
}

+ (NSError *)stateMismatchError
{
	return [NSError errorWithDomain:INFacebookLoginClientErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"The state returned by the request does not match the original state UUID that was sent. This may indicate cross-site request forgery."}];
}

- (void)requestDebugInfoForAccessToken:(NSString *)token
							  appToken:(NSString *)appToken
							   success:(void(^)( INFacebookAccessTokenDebugInfo *))success
							   failure:(void(^)( NSError *))failure
{
	NSParameterAssert(token);
	NSParameterAssert(appToken);
	[self getPath:@"debug_token" parameters:@{@"input_token": token, @"access_token" : appToken} success:^(AFHTTPRequestOperation *operation, NSDictionary *dictionary) {
		INFacebookAccessTokenDebugInfo *info = [[INFacebookAccessTokenDebugInfo alloc] initWithParameters:dictionary[@"data"]];
		if (success) success(info);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) failure(error);
	}];
}

@end

@implementation INFacebookAccessToken

#pragma mark - Initialization

- (instancetype)initWithParameters:(NSDictionary *)parameters
{
	if ((self = [super init])) {
		self.accessToken = parameters[@"access_token"];
		NSString *expiryString = parameters[@"expires"];
		if (expiryString.length) {
			NSTimeInterval expirySeconds = [expiryString doubleValue];
			self.expiryDate = [NSDate dateWithTimeIntervalSinceNow:expirySeconds];
		}
	}
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p accessToken:%@ expiryDate:%@>", NSStringFromClass(self.class), self, self.accessToken, self.expiryDate];
}
@end

@implementation INFacebookAccessTokenDebugInfo

- (instancetype)initWithParameters:(NSDictionary *)parameters
{
	if ((self = [super init])) {
		self.appID = parameters[@"app_id"];
		self.appName = parameters[@"application"];
		self.expiryDate = [NSDate dateWithTimeIntervalSince1970:[parameters[@"expires_at"] doubleValue]];
		self.issueDate = [NSDate dateWithTimeIntervalSince1970:[parameters[@"issued_at"] doubleValue]];
		self.valid = [parameters[@"is_valid"] boolValue];
		self.metadata = parameters[@"metadata"];
		self.permissions = parameters[@"scopes"];
		self.userID = parameters[@"user_id"];
	}
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p appID:%@ appName:%@ expiryDate:%@ issueDate:%@ valid:%d metadata:%@ permissions:%@ userID%@>", NSStringFromClass(self.class), self, self.appID, self.appName, self.expiryDate, self.issueDate, self.valid, self.metadata, self.permissions, self.userID];
}
@end
