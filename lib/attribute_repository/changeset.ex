defmodule AttributeRepository.Changeset do
  @moduledoc """
  """

  alias AttributeRepository.Schema

  defstruct [
    adapter_data: [],
    change_ops: [],
    modified?: false,
    resource: %{},
    schemas: []
  ]

  @typedoc """
  A changeset is composed of the following fields:
  - `:adapter_data`: opaque data set by the adapter when loading a resource. Must not be used
  except by it. Can be used by adapters to keep track of the original loaded object, if needed
  (for instance Riak would need it to efficietly update the object and its CRDTs).
  - `:changes`: list of changes performed on the changeset. Should not be used by libraries'
  authors
  - `:modified?`: set to `true` as soon as a change has been performed on the changeset. Can
  be used in pattern matching my libraries' authors
  - `:resource`: the resource data, with its modifications performed so far
  - `:schema`: the schema associated to the changeset, from adapters' data
  """
  @type t :: %__MODULE__{
    adapter_data: [{module(), any()}],
    change_ops: [change_op()],
    modified?: boolean(),
    resource: AttributeRepository.resource(),
    schemas: [Schema.t()]
  }

  @type change_op ::
  {
    :add,
    attribute_name :: AttributeRepository.attribute_name(),
    value :: AttributeRepository.attribute_value()
  }
  |
  {
    :add,
    attribute_name :: AttributeRepository.attribute_name(),
    subattribute_name :: AttributeRepository.attribute_name(),
    value :: AttributeRepository.simple_value()
  }

  @typedoc """
  The path for a change operation

  The examples from the specification would translate to:

  - `"members"`:
  ```
  {"members", nil, nil}
  ```
  - `"name.familyName"`:
  ```
  {"name", nil, "familyName"}
  ```
  - `"addresses[type eq \"work\"]"`:
  ```
  {"addresses", {:eq, {:attr_path, nil, "type", nil}, "work"}, nil}
  ```
  - `"members[value eq \"2819c223-7f76-453a-919d-413861904646\"]"`:
  ```
  {"members", {:eq, {:attr_path, nil, "value", nil}, "2819c223-7f76-453a-919d-413861904646"}, nil}
  ```
  - `"members[value eq \"2819c223-7f76-453a-919d-413861904646\"].displayName"`:
  ```
  {"members", {:eq, {:attr_path, nil, "value", nil}, "2819c223-7f76-453a-919d-413861904646"}, "displayName"}
  ```
  """
  @type change_op_path :: {
    attribute :: AttributeRepository.attribute_name(),
    filter :: AttributeRepository.val_filter() | nil,
    sub_attribute :: AttributeRepository.attribute_name() | nil
  }

  defmodule InvalidTypeError do
    defexception [:message]
  end

  defmodule InvalidOperationError do
    defexception [:message]
  end

  defmodule MutabilityViolationError do
    defexception [:message]
  end

  defmodule CanonicalValuesViolationError do
    defstruct [:message]
  end

  defguard is_datetime(term) when
    is_map(term) and
    :erlang.is_map_key(:__struct__, term) and
    is_atom(:erlang.map_get(:__struct__, term)) and
    is_struct(term) and
    :erlang.map_get(:__struct__, term) == DateTime

  defguardp is_simple_value(term) when
    is_binary(term) or
    is_boolean(term) or
    is_float(term) or
    is_integer(term) or
    is_datetime(term) or
    is_nil(term)

  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(opts \\ []) do
    #FIXME: verify resource attributes when creating?
    %__MODULE__{
      adapter_data: opts[:adapter_data] || [],
      resource: opts[:resource] || %{},
      schemas: opts[:schemas] || []
    }
  end

  @spec add(
    t(),
    attribute :: AttributeRepository.attribute_name() | nil,
    sub_attribute :: AttributeRepository.attribute_name() | nil,
    simple_or_complex_value :: AttributeRepository.attribute_data_type()
  ) :: {:ok, t()} | {:error, Exception.t()}
  def add(changeset, attribute \\ nil, sub_attribute \\ nil, value_or_values)

  # add(changeset, attribute_name, new_simple_or_complex_value)
  def add(%__MODULE__{} = changeset, <<_::binary>> = attr_name, nil, new_val) do
    case set_attribute_value(changeset, attr_name, new_val) do
      {:ok, ^changeset} ->
        {:ok, changeset}

      {:ok, changeset} ->
        {:ok, changeset |> register_change_op({:add, attr_name, new_val}) |> set_modified()}

      {:error, _} = error ->
        error
    end
  end

  # add(changeset, attribute_name, subattribute_name, simple_value)
  def add(
    %__MODULE__{} = changeset,
    <<_::binary>> = attr_name,
    <<_::binary>> = subattr_name,
    new_val
  ) when is_simple_value(new_val) do
    case set_attribute_value(changeset, attr_name, %{subattr_name => new_val}) do
      {:ok, ^changeset} ->
        {:ok, changeset}

      {:ok, changeset} ->
        {:ok, changeset |> register_change_op({:add, attr_name, new_val}) |> set_modified()}

      {:error, _} = error ->
        error
    end
  end

  def add(%__MODULE__{} = changeset, nil, nil, %{} = new_vals) do
    Enum.reduce_while(new_vals, changeset, fn {attr_name, attr_val}, acc ->
        case add(acc, attr_name, attr_val) do
          {:ok, changeset}    -> {:cont, changeset}
          {:error, _} = error -> {:halt, error}
        end
      end
    )
    |> case do
      %_{} = changeset ->
        {:ok, changeset}

      {:error, _} = error ->
        error
    end
  end

  defp set_attribute_value(changeset, attr_name, new_val) do
    with {:ok, attr_def} <- Schema.attribute_definition(changeset.schemas, attr_name),
         :ok <- check_type_compat(attr_name, new_val, attr_def),
         :ok <- check_mutability(changeset.resource, attr_name, attr_def),
         :ok <- check_canonical_values(attr_name, new_val, attr_def),
         false <- value_set?(changeset, attr_name, new_val, attr_def) do
      cond do
        is_simple_value(new_val) and not attr_def[:multi_valued] ->
          changeset = %__MODULE__{changeset |
            resource: Map.put(changeset.resource, attr_name, new_val)
          }

          {:ok, changeset}

        is_simple_value(new_val) and attr_def[:multi_valued] ->
          existing_vals = changeset.resource[attr_name] || []

          changeset = %__MODULE__{changeset |
            resource: Map.put(changeset.resource, attr_name, [new_val | existing_vals])
          }

          {:ok, changeset}

        match?(%{}, new_val) and not attr_def[:multi_valued] ->
          with :ok <- can_insert_complex_value(changeset, attr_name, new_val) do
            existing_val = changeset.resource[attr_name] || %{}

            #FIXME: add to list
            {:ok, put_in(changeset, [:resource, attr_name], Map.merge(existing_val, new_val))}
          end

        match?(%{}, new_val) and attr_def[:multi_valued] ->
          with :ok <- can_insert_complex_value(changeset, attr_name, new_val) do
            existing_vals = changeset.resource[attr_name] || []

            {:ok, put_in(changeset, [:resource, attr_name], [new_val | existing_vals])}
          end
      end
    else
      true ->
        {:ok, changeset}

      {:error, _} = error ->
        error
    end
  end

  defp can_insert_complex_value(_changeset, _attr_name, new_val) when new_val == %{} do
    :ok
  end

  defp can_insert_complex_value(changeset, attr_name, new_val) do
    [{subattr_name, subattr_val} | other_values] = Enum.take(new_val, 1)
    sub_vals = changeset.resource[attr_name] || %{}

    schemas = changeset.schemas

    with {:ok, subattr_def} <- Schema.attribute_definition(schemas, attr_name, subattr_name),
         :ok <- check_type_compat(subattr_name, subattr_val, subattr_def),
         :ok <- check_mutability(sub_vals, subattr_name, subattr_def),
         :ok <- check_canonical_values(subattr_name, subattr_val, subattr_def) do
      can_insert_complex_value(changeset, attr_name, Enum.into(other_values, %{}))
    end
  end

  defp check_type_compat(_, <<_::binary>>, %{type: :string}), do: :ok
  defp check_type_compat(_, true, %{type: :boolean}), do: :ok
  defp check_type_compat(_, false, %{type: :boolean}), do: :ok
  defp check_type_compat(_, term, %{type: :decimal}) when is_float(term), do: :ok
  defp check_type_compat(_, term, %{type: :integer}) when is_integer(term), do: :ok
  defp check_type_compat(_, %DateTime{}, %{type: :date_time}), do: :ok
  defp check_type_compat(_, <<_::binary>>, %{type: :binary}), do: :ok
  defp check_type_compat(_, <<_::binary>>, %{type: :reference}), do: :ok
  defp check_type_compat(_, %{}, %{type: :complex}), do: :ok
  defp check_type_compat(attr_name, new_val, %{type: type}),
    do: {:error, %InvalidTypeError{message:
      "invalid value provided for attribute #{attr_name}, expected a #{type}, " <>
      "got: #{inspect(new_val)}}"
    }}

  defp check_mutability(_resource, _attr_name, %{multi_valued: true}) do
    :ok
  end

  defp check_mutability(_resource, attr_name, %{mutability: :read_only}) do
    {:error, %MutabilityViolationError{message:
      "trying to modify a read only attribute: #{attr_name}"
    }}
  end

  defp check_mutability(_resource, _attr_name, %{mutability: :read_write}) do
    :ok
  end

  defp check_mutability(resource, attr_name, %{mutability: :immutable}) do
    case resource[attr_name] do
      nil ->
        :ok

      [] ->
        :ok

      _ ->
        {:error, %MutabilityViolationError{message:
          "trying to modify an already set immutable attribute: #{attr_name}"
        }}
    end
  end

  defp check_mutability(_resource, _attr_name, %{mutability: :write_only}) do
    :ok
  end

  defp check_canonical_values(attr_name, attr_val, %{canonical_values: canonical_values}) do
    if attr_val in canonical_values do
      :ok
    else
      {:error, %CanonicalValuesViolationError{
        message:
          "invalid value provided for attribute `#{attr_name}`, must " <>
          "be one of: #{inspect(canonical_values)}, got: #{inspect(attr_val)}"
      }}
    end
  end

  defp check_canonical_values(_, _, _) do
    :ok
  end

  defp value_set?(
    changeset, attr_name, new_val, %{multi_valued: false}
  ) when is_simple_value(new_val) do
    changeset.resource[attr_name] == new_val
  end

  defp value_set?(changeset, attr_name, %{} = new_val, %{multi_valued: false}) do
    existing_values = Map.take(changeset.resource[attr_name] || %{}, Map.keys(new_val))

    new_val == existing_values
  end

  defp value_set?(changeset, attr_name, new_val, %{multi_valued: true}) do
    new_val in (changeset.resource[attr_name] || [])
  end

  defp register_change_op(changeset, change_op) do
    %__MODULE__{changeset | change_ops: changeset.change_ops ++ [change_op]}
  end

  defp set_modified(changeset) do
    %__MODULE__{changeset | modified?: true}
  end

  @spec serialize_change_op_path(change_op_path()) :: String.t()
  def serialize_change_op_path(_) do
    #FIXME
  end
end
