# Booking cancelation

1. TOC
{:toc}

## Preface

Bookings could be canceled according to the rental's cancelation policy. You can get cancelation policy from rental's enpoint, usually it looks like:

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

In this case you can cancel the booking not later than 2 days before check-in. And penalty will be 10% from the booking final price.

## Booking cancelation

You can find detailed specification in [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)

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

request = Excon.new(URI.join(api_url, "/bookings/#{booking_id}/cancel").to_s, options)
payload = {
  data: {
    attributes: {
      "cancelation-reason": "canceled_by_traveller_other",
      "cancelation-description": "health concern",
      "channel-cancelation-cost": "80.0",
      "currency": "USD"
    },
    type: "bookings",
    id: booking_id
  }
}
response = request.request({
  method: :patch,
  body: payload.to_json
})

json = JSON.parse(response.body)
if response.status == 200
  booking_canceled_at = json["data"]["attributes"]["canceled-at"]
  # update new booking information
else
  handle_errors(json)
end
~~~

In some cases you can get a 422 error. Response will look like this:

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
