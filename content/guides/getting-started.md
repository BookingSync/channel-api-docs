# Getting Started with Smily Channel API

1. TOC
{:toc}

## Preface

These instruction describe how to make your first API call using cURL. Before you start using the API, your need to do the following:

  1. Request a demo account from [Smily Partners Team](mailto:partners@smily.com)
  2. Get an **API Key** and **host** [Smily Partners Team](mailto:partners@smily.com)
  3. Make sure you have [curl](https://curl.haxx.se/) installed on your machine :)

## Build your API call

Your API call must have the following components:

  - **A host.** The host will be provided by our support and will look like `https://<NAME>.platforms.bookingsync.com`.
  - **An Authorization header.** An API Key must be included in the Authorization header.
  - **An Accept header.** `Accept` header should always be equal `application/vnd.api+json`.
  - **A request.** When submitting data to a resource via POST or PUT, you must submit your payload in JSON.


## Make your first call to Smily Channel API

As a first API call, let's get all [accounts](https://demo.platforms.bookingsync.com/api-docs/index.html), who wants to publish their listings on your website:

~~~bash
curl -i -X 'GET' '<HOST>/api/ota/v1/accounts' -H 'accept: application/vnd.api+json' -H 'Authorization: Bearer <API_KEY>'
~~~

  1. Copy the curl example above.
  2. Paste the curl call into your favorite text editor.
  3. Copy your **API KEY** and paste it in the "Authorization" header.
  4. Copy your **HOST** and paste it in the url.
  5. Copy the code and paste it in your terminal.
  6. Hit **Enter**.
  7. **HTTP/2 200** at the top of response means you did everything correct!


Test code in Ruby with [Excon](https://github.com/excon/excon) library:

~~~ruby
token = "<YOUR_TOKEN>"
api_url = "<API_URL>"
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
~~~

Test code in Ruby with [Faraday](https://github.com/lostisland/faraday) library:

~~~ruby
token = "<YOUR_TOKEN>"
api_url = "<API_URL>"
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
~~~

## API response messages

All responses are returned in JSON format. We specify this by sending the `Content-Type` header. You can find detailed responses specification in [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)