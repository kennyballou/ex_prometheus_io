defmodule ExPrometheusIo.QueryTest do
  use ExUnit.Case

  import ExPrometheusIo.Query, only: [query_params: 2,
                                      endpoint: 1,
                                      build_url: 2]

  test "query_params builds proper query string" do
    curr_time = :os.system_time(:seconds)
    assert "query=up&time=#{curr_time}" == query_params(:query, "up")
  end

  test "query_params builds correct range query" do
    curr_time = :os.system_time(:seconds)
    assert "query=up&start=#{curr_time-5}&end=#{curr_time}&step=1" ==
           query_params(:range, {"up", curr_time - 5, curr_time, 1})
  end

  test "query_params builds correct series query" do
    assert "match[]=up" == query_params(:series, {["up"]})
  end

  test "query endpoint" do
    assert "http://#{prom_host}/api/v1/query" == endpoint(:query)
  end

  test "range endpoint" do
    assert "http://#{prom_host}/api/v1/query_range" == endpoint(:range)
  end

  test "series endpoint" do
    assert "http://#{prom_host}/api/v1/series" == endpoint(:series)
  end

  test "build url" do
    base_url = "http://#{prom_host}/api/v1/"
    cur_time = :os.system_time(:seconds)
    assert base_url <> "query?query=up&time=#{cur_time}"
        == build_url(:query, "up")
    assert base_url <> "query_range?query=up"
                    <> "&start=#{cur_time-5}"
                    <> "&end=#{cur_time}"
                    <> "&step=1"
        == build_url(:range, {"up", cur_time - 5, cur_time, 1})
    assert base_url <> "series?match[]=up" == build_url(:series, {["up"]})
  end

  defp prom_host, do: Application.fetch_env!(:ex_prometheus_io, :hostname)

end
