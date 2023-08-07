# Rentals synchronization

1. TOC
{:toc}

## Preface

After successfully onboarding accounts, you can initiate the process to import their rentals into your system.

## Getting Basic Rental Information

For detailed specifications and endpoint details, refer to the [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)

> Recommendation: We advise refreshing rental base information once a day

### Code Examples

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"
ACCOUNT_ID="ACCOUNT_ID"

curl -X GET \
  "$API_URL/api/ota/v1/rentals?page[number]=1&page[size]=50&filter[account-id]=$ACCOUNT_ID" \
  -H "User-Agent: API Client" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer $TOKEN"
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

Account.approved.each do |account|
  page_number = 1
  while true do
    request = Excon.new(URI.join(api_url, "/api/ota/v1/rentals?page[number]=#{page_number}&page[size]=50&filter[account-id]=#{account.id}").to_s, options)

    response = request.request({ method: :get })
    json = JSON.parse(response.body)
    json["data"].each do |rental|
      # Import rental
      import_rental(rental)
    end

    break if page_number >= json["meta"]["pagination"]["pages"].to_i
    page_number++
  end
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

# Assuming you have a function to get approved accounts: get_approved_accounts()
approved_accounts = get_approved_accounts()

for account in approved_accounts:
    page_number = 1
    while True:
        url = f"{api_url}/api/ota/v1/rentals?page[number]={page_number}&page[size]=50&filter[account-id]={account['id']}"
        response = requests.get(url, headers=headers)
        data = json.loads(response.text)

        for rental in data["data"]:
            # Import rental
            import_rental(rental)

        if page_number >= data["meta"]["pagination"]["pages"]:
            break

        page_number += 1
----java
import okhttp3.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;

public class AccountSynchronization {

