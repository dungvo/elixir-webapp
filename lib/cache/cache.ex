defmodule PhoenixCache.Cache do
  use GenServer
  alias :ets, as: Ets

  # Time to live - 10 minutes
  @expired_after 3 * 60

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    Ets.new(:simple_cache, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, state}
  end

  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  def handle_cast({:set, key, val}, state) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(@expired_after, :second)

    Ets.insert(:simple_cache, {key, val, expired_at})
    {:noreply, state}
  end

  def get(key) do
    rs = Ets.lookup(:simple_cache, key) |> List.first()
    if rs == nil do
      {:error, :not_found}
    else
      expired_at = elem(rs, 2)
      diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), expired_at)
      IO.inspect("diff #{diff}")
      cond do
        diff > 0 -> {:error, :expired}
        true     -> {:ok, elem(rs, 1)}
      end
    end
  end
end
