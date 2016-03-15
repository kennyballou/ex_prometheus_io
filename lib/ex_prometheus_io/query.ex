defmodule ExPrometheusIo.Query do

  def fetch_query(query_str, query_ref, owner) do
    "query=#{query_str}" <> "&time=#{:os.system_time(:seconds)}"
    |> fetch_json("query")
    |> Poison.decode
    |> send_results(query_ref, owner)
  end

  def fetch_range(query_str, start_ts, end_ts, step, query_ref, owner) do
    "query=#{query_str}"
    <> "&start=#{start_ts}"
    <> "&end=#{end_ts}"
    <> "&step=#{step}"
    |> fetch_json("query_range")
    |> Poison.decode
    |> send_results(query_ref, owner)
  end

  def fetch_series(matches, query_ref, owner) do
    matches
    |> Enum.map(fn(match) -> "match[]=#{match}" end)
    |> Enum.join("&")
    |> fetch_json("series")
    |> Poison.decode
    |> send_results(query_ref, owner)
  end

  defp fetch_json(query_str, query_type) do
    {:ok, {_, _, body}} = :httpc.request(
      "http://"
      <> prometheus_host
      <> "/api/v1/#{query_type}?"
      <> query_str
      |> String.to_char_list())
    body
  end

  defp send_results({:error, :invalid} = results, query_ref, owner) do
    send(owner, {:prometheus_results, query_ref, results})
  end

  defp send_results(
      {:ok, %{"status" => "success", "data" => results}}, query_ref, owner) do
    send(owner, {:prometheus_results, query_ref, results})
  end

  defp send_results({:ok, %{"error" => message}}, query_ref, owner) do
    send(owner, {:prometheus_results, query_ref, {:error, message}})
  end

  defp prometheus_host do
    Application.fetch_env!(:ex_prometheus_io, :hostname)
  end

end
