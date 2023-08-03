# Rentals synchronization

1. TOC
{:toc}

## Preface

Once you onboarded accounts, you can start import their rentals.

## Get rentals base information

You can find detailed specification in [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)

> We suggest to refresh rentals base information once a day


TODO: REMOVE disable_rentals

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

Account.approved.each do |account|
  account_rentals_ids = Rental.for_account(account).pluck(:id)
  page_number = 1
  while true do
    request = Excon.new(URI.join(api_url, "/api/ota/v1/rentals?page[number]=#{page_number}&page[size]=50&filter[account-id]=#{account.id}").to_s, options)

    response = request.request({ method: :get })
    json = JSON.parse(response.body)
    json["data"].each do |rental|
      # Import rental
      import_rental(rental)
    end

    account_rentals_ids -= json["data"].pluck("id").map(&:to_i)

    break if page_number >= json["meta"]["pagination"]["pages"].to_i
    page_number++
  end

  disable_rentals(account_rentals_ids)
end
~~~

## Get rentals availabilities

Availability is a just a field (see [Rental Schema](https://demo.platforms.bookingsync.com/api-docs/index.html)).
But it makes sense to sync availabilities more often than other information.

> We suggest to refresh rentals availabilities every hour

The best practice here would be to set the parameter `fields`. It allows to fetch only required fields, in our case `availability`. We also recommend to disable rentals during availabilities update.

TODO: choose approach 1 or approach 2

<!-- Approach 1: Fetch batches. No beautiful, but more effective -->
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

Account.approved.each do |account|
  account_rentals_ids = Rental.for_account(account).pluck(:id)
  page_number = 1

  while true do
    request = Excon.new(URI.join(api_url, "/api/ota/v1/rentals?page[number]=#{page_number}&page[size]=50&filter[account-id]=#{account.id}&fields[rentals]=availability").to_s, options)

    response = request.request({ method: :get })
    json = JSON.parse(response.body)
    json["data"].each do |rental|
      update_rental_availability(rental)
    end

    account_rentals_ids -= json["data"].pluck("id").map(&:to_i)
    break if page_number >= json["meta"]["pagination"]["pages"].to_i
    page_number++
  end
  disable_rentals(account_rentals_ids)
end
~~~

<!-- Approach 2: Better code, but less effective -->
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

Rental.each do |rental|
  request = Excon.new(URI.join(api_url, "/api/ota/v1/rentals/#{rental.remote_id}&fields[rentals]=availability").to_s, options)

  response = request.request({ method: :get })
  if response.code == 200
    json = JSON.parse(response.body)
    update_rental_availability(rental["data"]["attributes"]["availability"])
    make_rental_visible_if_was_hidden(rental)
  else
    hide_rental(rental)
  end
end
~~~

## Understanding availabilities

The regular availability object looks like:

~~~ruby
{
  "map": "0001111111111111111111111111100111111111111111110000000001111111111111111111111111111111111111111000001111111100111111100011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "start-date": "2023-07-01",
  "id": "2"
}
~~~

It has a `map` with statuses for the next 1096 days starting starting from the date indicated by `start-date`. '0' means available, '1' means unavailable.

Scope for ActiveRecord rental model could look like (assuming you are using Postgres and named `availability[map]` as `availability_map` and `availability[start_date]` as `availability_start_date`):

TODO: add raw SQL

~~~ruby
  scope :by_availabilities, ->(date, length) {
    unavailable_status = '1'
    start_point = "DATE_PART('day', TIMESTAMP :date - availability_start_date)::integer+1"
    availability_to_check_sql = "SUBSTR(availability_map, #{start_point}, :length_of_stay)"
    where("#{availability_to_check_sql} NOT SIMILAR TO :check_statuses", date: date, length_of_stay: length, check_statuses: unavailable_status)
  }
~~~

## Get rentals prices

Before we start, please read an article [Understanding LOS Records](https://developers.bookingsync.com/guides/understanding-los-records/). It explains what is LOS records and how it works.
We generate LOS records for the next 18 months, starting from yesterday.

To get rental prices better to use `/api/ota/v1/los-record-export-urls` endpoint. It will return a list of CSV files with LOS records for rentals. CSV files will look like:


> /los-records for debug only! Don't use it!

~~~bash
id;account_id;rental_id;currency;min_occupancy;max_occupancy;kind;day;rates
45086517195;1;11;EUR;1;4;final_price;2023-07-25;{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,12501.45,13741.65,14981.85,16222.05,17462.25,18702.45,19942.65,21182.85,22423.05,23663.25,24903.45,26143.65,27383.85,28624.05,29864.25,31104.45,32344.65,33584.85,34825.05,36065.25,37305.45}
46986331108;2;22;EUR;1;1;final_price;2023-07-25;{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,4422.6}
47234184996;3;33;EUR;1;1;final_price;2023-07-25;{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,4422.6}
47235754161;4;44;EUR;1;1;final_price;2023-07-25;{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,4422.6}
47844857128;5;55;EUR;1;4;final_price;2023-07-25;{0.0,0.0,0.0,0.0,0.0,0.0,1096.2,1252.8,1409.4,1566.0,1722.6,1879.2,2035.8,2192.4,2349.0,2505.6,2662.2,2818.8,2975.4,3132.0,3288.6,3445.2,3601.8,3758.4,3915.0,4071.6,4228.2,4384.8,4541.4,4698.0}
~~~

There are 3 kinds of LOS records ([LOS kinds](https://developers.bookingsync.com/reference/enums/#los-kinds)):

  1. **rental_price** - Price for the rent only, after all discounts applied.
  2. **rental_price_before_special_offers** - Price for the rent only, before special offers discounts being applied.
  3. **final_price** - Price including all required fees and taxes.

If you want to avoid price discrepancy, you have to use **rental_price** and apply all the fees and taxes on your side. Otherwise just use **final_price**.
TODO: EXPLAIN search price and booking price difference

> We update LOS files every 12 hours.

## Filter rentals by price

We suggest to create a table for LOS records and import prices from CSV files into this table.

TODO: add raw SQL

~~~sql
  create_table "eur_los_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "synced_id", null: false
    t.date "day", null: false
    t.integer "min_occupancy"
    t.integer "max_occupancy"
    t.bigint "rental_id", null: false
    t.decimal "rates_eur", default: [], array: true
    t.string "kind"
    t.bigint "account_id"
    t.index ["account_id", "day", "rental_id"], name: "index_elr_on_rental_account_day_rental"
    t.index ["rental_id", "account_id", "day"], name: "index_elr_on_day_rental_account"
  end
~~~

~~~ruby
class EurLosRecord < ApplicationRecord
  # Helper scopes
  scope :by_occupancy, -> (occupancy) {
    occupancy.to_i > 0 ? where("max_occupancy >= ? AND min_occupancy <= ?", occupancy, occupancy) : by_default
  }
  scope :by_default, -> { where(min_occupancy: 1) }
  scope :by_date, -> (date) { where(day: date) }
  scope :possible_to_stay_for, -> (length) { where("rates_eur[:length] IS NOT NULL", length: length) }
  scope :by_min_max_price_eur, -> (length, min_price_eur, max_price_eur) {
    by_min_price_eur(length, min_price_eur).by_max_price_eur(length, max_price_eur)
  }
  scope :by_min_price_eur, -> (length, min_price_eur) {
    if min_price_eur.present?
      where("rates_eur[:length] >= :min_price_eur", length: length, min_price_eur: min_price_eur)
    end
  }
  scope :by_max_price_eur, -> (length, max_price_eur) {
    if max_price_eur.present?
      where("rates_eur[:length] <= :max_price_eur", length: length, max_price_eur: max_price_eur)
    end
  }
  # The main search scope
  scope :by_occupancy_date_rate_price, ->(occupancy, date, length, min_price_eur, max_price_eur, los_kind = nil) {
    scope = by_occupancy(occupancy).by_date(date)
    scope = scope.by_kind(los_kind) if los_kind.present?
    scope.possible_to_stay_for(length)
      .by_min_max_price_eur(length, min_price_eur, max_price_eur)
  }
end
~~~

In controller you can use this scope like:

~~~ruby
  # `by_availabilities` scope was described above
  @rentals = Rental.by_availabilities(params[:date], params[:length])
  @rentals = @rentals
    .joins(:eur_los_records)
    .merge(EurLosRecord.by_occupancy_date_rate_price(params[:occupancy], params[:date], params[:length], params[:min_price], params[:max_price]))
~~~