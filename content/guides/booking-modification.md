# Booking Modification

1. TOC
{:toc}

## Overview

The Smily Channel API does not currently support direct booking modification. When a booking needs to be changed (e.g., different dates, number of guests, or rental), partners must follow a cancel-and-rebook workflow.

## Why There Is No Direct Modification Endpoint

Booking modifications involve complex dependencies such as pricing, availability, cancellation policies, and payment adjustments that must be carefully orchestrated. Until a dedicated modification endpoint is available, the recommended approach is to cancel the existing booking and create a new one with the updated details.

## Booking Modification Process

To modify a booking, follow these steps:

1. **Cancel the existing booking** by making a PATCH request to the booking cancellation endpoint. Refer to the [Booking Cancelation guide](/guides/booking-cancelation) for detailed instructions.
2. **Create a new booking** with the updated details by following the standard booking creation flow. Refer to the [Create a Booking guide](/guides/create-a-booking-payments-on-partner-side) for detailed instructions.

> **Please note** that when cancelling a booking as part of a modification, the applicable cancellation policy and any associated penalty fees still apply. Make sure to communicate this clearly to the guest before proceeding.

## Important Considerations

- **Availability:** Before cancelling the existing booking, confirm that the rental is available for the new dates or configuration to avoid leaving the guest without accommodation.
- **Pricing:** Always create a new quote for the updated booking details to get the confirmed price before creating the new booking.
- **Guest communication:** Inform the guest of the cancel-and-rebook process and any cost implications before initiating it.

## Step-by-Step Example

### Step 1 — Cancel the Existing Booking

Make a PATCH request to cancel the current booking:

```bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"
BOOKING_ID="YOUR_BOOKING_ID"

curl -X PATCH \
  "$API_URL/bookings/$BOOKING_ID/cancel" \
  -H 'User-Agent: Api client' \
  -H 'Accept: application/vnd.api+json' \
  -H 'Content-Type: application/vnd.api+json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "data": {
      "type": "bookings",
      "id": "'$BOOKING_ID'",
      "attributes": {
        "cancelation-reason": "canceled_by_traveller_other",
        "cancelation-description": "Guest requested modification",
        "channel-cancelation-cost": "0.0",
        "currency": "USD"
      }
    }
  }'
```

A successful response returns HTTP **200** with the `canceled-at` timestamp in the booking attributes.

### Step 2 — Create a New Quote

Before creating the new booking, request a quote to confirm availability and pricing for the updated details:

```bash
curl -X POST \
  "$API_URL/api/ota/v1/quotes" \
  -H 'User-Agent: Api client' \
  -H 'Accept: application/vnd.api+json' \
  -H 'Content-Type: application/vnd.api+json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "data": {
      "attributes": {
        "start-at": "NEW_START_DATE",
        "end-at": "NEW_END_DATE",
        "adults": 2,
        "children": 0,
        "rental-id": YOUR_RENTAL_ID,
        "type": "quotes"
      }
    }
  }'
```

The response includes a confirmed `final-price` and a `booking-url` for payment gateway redirection if needed.

### Step 3 — Create the New Booking

Once the quote is confirmed, create the new booking using the price returned in the quote response:

```bash
curl -X POST \
  "$API_URL/api/ota/v1/bookings" \
  -H 'User-Agent: Api client' \
  -H 'Accept: application/vnd.api+json' \
  -H 'Content-Type: application/vnd.api+json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "data": {
      "type": "bookings",
      "attributes": {
        "start-at": "NEW_START_DATE",
        "end-at": "NEW_END_DATE",
        "adults": 2,
        "children": 0,
        "rental-id": YOUR_RENTAL_ID,
        "final-price": CONFIRMED_PRICE,
        "currency": "USD"
      }
    }
  }'
```

A successful response returns HTTP **201** with the new booking details, including the new booking ID.

> **Note:** For partners handling payments on their side, follow up with a POST request to the `/payments` endpoint to confirm the new booking. Refer to the [Create a Booking — Payments on Partner Side guide](/guides/create-a-booking-payments-on-partner-side) for full details.
