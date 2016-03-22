defmodule ExPrometheusIo.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_prometheus_io,
     description: description,
     package: package,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :inets],
     mod: {ExPrometheusIo, []}]
  end

  defp deps do
    [{:poison, "~> 1.5"}]
  end

  defp description do
    "Prometheus.io Elixir client API library"
  end

  defp package do
    [maintainers: ["Kenny Ballou"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/kennyballou/ex_prometheus_io",
              "Prometheus Project" => "http://prometheus.io"},
     files: ~w(mix.exs README.md LICENSE lib)]
  end
end
