# Accounts synchronization

1. TOC
{:toc}

## Preface

The Accounts endpoint enables partners to retrieve a list of accounts interested in publishing their listings on the partner's website. Partners can use this endpoint to identify potential accounts for onboarding, which may involve signing contracts and other necessary steps.

## Get All Accounts

Retrieve a list of accounts that wish to publish their listings on a partner's website. Refer to the [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html) for detailed specifications.

> Note: Pagination is not supported for this endpoint.

> Important: If an account is no longer visible in the list, ensure to disable the corresponding account and rentals.

> Recommendation: We suggest to do synchronization of accounts every 12-24 hours.

## Code examples

| cURL | Ruby | Python | Java |
----bash
TOKEN="YOUR_TOKEN"
API_URL="API_URL"

curl -X GET \
  "$API_URL/api/ota/v1/accounts" \
  -H "User-Agent: API Client" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer $TOKEN"
----ruby
require 'excon'
require 'json'

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
request = Excon.new(URI.join(api_url, "/api/ota/v1/accounts").to_s, options)
response = request.request(method: :get)

response.status

already_import_accounts_ids = get_imported_accounts_ids # get an array of already imported accounts, Ex result: [1,2,3]

json = JSON.parse(response.body)
json["data"].each do |account|
  # Import accounts
  import_account(account["id"], account["attributes"]["name"])
end

accounts_for_disabling = already_import_accounts_ids - json["data"].pluck("id")
disable_accounts_and_rentals(accounts_for_disabling) # Disable accounts
----python
import requests

token = "YOUR_TOKEN"
api_url = "API_URL"
media_type = "application/vnd.api+json"
headers = {
    "User-Agent": "API Client",
    "Accept": media_type,
    "Content-Type": media_type,
    "Authorization": f"Bearer {token}"
}
response = requests.get(f"{api_url}/api/ota/v1/accounts", headers=headers)

response_status = response.status_code

# Assuming you have a function to retrieve already imported account IDs: get_imported_accounts_ids
already_import_accounts_ids = get_imported_accounts_ids()

json_data = response.json()
for account in json_data["data"]:
    # Import accounts
    import_account(account["id"], account["attributes"]["name"])

accounts_for_disabling = [account_id for account_id in already_import_accounts_ids if account_id not in [a["id"] for a in json_data["data"]]]
disable_accounts_and_rentals(accounts_for_disabling)  # Disable accounts
----java
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.json.JSONArray;
import org.json.JSONObject;

public class AccountSynchronization {

    public static void main(String[] args) {
        String token = "YOUR_TOKEN";
        String api_url = "API_URL";
        MediaType mediaType = MediaType.parse("application/vnd.api+json");

        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(api_url + "/api/ota/v1/accounts")
                .addHeader("User-Agent", "API Client")
                .addHeader("Accept", mediaType.toString())
                .addHeader("Content-Type", mediaType.toString())
                .addHeader("Authorization", "Bearer " + token)
                .build();

        try {
            Response response = client.newCall(request).execute();
            int responseStatus = response.code();

            // Assuming you have a function to retrieve already imported account IDs: getImportedAccountIds()
            JSONArray alreadyImportAccountIds = getImportedAccountIds();

            JSONObject responseBody = new JSONObject(response.body().string());
            JSONArray accounts = responseBody.getJSONArray("data");

            for (int i = 0; i < accounts.length(); i++) {
                JSONObject account = accounts.getJSONObject(i);
                // Import accounts
                importAccount(account.getInt("id"), account.getJSONObject("attributes").getString("name"));
            }

            JSONArray accountsForDisabling = new JSONArray();
            for (int i = 0; i < alreadyImportAccountIds.length(); i++) {
                int accountId = alreadyImportAccountIds.getInt(i);
                boolean found = false;
                for (int j = 0; j < accounts.length(); j++) {
                    if (accounts.getJSONObject(j).getInt("id") == accountId) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    accountsForDisabling.put(accountId);
                }
            }
            // Disable accounts
            disableAccountsAndRentals(accountsForDisabling);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Define your functions here:
    private static JSONArray getImportedAccountIds() {
        // Implement your logic to get imported account IDs
        return new JSONArray();
    }

    private static void importAccount(int accountId, String accountName) {
        // Implement your logic to import accounts
    }

    private static void disableAccountsAndRentals(JSONArray accountIds) {
        // Implement your logic to disable accounts and rentals
    }
}
--end--

Please replace `YOUR_TOKEN` and `API_URL` with your actual authentication token and API URL in the Python code.

Additionally, make sure you have the necessary functions **get_imported_accounts_ids**, **import_account**, and **disable_accounts_and_rentals** defined and implemented in your Python script.
