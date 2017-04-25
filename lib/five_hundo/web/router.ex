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
  end

  scope "/", FiveHundo.Web do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/api", FiveHundo.Web do
    pipe_through :api

    scope "/entries" do
      get "/today", EntriesController, :today
      post "/save", EntriesController, :save
    end
  end
end
