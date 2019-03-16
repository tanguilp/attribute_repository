defmodule AttributeRepository.Install do
  @moduledoc """
  Callback for installing an attribute repository
  """

  @callback install(AttributeRepository.run_opts(), AttributeRepository.init_opts())
  :: :ok | {:error, any()}
end
