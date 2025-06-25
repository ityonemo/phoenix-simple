defmodule OAuth.Test do
  defstruct []

  def init, do: %__MODULE__{}
end

Mox.defmock(OAuth.Mock, for: OAuth)

defimpl OAuth, for: OAuth.Test do
  defdelegate logout_url(mock), to: OAuth.Mock

  defdelegate authorize_url(mock), to: OAuth.Mock

  defdelegate fetch_token(mock, bearer_token), to: OAuth.Mock

  defdelegate fetch_user_info(mock, access_token), to: OAuth.Mock

  defdelegate init(), to: OAuth.Test
end
