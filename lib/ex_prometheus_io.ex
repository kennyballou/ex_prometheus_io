defmodule ExPrometheusIo do
  use Application

  def start(_, _) do
    ExPrometheusIo.Supervisor.start_link
  end

  def query(query, _opts \\ []) do
    query_opts = [query]
    spawn_query(:fetch_query, query_opts)
  end

  def range(query, start_ts, end_ts, step, _opts \\ []) do
    query_opts = [query, start_ts, end_ts, step]
    spawn_query(:fetch_range, query_opts)
  end

  def series(matches, _opts \\ []) do
    spawn_query(:fetch_series, [matches])
  end

  defp spawn_query(fetch, query_opts, _opts \\ []) do
    query_ref = make_ref()
    query_opts = query_opts ++ [query_ref, self()]
    {:ok, pid} = Task.Supervisor.start_child(
      ExPrometheusIo.QuerySupervisor,
      ExPrometheusIo.Query,
      fetch,
      query_opts)
    {pid, query_ref}
  end

end
