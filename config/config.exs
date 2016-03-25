use Mix.Config

config :ex_prometheus_io, hostname: "prometheus:9090"

import_config "#{Mix.env}.exs"
