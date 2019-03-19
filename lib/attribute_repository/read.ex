defmodule AttributeRepository.Read do
  @moduledoc """
  """

  @callback get(
    AttributeRepository.resource_id(),
    [AttributeRepository.attribute_name()] | :all,
    AttributeRepository.run_opts()
  ) :: {:ok, AttributeRepository.resource()}
  | {:error, %AttributeRepository.ReadError{}}
  | {:error, %__MODULE__.NotFoundError{}}

  defmacro __using__(_opts) do
    quote do
      def get!(resource_id, attributes, opts) do
        case get(resource_id, attributes, opts) do
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
