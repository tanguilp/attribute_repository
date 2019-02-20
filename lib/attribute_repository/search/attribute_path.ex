defmodule AttributeRepository.Search.AttributePath do
  @enforce_keys [:attribute]

  defstruct [
    :attribute,
    :uri,
    :sub_attribute
  ]

  def new(m) do
    %__MODULE__{
      attribute: m[:attribute],
      uri: m[:uri],
      sub_attribute: m[:sub_attribute]
    }
  end
end
