defmodule AttributeRepository.Search do
  @moduledoc """
  """

  @callback search(
    AttributeRepository.Search.Filter.t(),
    [AttributeRepository.attribute()] | :all,
    AttributeRepository.run_opts()
  ) :: {:ok, [AttributeRepository.resource()]}
  | {:error, %AttributeRepository.ReadError{}}
end
