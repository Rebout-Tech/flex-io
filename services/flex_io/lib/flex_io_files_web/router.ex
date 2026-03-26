defmodule FlexIoFilesWeb.Router do
  use FlexIoFilesWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FlexIoFilesWeb do
    pipe_through :api

    post "/files", FileController, :upload
    get "/files", FileController, :download
    delete "/files", FileController, :delete
    get "/files/url", FileController, :get_url
  end
end
