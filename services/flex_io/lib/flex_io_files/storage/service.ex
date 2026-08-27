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

  def generate_urls(file_infos, opts \\ []) when is_list(file_infos) do
    adapter = get_adapter()

    {valid_params, invalid_params} =
      Enum.reduce(file_infos, {[], []}, fn params, {valid, invalid} ->
        case validate_params(params) do
          {:ok, safe_params} -> {[safe_params | valid], invalid}
          {:error, reason} -> {valid, [%{params: params, reason: reason} | invalid]}
        end
      end)

    valid_params = Enum.reverse(valid_params)
    invalid_params = Enum.reverse(invalid_params)

    case {valid_params, invalid_params} do
      {[], _} -> {:ok, [], invalid_params}

      {valid, []} ->
        case adapter.generate_urls(valid, opts) do
          {:ok, urls} -> {:ok, urls}
          {:ok, urls, errors} -> {:ok, urls, errors}
          {:error, reason} -> {:error, reason}
        end

      {valid, invalid} ->
        case adapter.generate_urls(valid, opts) do
          {:ok, urls} -> {:ok, urls, invalid}
          {:ok, urls, errors} -> {:ok, urls, invalid ++ errors}
          {:error, reason} -> {:error, reason}
        end
    end
  end
end
