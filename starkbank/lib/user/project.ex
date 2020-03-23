defmodule StarkBank.User.Project do
  @moduledoc false
  defstruct [:environment, :access_id, :private_key, :name, :allowed_ips]
end
