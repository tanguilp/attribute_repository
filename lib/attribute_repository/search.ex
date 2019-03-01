defmodule AttributeRepository.Search do
  @moduledoc """
  """

  @callback search(
    AttributeRepository.Search.Filter.t(),
    [AttributeRepository.attribute()],
    AttributeRepository.run_opts()
  ) :: {:ok, [AttributeRepository.resource()]}
  | {:error, %AttributeRepository.ReadError{}}

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
