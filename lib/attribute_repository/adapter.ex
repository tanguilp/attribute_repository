defmodule AttributeRepository.Adapter do
  @moduledoc """
  Behaviour definition for adapters

  Adapters implement the necessary functions to communicate with a backend storing the real data,
  such as an LDAP server, an SQL database, a SCIM endpoint...
  """

  alias AttributeRepository.Schema

  @typedoc """
  Any keyword containing the adapter options

  For instance, hostname, port and credentials to access any external database server.
  """
  @type adapter_opts :: Keyword.t()
  @type search_result :: [search_entry()]
  @type search_entry :: {AttributeRepository.resource_id(), AttributeRepository.resource()}

  @doc """
  Deletes a resource
  """
  @callback delete(
    resource_id :: AttributeRepository.resource_id(),
    adapter_opts()
  ) :: :ok | {:error, Exception.t()}

  @doc """
  Gets a resource form the `resource_id`
  """
  @callback get(
    AttributeRepository.resource_id(),
    [AttributeRepository.attribute_name()] | :all,
    adapter_opts()
  ) :: {:ok, AttributeRepository.resource()} | {:error, Exception.t()}

  @doc """
  Configures or installs the adapter

  The callback shall return `:ok` when the repository is already installed.
  """
  @callback install(adapter_opts()) :: :ok | {:error, Exception.t()}

  @doc """
  Modifies attributes of a resource
  """
  @callback modify(
    AttributeRepository.resource_id(),
    [ChangeSet.modify_op()],
    adapter_opts()
  ) :: :ok | {:error, Exception.t()}

  @doc """
  Replaces a new resource
  """
  @callback put(
    AttributeRepository.resource_id(),
    AttributeRepository.resource(),
    adapter_opts()
  ) :: :ok | {:error, Exception.t()}

  @doc """
  Returns the schema

  This function is called everytime a new changeset is created, which means very often. An
  implementation should take into consideration performance issues so that it does not
  become a bottleneck (for instance, by caching the schema locally).
  """
  @callback schema(adapter_opts()) :: Schema.t()

  @doc """
  Search for resources using the filter.
  """
  @callback search(
    AttributeRepository.Search.Filter.t(),
    [AttributeRepository.attribute_name()] | :all,
    adapter_opts()
  ) :: {:ok, search_result()} | {:error, Exception.t()}

  @doc """
  Launches an attribute repository

  Returns `:ok` or an error. This callback is to be used when the attribute repository
  cannot be supervised, such as Mnesia.
  """
  @callback start(adapter_opts()) :: :ok | {:error, Exception.t()}

  @doc """
  Launches a supervised attribute repository

  Returns `{:ok, pid}` or an error like the `Supervisor.start_link/2` function. This
  callback is to be used when the attribute repository can be supervised.
  """

  @callback start_link(adapter_opts()) :: Supervisor.on_start()

  defmacro __using__(opts) do
    quote do
      @behaviour AttributeRepository.Adapter

      def adapter_opts(), do: unquote(opts[:adapter_opts]) || []

      if function_exported?(__MODULE__, :delete, 2) do
        def delete(resource_id) do
          __MODULE__.delete(resource_id, unquote(opts)[:adapter_opts] || [])
        end
      end

      if function_exported?(__MODULE__, :get, 3) do
        def get(resource_id, attributes_or_all) do
          __MODULE__.get(resource_id, attributes_or_all, unquote(opts)[:adapter_opts] || [])
        end
      end

      if function_exported?(__MODULE__, :install, 1) do
        def install(), do: __MODULE__.install(unquote(opts)[:adapter_opts] || [])
      end

      if function_exported?(__MODULE__, :modify, 3) do
        def modify(resource_id, resource) do
          __MODULE__.modify(resource_id, changes, unquote(opts)[:adapter_opts] || [])
        end
      end

      if function_exported?(__MODULE__, :put, 3) do
        def put(resource_id, resource) do
          __MODULE__.put(resource_id, resource, unquote(opts)[:adapter_opts] || [])
        end
      end

      @doc """
      Returns the schemas of the current module

      Returns the implementation schema (if any) and the locally defined schema (if any). If
      none is defined, an empty list is returned.
      """
      @spec schemas() :: [Schema.t()]
      def schemas() do
        quote do
          if function_exported?(__MODULE__, :__schema__, 0) do
            [__MODULE__.__schema__()]
          else
            []
          end
        end
        ++
        quote do
          if function_exported?(__MODULE__, :schema, 1) do
            [__MODULE__.schema(unquote(opts)[:adapter_opts] || [])]
          else
            []
          end
        end
      end

      if function_exported?(__MODULE__, :search, 3) do
        def search(filter, attributes_or_all) do
          __MODULE__.search(filter, attributes_or_all, unquote(opts)[:adapter_opts] || [])
        end
      end

      if function_exported?(__MODULE__, :start, 1) do
        def start(), do: __MODULE__.start(unquote(opts)[:adapter_opts] || [])
      end

      if function_exported?(__MODULE__, :start_link, 1) do
        def start_link(), do: __MODULE__.start_link(unquote(opts)[:adapter_opts] || [])
      end

      defoverridable generate_id: 2
    end
  end

  @doc """
  Generates a URL-base64 random ID with 192 bits of entropy with a length of 32 characters

  Can be used by adapters' implementation to generate resource IDs, when needed.

  ## Example

      iex> AttributeRepository.Adapter.generate_id()
      "h3gD8EfuWiqP0sLY8HHScOg0Zzn3lGzV"
      iex> AttributeRepository.Adapter.generate_id()
      "TovIJ2RM6-w70pUHzsD8dH7pJUANyIVA"
  """
  def generate_id(), do: :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)

  @optional_callbacks \
    delete: 2,
    get: 3,
    install: 1,
    modify: 3,
    put: 3,
    search: 3,
    schema: 1,
    start: 1,
    start_link: 1
end
