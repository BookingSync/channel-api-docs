# Booking and Payment Handling

1. TOC
{:toc}

## Preface

This document outlines the process of handling payments on the partner's side. While we offer the option to use the Smily payment gateway, this guide focuses on managing payments directly through the partner's infrastructure.

## Quote creation

Before proceeding with booking creation, it's necessary to confirm rental price and availability by generating a quote.

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"

curl -X POST \
  "$API_URL/api/ota/v1/quotes" \
  -H "User-Agent: Api client" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
  "data": {
    "attributes": {
      "start-at": "2023-08-04",
      "end-at": "2023-08-11",
      "adults": 20,
      "children": 0,
      "rental-id": 428
    },
    "type": "quotes"
  }
}'
----ruby
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
----python
import requests
import json

token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"
headers = {
    "User-Agent": "Api client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}"
}

url = f"{api_url}/api/ota/v1/quotes"
payload = {
    "data": {
        "attributes": {
            "start-at": "2023-08-04",
            "end-at": "2023-08-11",
            "adults": 20,
            "children": 0,
            "rental-id": 428
        },
        "type": "quotes"
    }
}

response = requests.post(url, headers=headers, data=json.dumps(payload))

if response.status_code == 201:
    response_json = response.json()
    price = response_json["data"]["attributes"]["final-price"]
    booking_url = response_json["data"]["attributes"]["booking-url"]
    # Now you can create booking via API or redirect user to booking_url
else:
    handle_errors(response.json())  # assuming handle_errors is a function you have defined
----java
import okhttp3.*;
import org.json.JSONObject;

import java.io.IOException;

public class CreateQuote {

