defmodule FlexIoFilesWeb.Router do
  use FlexIoFilesWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FlexIoFilesWeb do
    pipe_through :api

    # post "/files", FileController, :upload
    # get "/files/:id", FileController, :show
    # get "/files/:id/link", FileController, :link
    # delete "/files/:id", FileController, :delete
  end
end
