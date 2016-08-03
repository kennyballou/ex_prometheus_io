defmodule ExPrometheusIoTest do
  use ExUnit.Case, async: true
  doctest ExPrometheusIo

  test "can query for up data" do
    {pid, ref} = ExPrometheusIo.query("up")
    assert_receive {:prometheus_results, ^ref, results}
    assert results["results"] != []
    assert results["resultType"] == "vector"
    refute Process.alive?(pid)
  end

  test "can query range for up data" do
    {pid, ref} = ExPrometheusIo.range("up", 1458855801, 1458855810, 1)
    assert_receive {:prometheus_results, ^ref, results}
    assert results["results"] != []
    assert results["resultType"] == "matrix"
    refute Process.alive?(pid)
  end

  test "can query up series data" do
    {pid, ref} = ExPrometheusIo.series(["up"])
    assert_receive {:prometheus_results, ^ref, results}
    assert is_list(results)
    refute Process.alive?(pid)
  end

  test "http query failure doesn't break the world" do
    {pid, ref} = ExPrometheusIo.query("kill")
    refute_receive {:prometheus_results, ^ref, _}
    refute Process.alive?(pid)
  end

  test "http range failure doesn't break the wolrd" do
    {pid, ref} = ExPrometheusIo.range("kill", 0, 1, 0.5)
    refute_receive {:prometheus_results, ^ref, _}
    refute Process.alive?(pid)
  end

  test "http series failure doesn't break the world" do
    {pid, ref} = ExPrometheusIo.series(["kill"])
    refute_receive {:prometheus_results, ^ref, _}
    refute Process.alive?(pid)
  end

  test "http query timeout doesn't stop the world" do
    {_, ref} = ExPrometheusIo.query("timeout")
    refute_receive {:prometheus_results, ^ref, _}, 10
  end

  test "http range timeout doesn't stop the world" do
    {_, ref} = ExPrometheusIo.range("timeout", 0, 1, 0.5)
    refute_receive {:prometheus_results, ^ref, _}, 10
  end

  test "http series timeout doesn't stop the world" do
    {_, ref} = ExPrometheusIo.series(["timeout"])
    refute_receive {:prometheus_results, ^ref, _}, 10
  end

end
