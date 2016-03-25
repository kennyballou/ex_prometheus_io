defmodule ExPrometheusIo.Test.HTTPClient do

  @query_fixture File.read!("test/fixtures/prometheus_query.json")
  @range_fixture File.read!("test/fixtures/prometheus_range.json")
  @series_fixture File.read!("test/fixtures/prometheus_series.json")
  @empty_response """
  {"status": "error", "errorType": "bad_data", "error": "Nope"}
  """

  def request(url) do
    url = to_string(url)
    cond do
      String.contains?(url, "/api/v1/query?query=up") ->
        {:ok, {[], [], @query_fixture}}
      String.contains?(url, "/api/v1/query_range?query=up") ->
        {:ok, {[], [], @range_fixture}}
      String.contains?(url, "/api/v1/series?match[]=up") ->
        {:ok, {[], [], @series_fixture}}
      String.contains?(url, "query=timeout") or
      String.contains?(url, "match[]=timeout") ->
        :timer.sleep(20)
        {:ok, {[], [], @empty_response}}
      String.contains?(url, "query=kill") or
      String.contains?(url, "match[]=kill") ->
        Process.exit(self, :kill)
      true -> {:ok, {[], [], @empty_response}}
    end
  end

end
