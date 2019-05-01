defmodule AttributeRepository.Start do
  @moduledoc """
  Callback for starting a service (without supervision)
  """

  @doc """
  Launches an attribute repository

  Returns `:ok` or an error. This callback is to be used when the attribute repository
  cannot be supervised, such as mnesia.
  """

  @callback start(AttributeRepository.init_opts()) :: :ok | {:error, any()}
end
