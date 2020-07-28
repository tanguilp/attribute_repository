defmodule AttributeRepository.Schema.AttributeDefinition do
  @moduledoc """
  """

  @enforce_keys [:name, :multi_valued]

  defstruct [
    :name,
    :sub_attributes,
    :multi_valued,
    :description,
    :canonical_values,
    :reference_types,
    case_exact: false,
    mutability: :read_write,
    required: false,
    returned: :default,
    type: :string,
    uniqueness: :none
  ]

  @type t :: %__MODULE__{
    name: String.t(),
    type: type(),
    sub_attributes: [__MODULE__.t()] | nil,
    multi_valued: boolean(),
    description: String.t() | nil,
    required: boolean(),
    canonical_values: [AttributeRepository.simple_value()] | nil,
    case_exact: boolean(),
    mutability: mutability(),
    returned: returned(),
    uniqueness: uniqueness(),
    reference_types: [String.t()] | nil
  }

  @type mutability :: :read_only | :read_write | :immutable | :write_only
  @type returned :: :always | :never | :default | :request
  @type type :: :string | :boolean | :decimal | :integer | :date_time | :reference | :complex
  @type uniqueness :: :none | :server | :global
end
