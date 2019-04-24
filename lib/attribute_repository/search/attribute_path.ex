defmodule AttributeRepository.Search.AttributePath do
  @enforce_keys [:attribute]

  defstruct [
    :attribute,
    :uri,
    :sub_attribute
  ]

  @type t :: %__MODULE__{
          attribute: String.t(),
          uri: String.t(),
          sub_attribute: String.t()
        }

  def new(m) do
    %__MODULE__{
      attribute: string(m[:attribute]),
      uri: string(m[:uri]),
      sub_attribute: string(m[:sub_attribute])
    }
  end

  defp string(nil), do: nil
  defp string([_ | _] = charlist), do: List.to_string(charlist)
end
