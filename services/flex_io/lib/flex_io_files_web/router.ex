defmodule FlexIoFilesWeb.Router do
  use FlexIoFilesWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FlexIoFilesWeb do
    pipe_through :api

    post "/files/upload", FileController, :upload
    get "/files", FileController, :download
    delete "/files", FileController, :delete
    get "/files/url", FileController, :get_url
    post "/files/urls", FileController, :get_urls
  end
end
