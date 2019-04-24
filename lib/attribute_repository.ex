defmodule AttributeRepository do
  @typedoc """
  Options used at initialisation only
  """

  @type init_opts :: Keyword.t()

  @typedoc """
  Options used at runtime
  """

  @type run_opts :: Keyword.t()

  @typedoc """
  The name of a running instance of an implementation of `AttributeRepository`
  """

  @type running_instance :: atom()

  @typedoc """
  Attribute name

  An attribute is case-insensitive
  """

  @type attribute_name :: String.t()

  @typedoc """
  Binary data

  It is not required to Base64-encode binary data
  """

  @type binary_data() :: {:binary_data, binary()}

  @type ref :: {:ref, running_instance(), resource_id()}

  @typedoc """
  Simple attribute types
  """

  @type simple_attribute ::
          String.t()
          | boolean()
          | float()
          | integer()
          | DateTime.t()
          | binary_data()
          | ref()
          | nil

  @type object_attribute :: %{required(attribute_name) => simple_attribute()}

  @type attribute_value :: simple_attribute() | object_attribute()

  @type attribute_data_type :: attribute_value() | [attribute_value()]

  @typedoc """
  A resource id is the identifier by which an entity is managed

  It can be constrained in some implementation such as for LDAP servers, in which the resource
  id is the object's DN
  """

  @type resource_id :: String.t()

  @type resource :: %{required(attribute_name()) => attribute_data_type()}

  defmodule ReadError do
    @moduledoc """
    Error returned when a technical error prevents from reading from the backend
    """

    defexception message: "Read error"
  end

  defmodule WriteError do
    @moduledoc """
    Error returned when a technical error prevents from writing to the backend
    """

    defexception message: "Write error"
  end

  defmodule UnsupportedError do
    @moduledoc """
    Error returned when a `AttributeRepository` feature is not supported by the
    current impementation
    """

    defexception message: "Unsupported"

    def exception(), do: %__MODULE__{}
  end
end
