# Create a booking and handle payments with Smily payment gateway

1. TOC
{:toc}

## Preface

There are 2 ways of handling payments: using Smily payment gateway or process payment on partner side. This document explains first option - how to handle payments with Smily payment gateway.

## Create a quote

Before creating a booking, you have to confirm the price and availability of rental. To do that, you have to create a quote.

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

request = Excon.new(URI.join(api_url, "/api/ota/v1/quotes").to_s, options)
payload = {
  data: {
    attributes: {
      "start-at": "2023-08-04",
      "end-at": "2023-08-11",
      "adults": 20,
      "children": 0,
      "rental-id": 428
    },
    type: "quotes"
  }
}
response = request.request({
  method: :post,
  body: payload.to_json
})

json = JSON.parse(response.body)
if response.status == 201
  price = json["data"]["attributes"]["final-price"]
  booking_url = json["data"]["attributes"]["booking-url"]
  # Now you can create booking via API or redirect user to booking_url
else
  handle_errors(json)
end
~~~

If you don't have own payment gateway, you can just redirect user to `booking_url`. That's it :)
