<?php
/* 
Copyright (c) 2013, Indragie Karunaratne. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The OAuth spec doesn't support redirecting to URLs other than HTTP and HTTPS
but we want to redirect to an app-specific URI to notify it that the authentication
process has completed.

To work around this problem, this PHP script is used as the redirect instead (hosted
on a web server), which extracts the query fragment to the URL and redirects to the 
actual app URI.
*/
define("REDIRECT_URI", "in-facebook://auth");

// Extract the query fragment of the URL
$parts = parse_url($url);
parse_str($parts['query'], $query);

// Construct a new URL with the original query fragment
// and the modified redirect URI
$new_url = REDIRECT_URI . "?" . http_build_query($query, '', '&');

// Redirect to the new URL
header('Location : ' . $new_url, true, 303);
die();
?>