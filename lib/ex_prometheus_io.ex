defmodule ExPrometheusIo do
  use Application

  def start(_, _) do
    ExPrometheusIo.Supervisor.start_link
  end

  def query(query, _opts \\ []) do
    query_opts = [query]
    spawn_query(:query, query_opts)
  end

  def range(query, start_ts, end_ts, step, _opts \\ []) do
    query_opts = [query, start_ts, end_ts, step]
    spawn_query(:range, query_opts)
  end

  def series(matches, _opts \\ []) do
    spawn_query(:series, [matches])
  end

  defp spawn_query(query, query_opts, _opts \\ []) do
    query_ref = make_ref()
    query_opts = [query | query_opts] ++ [query_ref, self()]
    {:ok, pid} = Task.Supervisor.start_child(
      ExPrometheusIo.QuerySupervisor,
      ExPrometheusIo.Query,
      :process,
      query_opts)
    {pid, query_ref}
  end

end
