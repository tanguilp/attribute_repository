defmodule AttributeRepository.Read do
  @moduledoc """
  """

  @callback read(
    AttributeRepository.resource_id(),
    [AttributeRepository.attribute()],
    AttributeRepository.run_opts()
  ) :: {:ok, AttributeRepository.resource()}
  | {:error, %AttributeRepository.ReadError{}}
  | {:error, %__MODULE__.NotFoundError{}}

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

  defmodule NotFoundError do
    @moduledoc """
    Error returned when a resource expected to be found was not found
    """

    defexception message: "Resource not found"
  end
end
