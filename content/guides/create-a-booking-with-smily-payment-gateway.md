# Create a Booking and Handle Payments with Smily Payment Gateway

1. TOC
{:toc}

## Preface

This guide will walk you through the process of creating bookings and handling payments using the Smily payment gateway. By integrating with our API, you can seamlessly manage bookings and offer a secure payment experience to your users.

## Create a quote

Before creating a booking, you need to confirm the price and availability of the rental. To do this, you must create a quote by making a `POST` request to the `/api/ota/v1/quotes` endpoint.

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

After successfully creating a quote, simply redirect the user to the provided `booking-url`. This will take them to the Smily Payment Gateway's payment page, where they can complete the payment and finalize the booking.
