# Getting Started with Smily Channel API

1. TOC
{:toc}

## Overview

This guide provides step-by-step instructions for making your first API call using cURL, along with examples in different programming languages.

## Prerequisites

Before you start using the API, complete the following steps:

  1. **Request a Demo Account**: Begin by requesting a demo account from the [Smily Partners Team](mailto:partners@smily.com). This account will grant you access to the API.
  2. **Get an API Key and Host details**: Obtain your API Key and host details from the [Smily Partners Team](mailto:partners@smily.com). These credentials are essential for authentication and making API requests.
  3. **Install cURL**: Ensure that you have [curl](https://curl.haxx.se/) installed on your machine :)

## Making Your First API Call

Your API call should include the following components:

  - **Host:** Provided by our support team, the host will look like `https://<NAME>.platforms.bookingsync.com`.
  - **Authorization Header:** Include your API Key in the Authorization header for authentication.
  - **Accept header:** Set the `Accept` header to `application/vnd.api+json` to indicate the desired response format.
  - **Request:** When sending data via POST or PUT, format your payload as JSON.

## Sample cURL Request

Copy the following cURL example to make your first API call, which retrieves all [accounts](https://demo.platforms.bookingsync.com/api-docs/index.html) interested in publishing listings on your website:

~~~bash
curl -i -X 'GET' 'HOST/api/ota/v1/accounts' -H 'accept: application/vnd.api+json' -H 'Authorization: Bearer API_KEY'
~~~

  1. Copy the cURL example above.
  2. Paste the curl call into your favorite text editor.
  3. Replace **API_KEY** with your actual API key and **HOST** with your host details.
  4. Copy the updated cURL command and paste it into your terminal.
  5. Press **Enter** to execute the request.
  6. A successful response with status **HTTP/2 200** indicates correct setup.

## Code Examples

| Ruby (Excon) | Ruby (Faraday) | Python | Java |
----ruby
require 'excon' # https://github.com/excon/excon

# Remember to replace `YOUR_TOKEN` and `API_URL` with your actual API token and URL
token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"
options = {
  headers: {
    "User-Agent" => "Api client",
    "Accept" => media_type,
    "Content-Type" => media_type,
    "Authorization" => "Bearer #{token}"
  }
}
request = Excon.new(URI.join(api_url, "/api/ota/v1/accounts").to_s, options)
response = request.request({ method: :get })

response.status
----ruby
require 'faraday' # https://github.com/lostisland/faraday

# Remember to replace `YOUR_TOKEN` and `API_URL` with your actual API token and URL
token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"

request = Faraday.new({ ssl: { verify: true } }) do |f|
  f.adapter :net_http_persistent
end
request.headers[:accept] = media_type
request.headers[:content_type] = media_type
request.headers[:user_agent] = "Api client"
request.headers[:authorization] = "Bearer #{token}"
request.url_prefix = api_url
response = request.send(:get, "/api/ota/v1/accounts")

response.status
----python
# Make sure you have the `requests` library installed in your Python environment
import requests

# Remember to replace `YOUR_TOKEN` and `API_URL` with your actual API token and URL
token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"

headers = {
    "User-Agent": "Api client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}"
}

response = requests.get(f"{api_url}/api/ota/v1/accounts", headers=headers)
status_code = response.status_code

print(f"Response Status Code: {status_code}")

# You can further process the response content here if needed
response_content = response.content
print(f"Response Content: {response_content}")
----java
// Make sure you have the OkHttp library added to your Java project's dependencies.
// Feel free to adapt this Java code to your project's structure and error handling needs. This example demonstrates making a GET request, and you can build upon it for other types of requests as well.
import java.io.IOException;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class SmilyChannelApiExample {

    public static void main(String[] args) throws IOException {
        // Remember to replace `YOUR_TOKEN` and `API_URL` with your actual API token and URL
        String token = "YOUR_TOKEN";
        String apiURL = "API_URL";
        String mediaType = "application/vnd.api+json";

        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(apiURL + "/api/ota/v1/accounts")
                .addHeader("User-Agent", "Api client")
                .addHeader("Accept", mediaType)
                .addHeader("Content-Type", mediaType)
                .addHeader("Authorization", "Bearer " + token)
                .build();

        Response response = client.newCall(request).execute();
        int statusCode = response.code();

        System.out.println("Response Status Code: " + statusCode);

        // You can further process the response body here if needed
        String responseBody = response.body().string();
        System.out.println("Response Body: " + responseBody);
    }
}
--end--

## Understanding API Responses

All responses are returned in JSON format. The Content-Type header specifies the format. For detailed response specifications, refer to the [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)
