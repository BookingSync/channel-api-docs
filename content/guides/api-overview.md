# Smily Channel API Overview

1. TOC
{:toc}

## What is Smily Channel API?

Channel API allows you to sync Smily properties to your own website (aka Channel). You can choose which properties or accounts to display or not, get rentals availabilities, book rentals and collect payments.

## Who is Smily Channel API for?

TODO

## Why would I use Smily Channel API?

This API was developed to make integration with our partners easier. If you want to look at all features of our system, please refer to [BookingSync Universe API ](https://developers.bookingsync.com/).

## How the Smily Channel API works?

In general, there are 3 steps you have to do:

  1. Manage accounts that are ready to publish their listings on your website - regularly refresh the list and onboard them.
  2. Manage rentals of onboarded accounts - regularly refresh descriptions, prices and availabilities.
  3. Manage bookings. This step depends on how you want to process the payments - on your side, or on our side.


The API is fully [JSONAPI 1.0 compliant](http://jsonapi.org).

1. Get accounts
2. approve/reject them
3. sign contracts/register/oboarding/etc
4. get rentals of approved accounts
  4.1 Get rentals info (refresh once a day)
  4.2 Get rentals availabilities (refresh every hour)
  4.3 Get rentals prices (every 12 hours)
  4.4 Remove unpublished rentals
5. Booking creation:
  5.1 Create quote to confirm price and availability.
  5.2 Create booking with price not less than in quote response
  5.4 Create payment to confirm booking
