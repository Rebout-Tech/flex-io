defmodule FlexIoFiles.Storage.Behaviour do
  @type file_info :: %{bucket: String.t(), folder: String.t(), key: String.t()}
  @type file_content :: binary() | Stream.t()
  @callback upload(file_info(), file_content(), content_type :: String.t()) :: {:ok, String.t()} | {:error, term()}
  @callback download(file_info()) :: {:ok, file_content()} | {:error, term()}
  @callback delete(file_info()) :: :ok | {:error, term()}
end
