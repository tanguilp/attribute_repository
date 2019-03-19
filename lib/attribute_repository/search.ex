defmodule AttributeRepository.Search do
  @moduledoc """
  """

  @type search_result :: [search_entry()]

  @type search_entry :: {AttributeRepository.resource_id(), AttributeRepository.resource()}

  @callback search(
    AttributeRepository.Search.Filter.t(),
    [AttributeRepository.attribute_name()] | :all,
    AttributeRepository.run_opts()
  ) :: {:ok, search_result()}
  | {:error, %AttributeRepository.ReadError{}}
end
