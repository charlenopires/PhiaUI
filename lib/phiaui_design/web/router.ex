defmodule PhiaUiDesign.Web.Router do
  @moduledoc """
  Router for the PhiaUI Design tool.

  Single-route application: all traffic goes to `EditorLive` which
  manages the full editor UI as a single-page LiveView.
  """

  use Phoenix.Router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhiaUiDesign.Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PhiaUiDesign.Web do
    pipe_through :browser

    live "/", EditorLive, :index
  end
end
