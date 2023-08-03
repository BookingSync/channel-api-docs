# Create a booking

TODO: Split into 2? When have own payment gateway and when don't?

1. TOC
{:toc}

## Preface

This chapter explains the booking process.

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

Quotes endpoint could return a 422 error. Response will be like that

~~~json
{
  "errors":[
    {
      "title": "period is not available for booking",
      "detail": "start-at - period is not available for booking",
      "code": "100",
      "source": { "pointer": "/data/attributes/start-at" },
      "status": "422"
    },
    {
      "title": "period is not available for booking",
      "detail": "end-at - period is not available for booking",
      "code": "100",
      "source": { "pointer": "/data/attributes/end-at" },
      "status": "422"
    }
  ]
}
~~~

If you don't have own payment gateway, you can just redirect user to `booking_url`. If you want to handle this order with own payment gateway, follow next instructions.

## Create a booking

Once you have successfully created a Quote, you can make a booking request. To do that you have to provide all information about the client, dates, rental ID and price.

> Price should not be less than `final-price` you got from Quote request

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
    "Idempotency-Key" => get_order_uuid # optional but useful header, read comments below
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
    type: "quotes"
  }
}
response = request.request({
  method: :post,
  body: payload.to_json
})

json = JSON.parse(response.body)
if response.status == 201
  booking_id = json["data"]["id"]
  # save this booking id
else
  handle_errors(json)
end
~~~

TODO: confirm it
If created booking has field `tentative-expires-at`, it means it could be canceled automatically if you won't create any payment. So, as a next step, we have to create payments.

We recommend to always set `Idempotency-Key` header. This header allow to avoid duplicates creation. For example if you tried to create a booking and because of network connection or some other error you could not get response, you can safely retry your request and get the correct response, because for a given key, every success response will be cached for 6 hours.
We recommend to generate UUID for each order and use it in `Idempotency-Key` header.

## Create a payment

When you handled payment for the booking, you have to notify our us about that.

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
    "Idempotency-Key" => get_payment_uuid # optional but useful header, read comments below
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
  # save this booking id
else
  handle_errors(json)
end
~~~

Payments endpoint also support `Idempotency-Key` header. To ensure idempotent writes and frictionless integration, it is highly recommended to provide `Idempotency-Key` header. For a given key, every success response will be cached for 6 hours. Thanks to that, you can safely retry write operation.
