defmodule FlexIoFilesWeb.FileController do
  use FlexIoFilesWeb, :controller

  alias FlexIoFiles.Storage.Service

  def upload(conn, %{"bucket" => bucket, "folder" => folder, "key" => key} = params) do
    case params["file"] do
      %Plug.Upload{path: file_path, content_type: content_type, filename: filename} ->
        with {:ok, content} <- File.read(file_path) do
          file_params = %{bucket: bucket, folder: folder, key: key}

          case Service.upload(file_params, content, content_type || "application/octet-stream") do
            {:ok, path} ->
              json(conn, %{status: "success", path: path, filename: filename})

            {:error, reason} ->
              conn
              |> put_status(:bad_request)
              |> json(%{status: "error", reason: inspect(reason)})
          end
        else
          {:error, :enoent} -> conn |> put_status(:bad_request) |> json(%{status: "error", reason: "file not found"})
          {:error, reason} -> conn |> put_status(:internal_server_error) |> json(%{status: "error", reason: inspect(reason)})
        end

      base64_str when is_binary(base64_str) ->
        content = Base.decode64!(base64_str)
        content_type = Map.get(params, "content_type", "application/octet-stream")
        file_params = %{bucket: bucket, folder: folder, key: key}

        case Service.upload(file_params, content, content_type) do
          {:ok, path} -> json(conn, %{status: "success", path: path})
          {:error, reason} -> conn |> put_status(:bad_request) |> json(%{status: "error", reason: inspect(reason)})
        end
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: "file field is required (as multipart or base64)"})
    end
  end

  def download(conn, %{"bucket" => bucket, "folder" => folder, "key" => key}) do
    file_params = %{bucket: bucket, folder: folder, key: key}

    case Service.download(file_params) do
      {:ok, content} ->
        conn
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(200, content)

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end

  def delete(conn, %{"bucket" => bucket, "folder" => folder, "key" => key}) do
    file_params = %{bucket: bucket, folder: folder, key: key}

    case Service.delete(file_params) do
      :ok ->
        json(conn, %{status: "deleted"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end

  def get_url(conn, %{"bucket" => bucket, "folder" => folder, "key" => key} = params) do
    file_params = %{bucket: bucket, folder: folder, key: key}

    expires_in =
      case Integer.parse(params["expires"] || "") do
        {value, _} when value > 0 -> value
        _ -> 3600
    end

    case Service.generate_url(file_params, expires_in: expires_in) do
      {:ok, url} ->
        json(conn, %{status: "success", url: url, expires_in: expires_in})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end

end
