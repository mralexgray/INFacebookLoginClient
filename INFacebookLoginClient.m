//
//  INFacebookLoginClient.m
//  INFacebookLoginClient
//
//  Created by Indragie Karunaratne on 2013-05-06.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INFacebookLoginClient.h"
#import "AFJSONRequestOperation.h"
#import "RequestUtils.h"

static NSString * const INFacebookLoginClientOAuthBaseURL = @"https://www.facebook.com/dialog/";
static NSString * const INFacebookLoginClientGraphBaseURL = @"https://graph.facebook.com/";
static NSString * const INFacebookLoginClientErrorDomain = @"INFacebookLoginClientErrorDomain";

@interface INFacebookAccessToken ()
@property (nonatomic, copy, readwrite) NSString *accessToken;
@property (nonatomic, strong, readwrite) NSDate *expiryDate;
@property (nonatomic, copy, readwrite) NSString *state;
@property (nonatomic, strong, readwrite) NSError *error;
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

@implementation INFacebookLoginClient {
	NSString *_stateVerificationUUID;
}

#pragma mark - Initialization

- (instancetype)initWithClientID:(NSString *)clientID
{
	if ((self = [super initWithBaseURL:[NSURL URLWithString:INFacebookLoginClientGraphBaseURL]])) {
		_clientID = [clientID copy];
		[self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
	}
	return self;
}

#pragma mark - Public API

- (NSURL *)authenticationURLForRedirectURI:(NSString *)redirectURI
							   permissions:(NSArray *)permissions
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:5];
	parameters[@"client_id"] = self.clientID;
	parameters[@"response_type"] = @"token";
	_stateVerificationUUID = [[NSUUID UUID] UUIDString];
	parameters[@"state"] = _stateVerificationUUID;
	if (redirectURI) parameters[@"redirect_uri"] = redirectURI;
	if (permissions) parameters[@"scope"] = [permissions componentsJoinedByString:@","];
	
	NSString *query = [NSString URLQueryWithParameters:parameters];
	NSString *baseURLString = [NSString stringWithFormat:@"%@oauth", INFacebookLoginClientOAuthBaseURL];
	NSURL *baseURL = [NSURL URLWithString:baseURLString];
	return [baseURL URLWithQuery:query];
}

- (INFacebookAccessToken *)accessTokenForRedirectURL:(NSURL *)URL
{
	NSDictionary *parameters = [URL.query URLQueryParameters];
	INFacebookAccessToken *token = [[INFacebookAccessToken alloc] initWithParameters:parameters];
	if (![token.state isEqualToString:_stateVerificationUUID]) {
		token.error = [self.class stateMismatchError];
	}
	_stateVerificationUUID = nil;
	return token;
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
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
	if (token) parameters[@"input_token"] = token;
	if (appToken) parameters[@"access_token"] = appToken;
	[self getPath:@"debug_token" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *dictionary) {
		INFacebookAccessTokenDebugInfo *info = [[INFacebookAccessTokenDebugInfo alloc] initWithParameters:parameters[@"data"]];
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
		self.state = parameters[@"state"];
		NSString *error = parameters[@"error"];
		if (error.length) {
			NSMutableDictionary *errorParameters = [NSMutableDictionary dictionaryWithCapacity:3];
			errorParameters[@"fb_error"] = error;
			NSString *errorReason = parameters[@"error_reason"];
			if (errorReason) errorParameters[NSLocalizedFailureReasonErrorKey] = errorReason;
			NSString *errorDescription = parameters[@"error_description"];
			if (errorDescription) errorParameters[NSLocalizedDescriptionKey] = errorDescription;
			self.error = [NSError errorWithDomain:INFacebookLoginClientErrorDomain code:0 userInfo:errorParameters];
		}
	}
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p accessToken:%@ expiryDate:%@ state:%@ error:%@>", NSStringFromClass(self.class), self, self.accessToken, self.expiryDate, self.state, self.error];
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
