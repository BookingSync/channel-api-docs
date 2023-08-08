# Booking and Payment Handling

1. TOC
{:toc}

## Preface

This document outlines the process of handling payments on the partner's side. While we offer the option to use the Smily payment gateway, this guide focuses on managing payments directly through the partner's infrastructure.

## Quote creation

Before proceeding with booking creation, it's necessary to confirm rental price and availability by generating a quote.

~~~ruby
require 'excon'

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
  # Proceed to booking creation via API or redirect user to booking_url
else
  handle_errors(json)
end
~~~

## Booking creation

Once a successful quote is obtained, initiate a booking request by providing client details, rental information, and pricing.

> Note: Ensure that the provided price matches or higher than `final-price` from the quote.

~~~ruby
token = "<YOUR_TOKEN>"
api_url = "<API_URL>"
media_type = "application/vnd.api+json"
options = {
  headers: {
    "User-Agent" => "Api client",
    "Accept" => media_type,
    "Content-Type" => media_type,
    "Authorization" => "Bearer #{token}",
    "Idempotency-Key" => get_order_uuid # Use a unique ID for idempotency
  }
}

request = Excon.new(URI.join(api_url, "/api/ota/v1/bookings").to_s, options)
payload = {
  data: {
    attributes: {
      "start-at": "2020-09-04T16:00:00.000Z", # "2020-09-04" works too
      "end-at": "2020-09-11T10:00:00.000Z", # "2020-09-11" works too
      "adults": 2,
      "children": 1,
      "final-price": "176.0",
      "currency": "EUR",
      "rental-id": 1,
      "client-first-name": "Rich",
      "client-last-name": "Piana",
      "client-email": "rich@piana.com",
      "client-phone-number": "123123123",
      "client-country-code": "US"
    },
    type: "bookings"
  }
}
response = request.request({
  method: :post,
  body: payload.to_json
})

json = JSON.parse(response.body)
if response.status == 201
  booking_id = json["data"]["id"]
  # Save the booking ID for future reference
else
  handle_errors(json)
end
~~~

> **Note:** If a created booking includes the not null `tentative-expires-at` field, it may be automatically canceled if no payment is made. Therefore, it's essential to proceed with payment creation.

We strongly recommend setting the `Idempotency-Key` header to prevent duplicate creations. Generate a UUID for each order and use it as the `Idempotency-Key`.

For example, if you attempt to create a booking but encounter a network connection issue or another error that prevents you from receiving a response, you can safely retry your request. This is possible because, for a specific key, each successful response will be cached for a 6 hours.

## Payment creation

Once payment for the booking is processed, notify us to prevent booking cancellation.

~~~ruby
token = "<YOUR_TOKEN>"
api_url = "<API_URL>"
media_type = "application/vnd.api+json"
options = {
  headers: {
    "User-Agent" => "Api client",
    "Accept" => media_type,
    "Content-Type" => media_type,
    "Authorization" => "Bearer #{token}",
    "Idempotency-Key" => get_payment_uuid # Use a unique ID for idempotency
  }
}

request = Excon.new(URI.join(api_url, "/api/ota/v1/payments").to_s, options)
payload = {
  data: {
    attributes: {
      "amount": "100.0",
      "currency": "EUR",
      "paid-at": "2020-09-10T05:30:18.321Z",
      "kind": "credit-card",
      "booking-id": booking_id
    },
    type: "payments"
  }
}
response = request.request({
  method: :post,
  body: payload.to_json
})

json = JSON.parse(response.body)
if response.status == 201
  booking_id = json["data"]["id"]
  # Save the payment ID for reference
else
  handle_errors(json)
end
~~~

> **Note:** Payments endpoint also support `Idempotency-Key` header. To ensure idempotent writes and frictionless integration, it is highly recommended to provide `Idempotency-Key` header. For a given key, every success response will be cached for 6 hours. Thanks to that, you can safely retry write operation.
