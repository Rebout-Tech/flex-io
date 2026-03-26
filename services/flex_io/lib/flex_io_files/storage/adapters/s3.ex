defmodule FlexIoFiles.Storage.Adapters.S3 do
  @moduledoc """
  Адаптер для S3-совместимых хранилищ.
  """
  @behaviour FlexIoFiles.Storage.Behaviour

  @impl true
  def upload(%{bucket: bucket, folder: folder, key: key}, content, content_type) do
    object_key = Path.join([folder, key])

    request =
      ExAws.S3.put_object(bucket, object_key, content, content_type: content_type)

    case ExAws.request(request) do
      {:ok, _} -> {:ok, object_key}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def download(%{bucket: bucket, folder: folder, key: key}) do
    object_key = Path.join([folder, key])

    case ExAws.S3.get_object(bucket, object_key) |> ExAws.request() do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def delete(%{bucket: bucket, folder: folder, key: key}) do
    object_key = Path.join([folder, key])

    case ExAws.S3.delete_object(bucket, object_key) |> ExAws.request() do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
