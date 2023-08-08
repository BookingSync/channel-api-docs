# Booking Cancelation

1. TOC
{:toc}

## Preface

The Booking Cancellation API allows you to cancel bookings according to the rental's cancellation policy. The cancellation policy can be retrieved from the rental's endpoint and includes details such as eligible cancellation days and penalty percentages.

~~~js
  "cancelation-policy-items": [
    {
      "id": "1",
      "penalty-percentage": 10,
      "eligible-days": 2,
      "message-translations": {
        "en": "Lorem ipsum",
        "fr": "Lorem ipsum"
      }
    }
  ]
~~~

In this example, a booking can be canceled up to 2 days before check-in with a penalty of 10% from the booking's final price.

## Booking Cancellation Process

To cancel a booking, follow these steps:

  1. Retrieve the cancellation policy from the rental's endpoint. Refer to the [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html) for detailed specifications.
  2. Use the provided cancellation policy to determine the eligible cancellation days and penalty percentage.
  3. Make a PATCH request to the booking cancellation endpoint:

~~~ruby
token = "<YOUR_TOKEN>"
api_url = "<API_URL>"
media_type = "application/vnd.api+json"

# Set headers and options for the request
headers = {
  "User-Agent": "Api client",
  "Accept": media_type,
  "Content-Type": media_type,
  "Authorization": "Bearer #{token}"
}

options = {
  headers: headers
}

# Construct the request
booking_id = "<BOOKING_ID>"
cancelation_reason = "canceled_by_traveller_other"
cancelation_description = "health concern"
channel_cancelation_cost = "80.0"
currency = "USD"

payload = {
  data: {
    type: "bookings",
    id: booking_id,
    attributes: {
      "cancelation-reason": cancelation_reason,
      "cancelation-description": cancelation_description,
      "channel-cancelation-cost": channel_cancelation_cost,
      "currency": currency
    }
  }
}

request_url = URI.join(api_url, "/bookings/#{booking_id}/cancel").to_s
request = Excon.new(request_url, options)

# Send the request and handle the response
response = request.request(method: :patch, body: payload.to_json)
json = JSON.parse(response.body)

if response.status == 200
  booking_canceled_at = json["data"]["attributes"]["canceled-at"]
  # Update new booking information
else
  handle_errors(json)
end
~~~

## Possible Validation Error

In case of a validation error, the response will resemble the following:

~~~js
  {
    "errors" => [
      {
        "code" => "100",
        "detail" => "currency - provided currency for cancelation must be the same as the one from booking",
        "source" => {
          "pointer" => "/data/attributes/currency"
        },
        "status" => "422",
        "title" => "provided currency for cancelation must be the same as the one from booking"
      }
    ]
  }
~~~
