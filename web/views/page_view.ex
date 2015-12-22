defmodule Connectdemo.PageView do
  use Connectdemo.Web, :view

  def stripe_connect_workflow_url do
    stripe_csrf_token = "a token saved in session"
    Stripe.Connect.generate_button_url stripe_csrf_token
  end
end
