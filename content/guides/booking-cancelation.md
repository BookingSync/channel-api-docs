# Booking Cancelation

1. TOC
{:toc}

## Preface

The Booking Cancellation API allows you to cancel bookings according to the rental's cancellation policy. The cancellation policy can be retrieved from the rental's endpoint and includes details such as eligible cancellation days and penalty percentages.

The cancellations and modifications made on the bookings both initiated by the guest or the PMs need to be made on the channel side which will then reflect in the Smily interface.

> **Please note** that PMs can't make cancellations directly in the Smily system so the cancellation has to be made by your channel.

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

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"
BOOKING_ID="111"

curl -X PATCH \
  '$API_URL/bookings/$BOOKING_ID/cancel' \
  -H 'User-Agent: Api client' \
  -H 'Accept: application/vnd.api+json' \
  -H 'Content-Type: application/vnd.api+json' \
  -H 'Authorization: Bearer $TOKEN' \
  -d '{
    "data": {
      "type": "bookings",
      "id": "$BOOKING_ID",
      "attributes": {
        "cancelation-reason": "canceled_by_traveller_other",
        "cancelation-description": "health concern",
        "channel-cancelation-cost": "80.0",
        "currency": "USD"
      }
    }
  }'
----ruby
token = "YOUR_TOKEN"
api_url = "API_URL"
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
booking_id = "BOOKING_ID"
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
----python
import requests
import json

token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"

# Set headers for the request
headers = {
    "User-Agent": "Api client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}"
}

# Construct the request
booking_id = "BOOKING_ID"
cancelation_reason = "canceled_by_traveller_other"
cancelation_description = "health concern"
channel_cancelation_cost = "80.0"
currency = "USD"

payload = {
    "data": {
        "type": "bookings",
        "id": booking_id,
        "attributes": {
            "cancelation-reason": cancelation_reason,
            "cancelation-description": cancelation_description,
            "channel-cancelation-cost": channel_cancelation_cost,
            "currency": currency
        }
    }
}

request_url = f"{api_url}/bookings/{booking_id}/cancel"

# Send the request and handle the response
response = requests.patch(request_url, headers=headers, data=json.dumps(payload))
response_json = response.json()

if response.status_code == 200:
    booking_canceled_at = response_json["data"]["attributes"]["canceled-at"]
    # Update new booking information
else:
    handle_errors(response_json)
----java
import okhttp3.*;
import org.json.JSONObject;

import java.io.IOException;

public class CancelBooking {

    private static final String TOKEN = "YOUR_TOKEN";
    private static final String API_URL = "API_URL";
    private static final String MEDIA_TYPE = "application/vnd.api+json";

    public static void main(String[] args) {
        OkHttpClient client = new OkHttpClient();
        MediaType mediaType = MediaType.parse(MEDIA_TYPE);
        String bookingId = "YOUR_BOOKING_ID"; // Replace with your actual booking id

        JSONObject payload = new JSONObject();
        payload.put("type", "bookings");
        payload.put("id", bookingId);
        JSONObject attributes = new JSONObject();
        attributes.put("cancelation-reason", "canceled_by_traveller_other");
        attributes.put("cancelation-description", "health concern");
        attributes.put("channel-cancelation-cost", "80.0");
        attributes.put("currency", "USD");
        payload.put("attributes", attributes);

        RequestBody body = RequestBody.create(mediaType, payload.toString());

        Request request = new Request.Builder()
                .url(API_URL + "/bookings/" + bookingId + "/cancel")
                .patch(body)
                .addHeader("User-Agent", "Api client")
                .addHeader("Accept", MEDIA_TYPE)
                .addHeader("Content-Type", MEDIA_TYPE)
                .addHeader("Authorization", "Bearer " + TOKEN)
                .build();

        try {
            Response response = client.newCall(request).execute();
            int responseStatus = response.code();

            if (responseStatus == 200) {
                JSONObject jsonResponse = new JSONObject(response.body().string());
                String bookingCanceledAt = jsonResponse.getJSONObject("data").getJSONObject("attributes").getString("canceled-at");
                // Update new booking information
                System.out.println("Booking canceled at: " + bookingCanceledAt);
            } else {
                // Handle errors
                System.out.println("Error: " + response.body().string());
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
--end--

> **Note:** When cancelling a booking, it is essential to handle the `channel-cancelation-cost` attribute correctly to ensure the proper amount is charged or refunded to the guest.<br> `Channel-cancelation-cost` is **0**. means the partner does not want to charge the guest, and the cancellation is free.<br>`Channel-cancelation-cost` is **not 0**: indicates that the partner wants to charge the guest a certain amount as a cancellation fee.