# Create a Booking and Handle Payments with Smily Payment Gateway

1. TOC
{:toc}

## Preface

This guide will walk you through the process of creating bookings and handling payments using the Smily payment gateway. By integrating with our API, you can seamlessly manage bookings and offer a secure payment experience to your users.

## Create a quote

Before creating a booking, you need to confirm the price and availability of the rental. To do this, you must create a quote by making a `POST` request to the `/api/ota/v1/quotes` endpoint.

## Code example in Ruby

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

After successfully creating a quote, simply redirect the user to the provided `booking-url`. This will take them to the Smily Payment Gateway's payment page, where they can complete the payment and finalize the booking.
