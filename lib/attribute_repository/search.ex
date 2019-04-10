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

  defmacro __using__(_opts) do
    quote do
      def search(filter_str, attributes, run_opts) when is_binary(filter_str) do
        case AttributeRepository.Search.Filter.parse(filter_str) do
          {:ok, filter} ->
            search(filter, attributes, run_opts)

          {:error, reason} ->
            {:error, AttributeRepository.ReadError.exception(inspect(reason))}
        end
      end
    end
  end
end
