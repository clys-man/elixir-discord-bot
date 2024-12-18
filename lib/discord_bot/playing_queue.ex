defmodule DiscordBot.PlayingQueue do
  use GenServer

  alias __MODULE__, as: Q

  def start_link(_opts) do
    GenServer.start_link(Q, %{}, name: Q)
  end

  def init(state) do
    {:ok, state}
  end

  def pop(guild_id, number \\ 1),
    do: GenServer.call(Q, {:pop, guild_id, number})

  def peek(guild_id, number \\ 1),
    do: GenServer.call(Q, {:peek, guild_id, number})

  def len(guild_id),
    do: GenServer.call(Q, {:len, guild_id})

  def empty?(guild_id),
    do: GenServer.call(Q, {:empty, guild_id})

  def push(guild_id, item),
    do: GenServer.cast(Q, {:push, guild_id, item})

  def push_front(guild_id, item),
    do: GenServer.cast(Q, {:push_front, guild_id, item})

  def assert(guild_id),
    do: GenServer.cast(Q, {:assert, guild_id})

  def purge(guild_id),
    do: GenServer.cast(Q, {:purge, guild_id})

  def purge_range(guild_id, range),
    do: GenServer.cast(Q, {:purge_range, guild_id, range})

  def remove(guild_id),
    do: GenServer.cast(Q, {:remove, guild_id})

  def handle_call({:pop, guild_id, number}, _from, map) do
    {front, back} = split(q(map, guild_id), number)
    {:reply, :queue.to_list(front), Map.put(map, guild_id, back)}
  end

  def handle_call({:peek, guild_id, number}, _from, map) do
    {front, _back} = split(q(map, guild_id), number)
    {:reply, :queue.to_list(front), map}
  end

  def handle_call({:len, guild_id}, _from, map) do
    {:reply, :queue.len(q(map, guild_id)), map}
  end

  def handle_call({:empty, guild_id}, _from, map) do
    {:reply, q(map, guild_id) |> :queue.is_empty(), map}
  end

  def handle_cast({:push, guild_id, item}, map) do
    {:noreply, Map.put(map, guild_id, :queue.in(item, q(map, guild_id)))}
  end

  def handle_cast({:push_front, guild_id, item}, map) do
    {:noreply, Map.put(map, guild_id, :queue.in_r(item, q(map, guild_id)))}
  end

  def handle_cast({:assert, guild_id}, map) do
    {:noreply, Map.put_new(map, guild_id, :queue.new())}
  end

  def handle_cast({:purge, guild_id}, map) do
    {:noreply, Map.put(map, guild_id, :queue.new())}
  end

  def handle_cast({:purge_range, guild_id, range}, map) do
    new_q =
      q(map, guild_id)
      |> :queue.to_list()
      |> Enum.with_index(1)
      |> Enum.filter(fn {_elem, i} -> i not in range end)
      |> Enum.map(fn {elem, _} -> elem end)
      |> :queue.from_list()

    {:noreply, Map.put(map, guild_id, new_q)}
  end

  def handle_cast({:remove, guild_id}, map) do
    {:noreply, Map.delete(map, guild_id)}
  end

  defp q(map, guild_id), do: map[guild_id] || :queue.new()

  defp split(q, num) do
    num = min(num, :queue.len(q))
    {_front, _back} = :queue.split(num, q)
  end
end
