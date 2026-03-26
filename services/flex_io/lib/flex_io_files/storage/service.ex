defmodule FlexIoFiles.Storage.Service do

  defp get_adapter do
    Application.get_env(:flex_io_files, :storage_adapter, FlexIoFiles.Storage.Adapters.S3)
  end

  defp validate_params(%{bucket: bucket, folder: folder, key: key}) do
    cond do
      String.contains?(bucket, "..") -> {:error, :invalid_bucket}
      String.contains?(folder, "..") -> {:error, :invalid_folder}
      String.contains?(key, "..") -> {:error, :invalid_key}
      String.starts_with?(key, "/") -> {:error, :invalid_key}
      true -> {:ok, %{bucket: bucket, folder: folder, key: key}}
    end
  end

  def upload(params, file_content, content_type \\ "application/octet-stream") do
    with {:ok, safe_params} <- validate_params(params),
         adapter <- get_adapter() do
      adapter.upload(safe_params, file_content, content_type)
    end
  end

  def download(params) do
    with {:ok, safe_params} <- validate_params(params),
         adapter <- get_adapter() do
      adapter.download(safe_params)
    end
  end

  def delete(params) do
    with {:ok, safe_params} <- validate_params(params),
         adapter <- get_adapter() do
      adapter.delete(safe_params)
    end
  end

  def generate_url(params, opts \\ []) do
    with {:ok, safe_params} <- validate_params(params),
         adapter <- get_adapter() do
      adapter.generate_url(safe_params, opts)
    end
  end
end