    public static void main(String[] args) {
        String token = "YOUR_TOKEN";
        String api_url = "API_URL";
        MediaType mediaType = MediaType.parse("application/vnd.api+json");

        OkHttpClient client = new OkHttpClient();

        // Assuming you have a function to retrieve approved account IDs: getApprovedAccountIds()
        JSONArray approvedAccountIds = getApprovedAccountIds();

        for (int i = 0; i < approvedAccountIds.length(); i++) {
            int accountId = approvedAccountIds.getInt(i);
            int pageNumber = 1;
            while (true) {
                String url = api_url + "/api/ota/v1/rentals?page[number]=" + pageNumber + "&page[size]=50&filter[account-id]=" + accountId;

                Request request = new Request.Builder()
                        .url(url)
                        .addHeader("User-Agent", "API Client")
                        .addHeader("Accept", mediaType.toString())
                        .addHeader("Content-Type", mediaType.toString())
                        .addHeader("Authorization", "Bearer " + token)
                        .build();

                try {
                    Response response = client.newCall(request).execute();
                    JSONObject data = new JSONObject(response.body().string());

                    JSONArray rentals = data.getJSONArray("data");
                    for (int j = 0; j < rentals.length(); j++) {
                        // Import rental
                        importRental(rentals.getJSONObject(j));
                    }

                    if (pageNumber >= data.getJSONObject("meta").getJSONObject("pagination").getInt("pages")) {
                        break;
                    }

                    pageNumber++;
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // Define your functions here:
    private static JSONArray getApprovedAccountIds() {
        // Implement your logic to get approved account IDs
        return new JSONArray();
    }

    private static void importRental(JSONObject rental) {
        // Implement your logic to import rentals
    }
}
--end--

## Fetching Rental Availabilities

Availability is a just a rental field (see [Rental Schema](https://demo.platforms.bookingsync.com/api-docs/index.html)). But it makes sense to sync availabilities more often than other information.

> Recommendation: We suggest refreshing rental availabilities every hour.

To optimize the retrieval process, it's recommended to use the fields parameter when fetching rental data. By specifying `fields[rentals]=availability`, you can streamline the API response to include only the necessary availability information, improving efficiency.

<!-- TODO: choose approach 1 or approach 2 -->

### Code Examples

| cURL | Ruby 1 | Ruby 2 | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"
ACCOUNT_ID="ACCOUNT_ID"

curl -X GET \
  "$API_URL/api/ota/v1/rentals?page[number]=1&page[size]=50&filter[account-id]=$ACCOUNT_ID&fields[rentals]=availability" \
  -H "User-Agent: API Client" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer $TOKEN"
----ruby
# Approach 1: Fetch batches. No beautiful, but more effective
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
----ruby
# Approach 2: Better code, but less effective
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

# Assuming you have a function to get approved accounts: get_approved_accounts()
approved_accounts = get_approved_accounts()

for account in approved_accounts:
    # Assuming you have a function to get rentals for account: get_rentals_for_account(account)
    account_rentals_ids = get_rentals_for_account(account)
    page_number = 1
    while True:
        url = f"{api_url}/api/ota/v1/rentals?page[number]={page_number}&page[size]=50&filter[account-id]={account['id']}&fields[rentals]=availability"
        response = requests.get(url, headers=headers)
        data = json.loads(response.text)

        for rental in data["data"]:
            # Assuming you have a function to update rental availability: update_rental_availability(rental)
            update_rental_availability(rental)

        account_rentals_ids -= [rental['id'] for rental in data["data"]]
        if page_number >= data["meta"]["pagination"]["pages"]:
            break

        page_number += 1

    # Assuming you have a function to disable rentals: disable_rentals(account_rentals_ids)
    disable_rentals(account_rentals_ids)
----java
import okhttp3.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class AccountSynchronization {

    public static void main(String[] args) {
        String token = "YOUR_TOKEN";
        String api_url = "API_URL";
        MediaType mediaType = MediaType.parse("application/vnd.api+json");

        OkHttpClient client = new OkHttpClient();

        // Assuming you have a function to retrieve approved account IDs: getApprovedAccountIds()
        List&lt;Integer&gt; approvedAccountIds = getApprovedAccountIds();

        for (int accountId : approvedAccountIds) {
            // Assuming you have a function to get rentals for account: getRentalsForAccount(accountId)
            List&lt;Integer&gt; accountRentalsIds = getRentalsForAccount(accountId);
            int pageNumber = 1;
            while (true) {
                String url = api_url + "/api/ota/v1/rentals?page[number]=" + pageNumber + "&page[size]=50&filter[account-id]=" + accountId + "&fields[rentals]=availability";

                Request request = new Request.Builder()
                        .url(url)
                        .addHeader("User-Agent", "API Client")
                        .addHeader("Accept", mediaType.toString())
                        .addHeader("Content-Type", mediaType.toString())
                        .addHeader("Authorization", "Bearer " + token)
                        .build();

                try {
                    Response response = client.newCall(request).execute();
                    JSONObject data = new JSONObject(response.body().string());

                    JSONArray rentals = data.getJSONArray("data");
                    for (int j = 0; j < rentals.length(); j++) {
                        // Assuming you have a function to update rental availability: updateRentalAvailability(rental)
                        updateRentalAvailability(rentals.getJSONObject(j));
                        accountRentalsIds.remove(Integer.valueOf(rentals.getJSONObject(j).getInt("id")));
                    }

                    if (pageNumber >= data.getJSONObject("meta").getJSONObject("pagination").getInt("pages")) {
                        break;
                    }

                    pageNumber++;
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            // Assuming you have a function to disable rentals: disableRentals(accountRentalsIds)
            disableRentals(accountRentalsIds);
        }
    }

    // Define your functions here:
    private static List&lt;Integer&gt; getApprovedAccountIds() {
        // Implement your logic to get approved account IDs
        return new ArrayList&lt;&gt;();
    }

    private static List&lt;Integer&gt; getRentalsForAccount(int accountId) {
        // Implement your logic to get rentals for account
        return new ArrayList&lt;&gt;();
    }

    private static void updateRentalAvailability(JSONObject rental) {
        // Implement your logic to update rental availability
    }

    private static void disableRentals(List&lt;Integer&gt; rentalIds) {
        // Implement your logic to disable rentals
    }
}
--end--

## Understanding availabilities

The regular availability object consists of a map field, which contains statuses for the next 1096 days starting from the `start-date`. A status of '0' indicates availability, while '1' indicates unavailability.

~~~ruby
{
  "map": "0001111111111111111111111111100111111111111111110000000001111111111111111111111111111111111111111000001111111100111111100011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "start-date": "2023-07-01",
  "id": "2"
}
~~~

Scope for ActiveRecord rental model could look like (assuming you are using Postgres and named `availability[map]` as `availability_map` and `availability[start_date]` as `availability_start_date`):

### Code Examples

| Ruby | SQL Query |
----ruby
  scope :by_availabilities, ->(date, length) {
    unavailable_status = '1'
    start_point = "DATE_PART('day', TIMESTAMP :date - availability_start_date)::integer+1"
    availability_to_check_sql = "SUBSTR(availability_map, #{start_point}, :length_of_stay)"
    where("#{availability_to_check_sql} NOT SIMILAR TO :check_statuses", date: date, length_of_stay: length, check_statuses: unavailable_status)
  }
----sql
SELECT r.id
FROM rentals r
WHERE
  SUBSTRING(r.availability_map,
            DATE_PART('day', TIMESTAMP '2023-07-01' - r.availability_start_date)::integer + 1,
            7)
  NOT SIMILAR TO '1';

-- `2023-07-01` - is a sample start date, `7` is a sample length of stay.
--end--

## Fetching Rental Prices

Before we start, please read an article [Understanding LOS Records](https://developers.bookingsync.com/guides/understanding-los-records/). It explains what is LOS records and how it works.
We generate LOS records for the next 18 months, starting from yesterday.

> Attention! `/los-records` is for debugging purposes only! Please don't use it in production mode!

To fetch rental prices, it is recommended to use `/api/ota/v1/los-record-export-urls` endpoint. This endpoint provides CSV files containing LOS records for rentals.
CSV files look like:

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
Read more about [difference between rental price and final price](/guides/difference-between-rental-price-and-final-price/).

> Recommendation: We update LOS files every 12 hours.

## Filtering Rentals by Price

To effectively filter rentals by price, consider creating a table for LOS records and importing prices from CSV files into this table. We suggest the following table structure:

~~~sql
CREATE TABLE public.eur_los_records_v5 (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    synced_id bigint NOT NULL,
    day date NOT NULL,
    min_occupancy integer,
    max_occupancy integer,
    synced_rental_id bigint NOT NULL,
    rates_eur numeric[] DEFAULT '{}'::numeric[],
    kind character varying,
    synced_account_id bigint
);
~~~

**Sample ActiveRecord model for EUR LOS records**

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

In controller you can use this scope to filter rentals:

~~~ruby
  # `by_availabilities` scope was described above
  @rentals = Rental.by_availabilities(params[:date], params[:length])
  @rentals = @rentals
    .joins(:eur_los_records)
    .merge(EurLosRecord.by_occupancy_date_rate_price(params[:occupancy], params[:date], params[:length], params[:min_price], params[:max_price]))
~~~