    public static void main(String[] args) {
        String token = "YOUR_TOKEN";
        String api_url = "API_URL";
        MediaType mediaType = MediaType.parse("application/vnd.api+json");

        OkHttpClient client = new OkHttpClient();

        String url = api_url + "/api/ota/v1/quotes";

        JSONObject attributes = new JSONObject();
        attributes.put("start-at", "2023-08-04");
        attributes.put("end-at", "2023-08-11");
        attributes.put("adults", 20);
        attributes.put("children", 0);
        attributes.put("rental-id", 428);

        JSONObject data = new JSONObject();
        data.put("attributes", attributes);
        data.put("type", "quotes");

        JSONObject payload = new JSONObject();
        payload.put("data", data);

        RequestBody body = RequestBody.create(payload.toString(), mediaType);

        Request request = new Request.Builder()
                .url(url)
                .addHeader("User-Agent", "API Client")
                .addHeader("Accept", mediaType.toString())
                .addHeader("Content-Type", mediaType.toString())
                .addHeader("Authorization", "Bearer " + token)
                .post(body)
                .build();

        try {
            Response response = client.newCall(request).execute();
            if (response.code() == 201) {
                JSONObject responseBody = new JSONObject(response.body().string());
                int price = responseBody.getJSONObject("data").getJSONObject("attributes").getInt("final-price");
                String bookingUrl = responseBody.getJSONObject("data").getJSONObject("attributes").getString("booking-url");
                // Now you can create booking via API or redirect user to booking_url
            } else {
                handleErrors(response.body().string());  // assuming handleErrors is a function you have defined
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Define your function here:
    private static void handleErrors(String error) {
        // Implement your logic to handle errors
    }
}
--end--

## Booking creation

Once a successful quote is obtained, initiate a booking request by providing client details, rental information, and pricing.

> Note: Ensure that the provided price matches or higher than `final-price` from the quote.

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"

curl -X POST \
  '$API_URL/api/ota/v1/bookings' \
  -H 'User-Agent: Api client' \
  -H 'Accept: application/vnd.api+json' \
  -H 'Content-Type: application/vnd.api+json' \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Idempotency-Key: UNIQUE_UUID' \
  -d '{
  "data": {
    "attributes": {
      "start-at": "2020-09-04T16:00:00.000Z",
      "end-at": "2020-09-11T10:00:00.000Z",
      "adults": 2,
      "children": 1,
      "final-price": "176.0",
      "currency": "EUR",
      "rental-id": 1,
      "client-first-name": "Rich",
      "client-last-name": "Piana",
      "client-email": "rich@piana.com",
      "client-phone-number": "123123123",
      "client-country-code": "US",
      "channel-commission": "10.0"
    },
    "type": "bookings"
  }
}'
----ruby
token = "YOUR_TOKEN"
api_url = "API_URL"
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
      "client-country-code": "US",
      "channel-commission": "10.0"
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
----python
import requests
import json
import uuid

def get_order_uuid():
    # Replace this function with your actual implementation
    return str(uuid.uuid4())

token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"

headers = {
    "User-Agent": "Api client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}",
    "Idempotency-Key": get_order_uuid()  # Use a unique ID for idempotency
}

payload = {
    "data": {
        "attributes": {
            "start-at": "2020-09-04T16:00:00.000Z",  # "2020-09-04" works too
            "end-at": "2020-09-11T10:00:00.000Z",  # "2020-09-11" works too
            "adults": 2,
            "children": 1,
            "final-price": "176.0",
            "currency": "EUR",
            "rental-id": 1,
            "client-first-name": "Rich",
            "client-last-name": "Piana",
            "client-email": "rich@piana.com",
            "client-phone-number": "123123123",
            "client-country-code": "US",
            "channel-commission": "10.0"
        },
        "type": "bookings"
    }
}

response = requests.post(
    f"{api_url}/api/ota/v1/bookings",
    headers=headers,
    data=json.dumps(payload)
)

response_json = response.json()

if response.status_code == 201:
    booking_id = response_json["data"]["id"]
    # Save the booking ID for future reference
else:
    handle_errors(response_json)  # Make sure to define this function
----java
import okhttp3.*;
import org.json.JSONObject;

import java.io.IOException;
import java.util.UUID;

public class BookingCreation {

    public static void main(String[] args) {
        String token = "YOUR_TOKEN";
        String api_url = "API_URL";
        String mediaTypeStr = "application/vnd.api+json";

        MediaType mediaType = MediaType.parse(mediaTypeStr);
        OkHttpClient client = new OkHttpClient();

        JSONObject attributes = new JSONObject()
                .put("start-at", "2020-09-04T16:00:00.000Z")
                .put("end-at", "2020-09-11T10:00:00.000Z")
                .put("adults", 2)
                .put("children", 1)
                .put("final-price", "176.0")
                .put("currency", "EUR")
                .put("rental-id", 1)
                .put("client-first-name", "Rich")
                .put("client-last-name", "Piana")
                .put("client-email", "rich@piana.com")
                .put("client-phone-number", "123123123")
                .put("client-country-code", "US")
                .put("channel-commission", "10.0");

        JSONObject payload = new JSONObject()
                .put("data", new JSONObject()
                        .put("attributes", attributes)
                        .put("type", "bookings"));

        RequestBody body = RequestBody.create(mediaType, payload.toString());

        Request request = new Request.Builder()
                .url(api_url + "/api/ota/v1/bookings")
                .addHeader("User-Agent", "API Client")
                .addHeader("Accept", mediaTypeStr)
                .addHeader("Content-Type", mediaTypeStr)
                .addHeader("Authorization", "Bearer " + token)
                .addHeader("Idempotency-Key", UUID.randomUUID().toString())
                .post(body)
                .build();

        try {
            Response response = client.newCall(request).execute();
            if (response.isSuccessful()) {
                JSONObject responseBody = new JSONObject(response.body().string());
                String booking_id = responseBody.getJSONObject("data").getString("id");
                // Save the booking ID for future reference
            } else {
                handleErrors(response); // Make sure to define this function
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void handleErrors(Response response) {
        // Implement your logic to handle errors
    }
}
--end--

> **Note:** Please ensure you correctly set the partner's commission in the `channel-commission` field of the payload.

> **Important:** By default, we create tentative bookings, and if payment is not received within some period, the booking will be automatically canceled. Each booking includes a 'tentative-expires-at' field, indicating the time at which the booking will expire. The duration of this period varies depending on the rental settings. For instantly bookable rentals, this period is 10 minutes but can be extended upon request. For rentals that are not instantly bookable, the period is 72 hours.

> **Additionally:**: By default, we do not include rentals that are not instantly bookable in the API response, but we can include them upon request.

We strongly recommend setting the `Idempotency-Key` header to prevent duplicate creations. Generate a UUID for each order and use it as the `Idempotency-Key`.

For example, if you attempt to create a booking but encounter a network connection issue or another error that prevents you from receiving a response, you can safely retry your request. This is possible because, for a specific key, each successful response will be cached for a 6 hours.

## Payment creation

Once payment for the booking is processed, notify us to prevent booking cancellation.

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"
IDEMPOTENCY_UUID="IDEMPOTENCY_UUID"
BOOKING_ID=1111

curl -X POST "$API_URL/api/ota/v1/payments" \
  -H "User-Agent: Api client" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: $IDEMPOTENCY_UUID" \
  -d '{
    "data": {
      "attributes": {
        "amount": "100.0",
        "currency": "EUR",
        "paid-at": "2020-09-10T05:30:18.321Z",
        "kind": "credit-card",
        "booking-id": "$BOOKING_ID"
      },
      "type": "payments"
    }
  }'
----ruby
token = "YOUR_TOKEN"
api_url = "API_URL"
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
----python
import requests
import json
import uuid

token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"

def get_payment_uuid():
    return str(uuid.uuid4())  # Use a unique ID for idempotency

headers = {
    "User-Agent": "Api client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}",
    "Idempotency-Key": get_payment_uuid()
}

payload = {
    "data": {
        "attributes": {
            "amount": "100.0",
            "currency": "EUR",
            "paid-at": "2020-09-10T05:30:18.321Z",
            "kind": "credit-card",
            "booking-id": "BOOKING_ID"  # Replace with actual booking id
        },
        "type": "payments"
    }
}

response = requests.post(f"{api_url}/api/ota/v1/payments", headers=headers, data=json.dumps(payload))

if response.status_code == 201:
    json_response = response.json()
    payment_id = json_response["data"]["id"]
    # Save the payment ID for reference
else:
    print(f"Handle errors: {response.text}")
----java
import okhttp3.*;
import org.json.JSONObject;

import java.io.IOException;
import java.util.UUID;

public class MakePayment {

    private static final String TOKEN = "YOUR_TOKEN";
    private static final String API_URL = "API_URL";
    private static final String MEDIA_TYPE = "application/vnd.api+json";

    public static void main(String[] args) {
        String idempotencyKey = UUID.randomUUID().toString();

        OkHttpClient client = new OkHttpClient();
        MediaType mediaType = MediaType.parse(MEDIA_TYPE);
        String bookingId = "YOUR_BOOKING_ID"; // Replace with your actual booking id

        JSONObject payload = new JSONObject();
        payload.put("type", "payments");
        JSONObject attributes = new JSONObject();
        attributes.put("amount", "100.0");
        attributes.put("currency", "EUR");
        attributes.put("paid-at", "2020-09-10T05:30:18.321Z");
        attributes.put("kind", "credit-card");
        attributes.put("booking-id", bookingId);
        payload.put("attributes", attributes);

        RequestBody body = RequestBody.create(mediaType, payload.toString());

        Request request = new Request.Builder()
                .url(API_URL + "/api/ota/v1/payments")
                .post(body)
                .addHeader("User-Agent", "Api client")
                .addHeader("Accept", MEDIA_TYPE)
                .addHeader("Content-Type", MEDIA_TYPE)
                .addHeader("Authorization", "Bearer " + TOKEN)
                .addHeader("Idempotency-Key", idempotencyKey)
                .build();

        try {
            Response response = client.newCall(request).execute();
            int responseStatus = response.code();

            if (responseStatus == 201) {
                JSONObject jsonResponse = new JSONObject(response.body().string());
                String paymentId = jsonResponse.getJSONObject("data").getString("id");
                // Save the payment ID for reference
                System.out.println("Payment ID: " + paymentId);
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

> **Note:** Payments endpoint also support `Idempotency-Key` header. To ensure idempotent writes and frictionless integration, it is highly recommended to provide `Idempotency-Key` header. For a given key, every success response will be cached for 6 hours. Thanks to that, you can safely retry write operation.
