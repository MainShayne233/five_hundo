defmodule FiveHundo.Web.Router do
  use FiveHundo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", FiveHundo.Web do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/api", FiveHundo.Web do
    pipe_through :api

    scope "/authorization" do
      get "/session", AuthorizationController, :session
      post "/authorize", AuthorizationController, :authorize
    end

    scope "/entries" do
      get "/today", EntriesController, :today
      post "/save", EntriesController, :save
    end
  end
end
