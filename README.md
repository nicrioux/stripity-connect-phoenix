# Connectdemo

This repo holds a bare-bones phoenix web application demonstrating the "Stripe Connect" feature of the elixir library [Stripity-Stripe](https://github.com/robconery/stripity-stripe).

## Platform Client ID
The first piece of the integrati
on is the configuration that holds the Stripe Connect platform client id.
You obtain the platform client id and configure the redirect url on your stripe account settings, "Connect" tab. Once there, grab the client_id and set the redirect_url to your platform url endpoint that will get called once the onboarding process is done with an authorization code that the stripity-stripe library will use to request an access token for the user who went through the onboarding process.

Have a look in config/dev.exs:
```
config :stripity_stripe, :platform_client_id, "YOUR PLATFORM CLIENT ID"
```

this can also be supplied in an environment variable named STRIPE_PLATFORM_CLIENT_ID (See [config_or_env_platform_client_id](https://github.com/robconery/stripity-stripe/blob/master/lib/stripe.ex).


## Connect onboarding starting url

[Stripe.Connect.generate_button_url csrf_token](https://github.com/robconery/stripity-stripe/blob/master/lib/stripe/connect.ex)

This function generates the url necessary to send the user to the Stripe Connect onboarding process.
```
defmodule Connectdemo.PageView do
  use Connectdemo.Web, :view

    def stripe_connect_workflow_url do
        stripe_csrf_token = "a token saved in session"
        Stripe.Connect.generate_button_url stripe_csrf_token
    end
end
...
<a href="<%= stripe_connect_workflow_url() %>">Start connect workflow</a>
```

## Onboarding workflow return

Once the user has completed the onboarding process on the stripe platform,
the stripe platform makes a call to your platform with the authorization code necessary to perform the oauth token request.

```
from your account connect tab, redirect uri field
http://localhost:4000/stripeconnect
...
from router.ex
get "/stripeconnect", PageController, :oauth_callback
...

defmodule Connectdemo.PageController do
  use Connectdemo.Web, :controller
  ...
  def oauth_callback(conn, %{"code" => code, "state" => state}) do
    #validate csrf (called state by the stripe platform)

    #extract code
    {:ok, resp} = Stripe.Connect.oauth_token_callback code
    #or  (nb code is only valid for 1 callback)
    #api_key =  Stripe.Connect.get_token code
    IO.inspect resp
    render conn, "success.html", api_key: resp[:access_token]  
  end
 ... 
```

The call to Stripe.Connect.oauth_token_callback with the authorization code sent from the stripe platform at the end of the onboarding process, execute the oauth token request to the stripe platform. This will return the following payload (converted to elixir %{})

```
%{
    token_type: "bearer",
    stripe_publishable_key: PUBLISHABLE_KEY,
    scope: "read_write",
    livemode: false,
    stripe_user_id: USER_ID,
    refresh_token: REFRESH_TOKEN,
    access_token: ACCESS_TOKEN
}
```

you could also use the function Stripe.Connect.get_token to only get the access token back.

## Using the oauth access token (your platform user stripe api key)
Once you have a hold of the access token, most stripity-stripe modules functions accept a "key" parameter to execute the API request in the name of the account associated with this api key.
```
{:ok, result} = Stripe.Charges.create 1000,params, key
```


