## INFacebookLoginClient
### Objective-C wrapper for authenticating through Facebook's web-based login flow

Facebook doesn't have official support for authenticating desktop apps through their OAuth-based login flow, but with some work, the web-based login flow can be used to authenticate desktop apps as well. This project provides a convenient wrapper class and sample application for doing so on OS X.

#### Dependencies

The following are dependencies that have been set up as submodules:

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [RequestUtils](https://github.com/nicklockwood/RequestUtils)

#### Requirements

- ARC (Automatic Reference Counting)
- A web server with PHP installed


#### Instructions

1. Register a URL scheme for your app. This will be used as the callback after the user has authenticated with Facebook. Look at the sample application for an example, which uses `in-facebook` as the scheme and `in-facebook://auth` as the redirect URI.
2. Modify the two parameters defined at the top of the included `facebook_auth_redirect.php` script, `$REDIRECT_URI` and `$SUCCESS_URL`. `$REDIRECT_URI` is the one you set up in your app (`in-facebook://auth` in the case of the sample app) and `$SUCCESS_URL` is the URL to redirect to after your user has completed authenticating.
3. Upload the `facebook_auth_redirect.php` script to your web server. Using an SSL certificate may be a good idea as you will be handling sensitive user credentials.
4. [Register a new application on Facebook](https://developers.facebook.com/apps/). Note the client secret and client ID for use later.
5. In the Advanced settings for your Facebook app, add the absolute URL to the `facebook_auth_redirect.php` script under **Valid OAuth redirect URIs**.
6. Create a new instance of `INFacebookLoginClient` using `-initWithClientID:clientSecret:` using the client ID & secret from your Facebook app configuration page.
7. Obtain an authentication URL by calling `-authenticationURLForRedirectURI:permissions`, where the redirect URI is the **absolute URL to your `facebook_auth_redirect.php` script**. Permissions are optional, a full list of permissions can be found [here](https://developers.facebook.com/docs/facebook-login/permissions/)
8. Open this URL in a browser using `NSWorkspace -openURL:` or inside a `WebView`.
9. Once the user has completed authentication, your app callback will be called (`-handleURLEvent:withReplyEvent:` in the sample app). Retrieve the URL as follows:

```
- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
	...
}

``` 

10. Call `INFacebookLoginClient -requestAccessTokenForRedirectURL:sucess:failure` with the URL. If successful, an `INFacebookAccessToken` object will be created.
11. Use the `accessToken` property of the `INFacebookAccessToken` to retrieve an OAuth token that can be used to make calls to the Facebook API.

#### Contact

* Indragie Karunaratne
* [@indragie](http://twitter.com/indragie)
* [http://indragie.com](http://indragie.com)

#### License

`INFacebookLoginClient` is licensed under MIT. See LICENSE.md for more information.