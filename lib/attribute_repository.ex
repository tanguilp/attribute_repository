defmodule AttributeRepository do
  @typedoc """
  Options used when running the `c:AttributeRepository.Install.install/1` callback
  """

  @type init_opts :: Keyword.t()

  @typedoc """
  Options used at runtime
  """

  @type run_opts :: Keyword.t()

  @type running_instance :: atom()

  @typedoc """
  An attribute is case-insensitive
  """

  @type attribute_name :: String.t()

  @type binary_data() :: {:binary_data, binary()}

  @type ref :: {:ref, running_instance(), resource_id()}

  @typedoc """
  Simple attributes

  Note that even though they are equivalent, `String.t()` denotes UTF-8 string attributes,
  and `binary()` some raw binary data (not necessarily a UTF-8 string).
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

  @type attribute_data_type ::
  attribute_value()
  | [attribute_value()]

  @type resource_id :: String.t()

  @type resource :: %{required(attribute_name()) => attribute_data_type()}

  @type resource_list :: [{resource_id(), resource()}]

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
end
