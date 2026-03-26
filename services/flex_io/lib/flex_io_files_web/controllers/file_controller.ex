defmodule FlexIoFilesWeb.FileController do
  use FlexIoFilesWeb, :controller

  alias FlexIoFiles.Storage.Service

  # Загрузка файла
  # Ожидаем JSON: {"bucket": "...", "folder": "...", "key": "...", "content": "BASE64"}
  def upload(conn, %{"bucket" => bucket, "folder" => folder, "key" => key} = params) do
    content_type = Map.get(params, "content_type", "application/octet-stream")

    content =
      case params["content"] do
        nil -> ""
        base64_str -> Base.decode64!(base64_str)
      end

    file_params = %{bucket: bucket, folder: folder, key: key}

    case Service.upload(file_params, content, content_type) do
      {:ok, path} ->
        json(conn, %{status: "success", path: path})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end

  # Скачивание файла
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

  # Удаление файла
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
end
