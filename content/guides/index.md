# Smily Channel API Overview

1. TOC
{:toc}

## What is Smily Channel API?

The channel API helps channel partners to integrate with our API by providing “shortcuts” so that partners can pull off the required data they need without having to combine too many requests from our API.

## Who is Smily Channel API for?

The Smily Channel API is designed to be useful for a variety of platforms. It's particularly valuable for:

  - **Online Travel Agencies (OTAs)**
  - **Marketplaces**
  - **Tour Operators**
  - **Niche Channels**

**Create Your Own Portal:** Additionally, the Smily offers the flexibility to build entire Marketplaces or Niche Channels according to your vision. Explore this capability further on our [Your Own Portal](https://www.smily.com/en/your-own-portal) page.

## Why would I use Smily Channel API?

The Smily Channel API presents an optimal way to easily onboard new properties onto your system. Designed with our partners in mind, this API simplifies the integration journey.

It's important to highlight that our more extensive feature set is available through the [BookingSync API](https://developers.bookingsync.com/). While the Smily Channel API offers speedy integration, unlocking the full range of features in the BookingSync API might take more time and expertise from skilled engineers.

In essence, the Smily Channel API provides a straightforward and speedy integration, while the BookingSync API offers a wider range of features that require more time and technical know-how.

## How the Smily Channel API works?

The Smily Channel API is designed to synchronize account data, rentals, and facilitate bookings between Smily Channel and our partners’ platforms. Below is a detailed step-by-step guide on how to utilize our API for a seamless synchronization process.

<a href="/images/integration_flow.png" target="_blank"><img src="/images/integration_flow.png" /></a>

### 1. Activation

Begin by requesting a demo account from the [Smily Partners Team](mailto:partners@smily.com). This account will grant you access to the API.

### 2. Accounts onboarding

The second step to integration is to fetch the list of accounts interested in publishing their listings on your platform. You can do this by making a GET request to the `/accounts` endpoint. It’s recommended to perform this operation regularly to keep the accounts data up-to-date.
After fetching the accounts, the next step is to onboard them. This process involves signing contracts, registering them in your system, and performing any other necessary setup operations.

### 3. Fetching Rental Information

Once the accounts are onboarded, it’s time to fetch their associated rentals. This process happens in several stages:

  **3.1 Fetching Base Rental Information**

First, fetch the base information of the rentals by making a GET request to the `/rentals` endpoint. This includes details like descriptions, tags, amenities, etc. It is advised to refresh this information once a day to keep it up-to-date.

  **3.2 Fetching Rental Availabilities**

The next step is to fetch the availability status of these rentals. You can do this by making an GET request to the `/rentals` endpoint. It's recommended to refresh availability data every hour.

  **3.3 Fetching Rental Prices**

Fetch the prices of the rentals by making a GET request to the `/api/ota/v1/los-record-export-urls` endpoint. We update prices every 12 hours, no sense to update it more often.

  **3.4 Unpublished Rentals**

Lastly, it’s crucial to remove any rentals that are no longer available. If a rental is unpublished from the Smily Channel, be sure to reflect this change in your system to avoid booking unavailable rentals.

### 4. Booking Creation

When a customer submits a booking request on your platform, start by verifying the price and availability for the desired rental. Achieve this by initiating a POST request to the `/quotes` endpoint. The response will provide you with the confirmed price and availability status.
The response also includes a `Booking URL`. If you wish to process payments through the Smily Payment Gateway, simply redirect the guest to this URL. If not, proceed to the next step.

### 5. Confirm Booking with Payment

The following steps are necessary if parner wishes to use own payment gateway:

  **5.1 Create a Booking**

If the rental is available, proceed to create a booking. Make a POST request to the `/bookings` endpoint with a price not less than the one provided in the quote response.

  **5.2 Process the payment**

The partner manages and completes the payment process on their end.

  **5.3 Store the Payment**

Lastly, confirm the booking by making a payment. You can do this by sending a POST request to the `/payments` endpoint. This final step ensures the booking is confirmed and the rental is successfully reserved for the customer.
