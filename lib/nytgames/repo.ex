defmodule Nytgames.Repo do
  use Ecto.Repo,
    otp_app: :nytgames,
    adapter: Ecto.Adapters.Postgres
end
