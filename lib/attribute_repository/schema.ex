defmodule AttributeRepository.Schema do
  @moduledoc """
  """

  @type_values [:string, :boolean, :decimal, :integer, :date_time, :reference, :complex]
  @mutability_values [:read_only, :read_write, :immutable, :write_only]
  @returned_values [:always, :never, :default, :request]
  @uniqueness_values [:none, :server, :global]

  @enforce_keys [:id, :name, :attributes, :defined_in]

  defstruct [:id, :name, :description, :attributes, :defined_in]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    description: String.t() | nil,
    attributes: %{optional(AttributeRepository.attribute_name()) => attribute_definition()},
    defined_in: module()
  }
  @type attribute_definition :: %{
    required(:case_exact) => boolean(),
    required(:multi_valued) => boolean(),
    required(:mutability) => attribute_mutability(),
    required(:required) => boolean(),
    required(:returned) => attribute_returned(),
    required(:type) => attribute_type(),
    required(:uniqueness) => attribute_uniqueness(),
    optional(:canonical_values) => [AttributeRepository.simple_value()],
    optional(:description) => String.t(),
    optional(:reference_types) => [String.t()],
    optional(:sub_attributes) => attribute_definition(),
    optional(atom()) => any()
  }
  @type attribute_type ::
  :string
  | :boolean
  | :decimal
  | :integer
  | :date_time
  | :reference
  | :complex

  @type attribute_mutability :: :read_only | :read_write | :immutable | :write_only

  @type attribute_returned :: :always | :never | :default | :request

  @type attribute_uniqueness :: :none | :server | :global

  defmodule MissingAttributeDefinitionError do
    @enforce_keys [:attribute_name]

    defexception [:attribute_name, :sub_attribute_name]

    @type t :: %__MODULE__{
      attribute_name: String.t(),
      sub_attribute_name: String.t() | nil
    }

    @impl true
    def message(%{attribute_name: attr_name, sub_attribute_name: sub_attr_name})
    when not is_nil(sub_attr_name)
    do
      "missing attribute definition for subattribute: " <> attr_name <> "." <> sub_attr_name
    end

    def message(%{attribute_name: attr_name}) do
      "missing attribute definition for attribute: " <> attr_name
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile AttributeRepository.Schema

      import AttributeRepository.Schema, only: [schema: 2, schema: 3]

      Module.register_attribute(__MODULE__, :attribute_repository_schemas, accumulate: true)
    end
  end

  defmacro schema(name, opts \\ [], [do: block]) do
    prelude =
      quote do
        Module.delete_attribute(__MODULE__, :attribute_repository_attributes)
        Module.register_attribute(__MODULE__, :attribute_repository_attributes, accumulate: true)

        name = unquote(name)
        id = unquote(opts[:id]) || name
        doc =
          case Module.get_attribute(__MODULE__, :doc) do
            {_line, doc} ->
              String.trim(doc)

            _ ->
              nil
          end

        schemas = Module.get_attribute(__MODULE__, :attribute_repository_schemas)

        if schemas != nil and id in schemas do
          raise "A schema with the name #{name} is already defined in this module"
        end

        unless is_binary(name) do
          raise "Schema name must be a string, got: #{inspect(name)}"
        end

        try do
          import AttributeRepository.Schema
          unquote(block)
        after
          :ok
        end
      end

    postlude =
      quote unquote: false do
        Module.put_attribute(__MODULE__, :attribute_repository_schemas, id)

        attributes = @attribute_repository_attributes |> Enum.reverse()

        attributes_processed = AttributeRepository.Schema.process_attributes(attributes)

        def __schema__(unquote(id)) do
          %AttributeRepository.Schema{
            id: unquote(id),
            name: unquote(name),
            description: unquote(doc),
            attributes: unquote(Macro.escape(attributes_processed)),
            defined_in: __MODULE__
          }
        end
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  defmacro attribute(name, definition \\ []) do
    quote do
      AttributeRepository.Schema.__attribute__(__MODULE__, unquote(name), unquote(definition))
    end
  end

  @doc false
  def __attribute__(module, name, definition) do
    Module.put_attribute(module, :attribute_repository_attributes, {name, definition})
  end

  defmacro __before_compile__(_env) do
    quote do
      def __schemas__() do
        for schema <- Enum.reverse(@attribute_repository_schemas), do: __schema__(schema)
      end
    end
  end

  @doc false
  def process_attributes(attribute_list) do
    for {name, definition} <- attribute_list, into: %{} do
      {to_string(name), process_attribute(to_string(name), definition)}
    end
  end

  defp process_attribute(name, definition) do
    definition = definition |> Enum.into(%{}) |> set_defaults()

    check_type!(name, definition)
    check_multi_valued!(name, definition)
    check_required!(name, definition)
    check_case_exact!(name, definition)
    check_mutability!(name, definition)
    check_returned!(name, definition)
    check_mutability!(name, definition)
    check_uniqueness!(name, definition)
    check_reference_types!(name, definition)
    check_canonical_values!(name, definition)

    case definition do
      %{sub_attributes: sub_attributes} ->
        %{definition | sub_attributes: process_attributes(sub_attributes)}

      _ ->
        definition
    end
  end

  defp set_defaults(attribute_definition) do
    attribute_definition
    |> Map.put_new(:required, false)
    |> Map.put_new(:case_exact, false)
    |> Map.put_new(:mutability, :read_write)
    |> Map.put_new(:returned, :default)
    |> Map.put_new(:uniqueness, :none)
    |> Map.put_new(:type, :string)
    |> Map.put_new(:multi_valued, false)
  end

  defp check_type!(name, %{type: type}) when type not in @type_values,
    do: raise "Attribute #{name} has incorrect type definition, must be one of: #{inspect(@type_values)}"
  defp check_type!(_, _), do: :ok

  defp check_multi_valued!(name, %{multi_valued: mv}) when not is_boolean(mv),
    do: raise "Attribute #{name} has incorrect multi valued definition, must be a boolean"
  defp check_multi_valued!(_, _), do: :ok

  defp check_required!(name, %{required: required}) when not is_boolean(required),
    do: raise "Attribute #{name} has incorrect required definition, must be a boolean"
  defp check_required!(_, _), do: :ok

  defp check_case_exact!(name, %{case_exact: case_exact}) when not is_boolean(case_exact),
    do: raise "Attribute #{name} has incorrect case exact definition, must be a boolean"
  defp check_case_exact!(_, _), do: :ok

  defp check_mutability!(name, %{mutability: mutability}) when mutability not in @mutability_values,
    do: raise "Attribute #{name} has incorrect mutability definition, must be one of: #{inspect(@mutability_values)}"
  defp check_mutability!(_, _), do: :ok

  defp check_uniqueness!(name, %{uniqueness: uniqueness}) when uniqueness not in @uniqueness_values,
    do: raise "Attribute #{name} has incorrect mutability definition, must be one of: #{inspect(@uniqueness_values)}"
  defp check_uniqueness!(_, _), do: :ok

  defp check_returned!(name, %{returned: returned}) when returned not in @returned_values,
    do: raise "Attribute #{name} has incorrect returned definition, must be one of: #{inspect(@returned_values)}"
  defp check_returned!(_, _), do: :ok

  defp check_reference_types!(name, definition) do
    case definition[:reference_types] do
      nil ->
        :ok

      reference_types when is_list(reference_types) ->
        for ref_type <- reference_types do
          unless is_binary(ref_type) do
            raise "Attribute #{name} has incorrect reference types definition, must be a list of strings"
          end
        end

      _ ->
        raise "Attribute #{name} has incorrect reference types definition, must be a list of strings"
    end
  end

  defp check_canonical_values!(name, definition) do
    case definition[:canonical_values] do
      nil ->
        :ok

      canonical_values when is_list(canonical_values) ->
        :ok

      _ ->
        raise "Attribute #{name} has incorrect canonical values definition, must be a list"
    end
  end

  @doc """
  Returns the attribute or subattribute definition from a schema or a list of schemas
  """
  @spec attribute_definition(
    t() | [t()],
    AttributeRepository.attribute_name(),
    AttributeRepository.attribute_name() | nil
  ) :: {:ok, attribute_definition()} | {:error, Exception.t()}
  def attribute_definition(schema_or_schemas, attribute_name, sub_attribute_name \\ nil)

  def attribute_definition(%__MODULE__{} = schema, <<_::binary>> = attr_name, nil) do
    case schema.attributes[attr_name] do
      %{} = attr_def ->
        {:ok, attr_def}

      nil ->
        {:error, %MissingAttributeDefinitionError{attribute_name: attr_name}}
    end
  end

  def attribute_definition([], <<_::binary>> = attr_name, nil) do
    {:error, %MissingAttributeDefinitionError{attribute_name: attr_name}}
  end

  def attribute_definition(
    [%__MODULE__{} = schema | other_schemas], <<_::binary>> = attr_name, nil
  ) do
    case attribute_definition(schema, attr_name) do
      {:ok, _} = result ->
        result

      {:error, _} ->
        attribute_definition(other_schemas, attr_name)
    end
  end

  def attribute_definition(
    %__MODULE__{} = schema, <<_::binary>> = attr_name, <<_::binary>> = sub_attr_name
  ) do
    case get_in(schema.attributes, [attr_name, :sub_attributes, sub_attr_name]) do
      %{} = sub_attr_def ->
        {:ok, sub_attr_def}

      _ ->
        {:error, %MissingAttributeDefinitionError{
          attribute_name: attr_name, sub_attribute_name: sub_attr_name}
        }
    end
  end

  def attribute_definition([], <<_::binary>> = attr_name, <<_::binary>> = sub_attr_name) do
    {:error, %MissingAttributeDefinitionError{
      attribute_name: attr_name, sub_attribute_name: sub_attr_name}
    }
  end

  def attribute_definition(
    [%__MODULE__{} = schema | other_schemas],
    <<_::binary>> = attr_name,
    <<_::binary>> = sub_attr_name)
  do
    case attribute_definition(schema, attr_name, sub_attr_name) do
      {:ok, _} = result ->
        result

      {:error, _} ->
        attribute_definition(other_schemas, attr_name, sub_attr_name)
    end
  end

  @doc """
  Converts an `t:AttributeRepository.Schema.t/0` into a plain map compatible with SCIM schemas.
  """
  @spec to_scim_map(__MODULE__.t()) :: map()
  def to_scim_map(%__MODULE__{} = schema) do
    %{
      "id" => schema.id,
      "name" => schema.name,
    }
    |> maybe_put_description_to_scim_map(schema)
    |> Map.put("attributes", attributes_to_json_map(schema.attributes))
  end

  defp maybe_put_description_to_scim_map(res, %__MODULE__{description: description}),
    do: Map.put(res, "description", description)
  defp maybe_put_description_to_scim_map(res, _), do: res

  defp attributes_to_json_map(attr_defs) do
    for {attr_name, attr_def} <- attr_defs, into: %{} do
      attr_def =
        for {def_elt, def_val} <- attr_def, into: %{} do
          case def_elt do
            :sub_attributes ->
              {camelize(def_elt), attributes_to_json_map(def_val)}

            _ ->
              {camelize(def_elt), camelize(def_val)}
          end
        end

      {attr_name, attr_def}
    end
  end

  defp camelize(atom) do
    [first | others] = atom |> to_string() |> String.split("_")

    [first | Enum.map(others, &String.capitalize/1)]
    |> Enum.join()
  end
end
