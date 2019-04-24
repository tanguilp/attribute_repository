defmodule AttributeRepository.Read do
  @moduledoc """
  Callback for getting a resource from it's identifier
  """

  @doc """
  Gets a resource form the `resource_id`

  When inserting `use AttributeRepository.Read` at the begining of an implementation,
  the `get!/3` banged version will be automatically created.

  ```elixir
  iex> AttributeRepositoryRiak.get("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", :all, run_opts)
  {:ok,
   %{
     "first_name" => "Lisa",
     "last_name" => "Santana",
     "newsletter_subscribed" => true,
     "shoe_size" => 33,
     "subscription_date" => #DateTime<2014-08-30 13:45:45Z>
   }}
  iex> AttributeRepositoryRiak.get("Y4HKZMJ3K5A7IMZFZ5O3O56VC4", ["shoe_size"], run_opts)
  {:ok, %{"shoe_size" => 33}}
  ```
  """

  @callback get(
              AttributeRepository.resource_id(),
              [AttributeRepository.attribute_name()] | :all,
              AttributeRepository.run_opts()
            ) ::
              {:ok, AttributeRepository.resource()}
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
