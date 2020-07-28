defmodule AttributeRepository.Schema do
  @moduledoc """
  """

  @enforce_keys [:id, :attributes]

  defstruct [:id, :name, :description, :attributes]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t() | nil,
    description: String.t() | nil,
    attributes: %{optional(AttributeRepository.attribute_name()) => AttributeDefinition.t()}
  }
end
