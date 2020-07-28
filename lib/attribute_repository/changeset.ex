defmodule AttributeRepository.Changeset do
  @moduledoc """
  """

  alias AttributeRepository.Schema

  @enforce_keys [:adapter_data, :changes, :resource]

  defstruct [:adapter_data, :changes, :resource, modified?: false, schemas: []]

  @type change :: any() #TODO

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
    adapter_data: any(),
    changes: [change()],
    modified?: boolean(),
    resource: AttributeRepository.resource(),
    schemas: [Schema.t()]
  }
end
