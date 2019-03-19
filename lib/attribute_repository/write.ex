defmodule AttributeRepository.Write do
  @moduledoc """
  """

  @callback put(
    AttributeRepository.resource_id(),
    AttributeRepository.resource(),
    AttributeRepository.run_opts()
  ) :: {:ok, AttributeRepository.resource()}
  | {:error, %AttributeRepository.WriteError{}}

  @callback modify(
    AttributeRepository.resource_id(),
    [modify_op()],
    AttributeRepository.run_opts()
  ) :: :ok
  | {:error, %AttributeRepository.WriteError{}}

  @type modify_op :: modify_op_add() | modify_op_replace() | modify_op_delete()

  @type modify_op_add ::
    {:add, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}

  @type modify_op_replace ::
    {:replace, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}
  | {:replace,
    AttributeRepository.attribute_name(),
    AttributeRepository.attribute_value(),
    AttributeRepository.attribute_value()}

  @type modify_op_delete ::
    {:delete, AttributeRepository.attribute_name()}
  | {:delete, AttributeRepository.attribute_name(), AttributeRepository.attribute_value()}

  @callback delete(
    AttributeRepository.resource_id(),
    AttributeRepository.run_opts()
  ) :: :ok
  | {:error, %AttributeRepository.WriteError{}}
  | {:error, %AttributeRepository.Read.NotFoundError{}}

  defmacro __using__(_opts) do
    quote do
      def put!(resource_id, resource, opts) do
        case put(resource_id, resource, opts) do
          {:ok, resource} ->
            resource

          {:error, exception} ->
            raise exception
        end
      end

      def delete!(resource_id, opts) do
        case delete(resource_id, opts) do
          :ok ->
            :ok

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
