defmodule ExPrometheusIo.Query do

  def process(query, query_opts, query_ref, owner) do
     build_url(query, query_opts)
     |> fetch_json()
     |> Poison.decode
     |> send_results(query_ref, owner)
  end

  defp fetch_json(uri) do
    {:ok, {_, _, body}} = :httpc.request(uri |> String.to_char_list())
    body
  end

  def endpoint(:query), do: build_endpoint("query")
  def endpoint(:range), do: build_endpoint("query_range")
  def endpoint(:series), do: build_endpoint("series")
  defp build_endpoint(endpoint) do
    "http://" <> prometheus_host <> "/api/v1/#{endpoint}"
  end
  def build_url(query, opts) when query in [:query, :range, :series] do
    endpoint(query) <> "?" <> query_params(query, opts)
  end

  def query_params(:query, query_parameter) do
    query_time = :os.system_time(:seconds)
    "query=#{query_parameter}&time=#{query_time}"
  end

  def query_params(:range, {topic, start_ts, end_ts, step}) do
    "query=#{topic}"
    <> "&start=#{start_ts}"
    <> "&end=#{end_ts}"
    <> "&step=#{step}"
  end

  def query_params(:series, {matches}) when is_list(matches) do
    matches
    |> Enum.map(fn(match) -> "match[]=#{match}" end)
    |> Enum.join("&")
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
