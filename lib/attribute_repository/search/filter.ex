defmodule AttributeRepository.Search.Filter do
  @type t :: {:attr_exp, attr_exp()} | log_exp() | value_path() | {:not, t()}

  @type attr_exp :: {:pr, attr_path()} | {compare_op(), attr_path(), comp_value()}

  @type log_exp :: {:and, t(), t()} | {:or, t(), t()}

  @type value_path :: {:value_path, attr_path(), val_filter()}

  @type val_filter :: attr_exp() | val_log_exp() | val_filter() | {:not, val_filter()}

  @type val_log_exp ::
          {:and, attr_exp(), val_log_exp()}
          | {:and, attr_exp(), attr_exp()}
          | {:or, attr_exp(), val_log_exp()}
          | {:or, attr_exp(), attr_exp()}

  @type compare_op :: :eq | :ne | :gt | :ge | :lt | :le | :co | :sw | :ew

  @type comp_value :: true | false | nil | String.t() | integer() | float() | DateTime.t()

  @typedoc """
  Tuple compose of `{:attr_path, uri_or_nil, attribute, subattribute_or_nil}`
  """
  @type attr_path :: {
    :attr_path,
    uri() | nil,
    AttributeRepository.attribute_name(),
    AttributeRepository.attribute_name() | nil
  }

  @type uri :: String.t()

  @operators [:eq, :ne, :lt, :le, :gt, :ge, :co, :sw, :ew]

  @doc """
  Parses an expression an returns an ok tuple with the AST or an error tuple with an exception

  ## Example

      iex> AttributeRepository.Search.Filter.parse(~s(surname co "Tchang"))
      {:ok, {:attr_exp, {:co, {:attr_path, nil, "surname", nil}, "Tchang"}}}

      iex> AttributeRepository.Search.Filter.parse(~s(subscription_date gt "2013-12-12T23:12:33Z" or lastname ew "ed" and email[value ew "@mail.tv" and type eq "work"]))
      {:ok,
       {:or,
        {:attr_exp,
         {:gt, {:attr_path, nil, "subscription_date", nil}, ~U[2013-12-12 23:12:33Z]}},
        {:and, {:attr_exp, {:ew, {:attr_path, nil, "lastname", nil}, "ed"}},
         {:value_path, {:attr_path, nil, "email", nil},
          {:and, {:ew, {:attr_path, nil, "value", nil}, "@mail.tv"},
           {:eq, {:attr_path, nil, "type", nil}, "work"}}}}}}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, any()}
  def parse(filter) do
    with {:ok, filter_lexed, _} <- :filter_lexer.string(:erlang.binary_to_list(filter)),
         {:ok, parsed_result} <- :filter_parser.parse(filter_lexed) do
      {:ok, parsed_result}
    else
      {:error, {_, _, reason}, _} ->
        error_message = reason |> :filter_lexer.format_error() |> to_string()

        {:error, __MODULE__.InvalidError.exception("Lexer error: " <> error_message)}

      {:error, {_, _, reason}} ->
        {:error, __MODULE__.InvalidError.exception("Parser error: " <> to_string(reason))}
    end
  end

  @doc """
  Parses an expression and returns its AST or raises an exception

  ## Example

      iex> AttributeRepository.Search.Filter.parse!(~s|not(birthdate lt "2000-01-01T00:0:00Z" or millenial eq true)|)
      {:not,
       {:or,
        {:attr_exp, {:lt, {:attr_path, nil, "birthdate", nil}, "2000-01-01T00:0:00Z"}},
        {:attr_exp, {:eq, {:attr_path, nil, "millenial", nil}, true}}}}

      iex> AttributeRepository.Search.Filter.parse!(~s|and(birthdate lt "2000-01-01T00:0:00Z" or millenial eq true)|) 
      ** (AttributeRepository.Search.Filter.InvalidError) Parser error: syntax error before: 'and'
  """
  @spec parse!(String.t()) :: t()
  def parse!(filter) do
    case parse(filter) do
      {:ok, ast} ->
        ast

      {:error, e} ->
        raise e
    end
  end

  @doc """
  Serializes an AST to the corresponding text filter


  ## Example

      iex> AttributeRepository.Search.Filter.parse!(~S|date eq 0.0000000000000000000000000214|)
      ...> |> AttributeRepository.Search.Filter.serialize()
      "date eq 2.14e-26"

      iex> AttributeRepository.Search.Filter.parse!(~S|attr pr and attr lt 12|)
      ...> |> AttributeRepository.Search.Filter.serialize()
      "attr pr and attr lt 12"
  """
  @spec serialize(t()) :: String.t()
  def serialize({:attr_exp, attr_expr}), do: serialize(attr_expr)
  def serialize({:not, expr}), do: "not(#{serialize(expr)})"
  def serialize({:pr, attr_path}), do: "#{serialize(attr_path)} pr"
  def serialize({op, attr_path, comp_value}) when op in @operators,
    do: "#{serialize(attr_path)} #{op} #{serialize(comp_value)}"
  def serialize({:and, left, right}), do: "#{serialize(left)} and #{serialize(right)}"
  def serialize({:or, left, right}), do: "(#{serialize(left)} or #{serialize(right)})"
  def serialize({:value_path, attr_path, val_filter}),
    do: "#{serialize(attr_path)}[#{serialize(val_filter)}]"
  def serialize({:attr_path, nil, attr, nil}), do: attr
  def serialize({:attr_path, nil, attr, sub_attr}), do: attr <> "." <> sub_attr
  def serialize({:attr_path, uri, attr, nil}), do: uri <> ":" <> attr
  def serialize({:attr_path, uri, attr, sub_attr}), do: uri <> ":" <> attr <> "." <> sub_attr
  def serialize(%DateTime{} = datetime), do: ~s("#{DateTime.to_iso8601(datetime)}")
  def serialize(true), do: "true"
  def serialize(false), do: "false"
  def serialize(nil), do: "null"
  def serialize(int) when is_integer(int), do: to_string(int)
  def serialize(float) when is_float(float), do: :io_lib_format.fwrite_g(float) |> to_string()
  def serialize(<<_::binary>> = str), do: ~s("#{str}")

  defmodule InvalidError do
    @moduledoc """
    Error returned when the filter is invalid because of:
    - lexer error
    - syntax error
    - expression not allowed, such as `attr gt true`
    """

    defexception message: "Invalid filter"

    def exception(), do: %__MODULE__{}
  end
end
