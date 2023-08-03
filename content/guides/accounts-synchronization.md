# Accounts synchronization

1. TOC
{:toc}

## Preface

With this endpoint you can import all accounts who wants to publish their listings on your website. As a next step you can sign a contracts with these accounts if needed, create accounts on your side, etc.

## Get all accounts

You can find detailed specification in [Swagger documentation](https://demo.platforms.bookingsync.com/api-docs/index.html)

> This endpoint does not support pagination.

> Don't forget to disable accounts and their rentals if you don't see them anymore in current list

> We suggest to do synchronization of accounts every 12-24 hours.

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
request = Excon.new(URI.join(api_url, "/api/ota/v1/accounts").to_s, options)
response = request.request({ method: :get })

response.status

already_import_accounts_ids = get_imported_accounts_ids # get an array of already imported accounts, Ex result: [1,2,3]

json = JSON.parse(response.body)
json["data"].each do |account|
  # Import accounts
  import_account(account["id"], account["attributes"]["name"])
end

accounts_for_disabling = already_import_accounts_ids - json["data"].pluck("id")
disable_accounts_and_rentals(accounts_for_disabling) # Disable accounts
~~~
