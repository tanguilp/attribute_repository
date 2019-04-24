defmodule AttributeRepository.Install do
  @moduledoc """
  Callback for installing an attribute repository
  """

  @doc """
  Configures or installs the attribute repository

  The callback shall return `:ok` when the repository is already installed.
  """

  @callback install(AttributeRepository.run_opts(), AttributeRepository.init_opts()) ::
              :ok | {:error, any()}
end
