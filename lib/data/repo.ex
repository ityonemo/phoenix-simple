defmodule Data.Repo do
  @adapter Application.compile_env(:my_app, :database_adapter)

  use Ecto.Repo,
    otp_app: :my_app,
    adapter: @adapter
end
