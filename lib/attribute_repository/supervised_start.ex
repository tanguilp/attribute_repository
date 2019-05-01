defmodule AttributeRepository.SupervisedStart do
  @moduledoc """
  Callback for supervised start
  """

  @doc """
  Launches a supervised attribute repository

  Returns `{:ok, pid}` or an error like the `Supervisor.start_link/2` function. This
  callback is to be used when the process can be supervised.
  """

  @callback start_link(AttributeRepository.init_opts()) :: Supervisor.on_start()
end
