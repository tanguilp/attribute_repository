defmodule AttributeRepository.Search do
  @moduledoc """
  """

  @callback search(
    AttributeRepository.Search.Filter.t(),
    [AttributeRepository.attribute()],
    AttributeRepository.run_opts()
  ) :: {:ok, [AttributeRepository.resource()]}
  | {:error, %AttributeRepository.ReadError{}}

  defmacro __using__(_opts) do
    quote do
      def read!(resource_id, attributes, opts) do
        case read(resource_id, attribute, opts) do
          {:ok, resource} ->
            resource

          {:error, exception} ->
            raise exception
        end
      end
    end
  end

  defmodule Filter do
    @type t :: any()
  end

  defmodule NotFoundError do
    @moduledoc """
    Error returned when a resource expected to be found was not found
    """

    defexception message: "Resource not found"
  end
end
