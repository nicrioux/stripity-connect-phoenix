defmodule Connectdemo.PageController do
  use Connectdemo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def oauth_callback(conn, %{"code" => code, "state" => state}) do
    #validate csrf

    #extract code
    {:ok, resp} = Stripe.Connect.oauth_token_callback code
    #or  (nb code is only valid for 1 callback)
    #api_key =  Stripe.Connect.get_token code
    IO.inspect resp
    render conn, "success.html", api_key: resp[:access_token]  
  end

  def oauth_callback(conn, %{"error" => error, "error_description" => description}) do
    IO.puts "error occured"
    IO.inspect error
    IO.inspect description
    render conn, "error.html", error: error, resp: description 
  end
end
