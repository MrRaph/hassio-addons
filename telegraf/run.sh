#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

agent_hostname=$(jq --raw-output ".agent.hostname" $CONFIG_PATH)
agent_interval=$(jq --raw-output ".agent.interval" $CONFIG_PATH)
agent_round_interval=$(jq --raw-output ".agent.round_interval" $CONFIG_PATH)
agent_metric_buffer_limit=$(jq --raw-output ".agent.metric_buffer_limit" $CONFIG_PATH)
agent_flush_buffer_when_full=$(jq --raw-output ".agent.flush_buffer_when_full" $CONFIG_PATH)
agent_collection_jitter=$(jq --raw-output ".agent.collection_jitter" $CONFIG_PATH)
agent_flush_interval=$(jq --raw-output ".agent.flush_interval" $CONFIG_PATH)
agent_flush_jitter=$(jq --raw-output ".agent.flush_jitter" $CONFIG_PATH)
agent_debug=$(jq --raw-output ".agent.debug" $CONFIG_PATH)
agent_quiet=$(jq --raw-output ".agent.quiet" $CONFIG_PATH)

outputs_influxdb_database=$(jq --raw-output ".outputs.influxdb_database" $CONFIG_PATH)
outputs_influxdb_precision=$(jq --raw-output ".outputs.influxdb_precision" $CONFIG_PATH)
outputs_influxdb_timeout=$(jq --raw-output ".outputs.influxdb_timeout" $CONFIG_PATH)
outputs_influxdb_urls=$(jq --raw-output ".outputs.influxdb_urls | length" $CONFIG_PATH)
if [ "$outputs_influxdb_urls" -gt "0" ]
then
    outputs_influxdb_url="["
    for (( i=0; i < "$outputs_influxdb_urls"; i++ )); do
        if [ "$i" -ne 0 ]
        then
           outputs_influxdb_url="$outputs_influxdb_url,"
        fi
        temp_url=$(jq --raw-output ".outputs.influxdb_urls[$i]" $CONFIG_PATH)
        outputs_influxdb_url="$outputs_influxdb_url\"$temp_url\""
    done
    outputs_influxdb_url="$outputs_influxdb_url]"
fi

inputs_ping_urls=$(jq --raw-output ".inputs.ping_urls | length" $CONFIG_PATH)
if [ "$inputs_ping_urls" -gt "0" ]
then
    inputs_ping_url="["
    for (( i=0; i < "$inputs_ping_urls"; i++ )); do
        if [ "$i" -ne 0 ]
        then
           inputs_ping_url="$inputs_ping_url,"
        fi
        temp_url=$(jq --raw-output ".inputs.ping_urls[$i]" $CONFIG_PATH)
        inputs_ping_url="$inputs_ping_url\"$temp_url\""
    done
    inputs_ping_url="$inputs_ping_url]"
fi

configuration="
[global_tags]

# Configuration for telegraf agent
[agent]
  interval = \"$agent_interval\"
  round_interval = $agent_round_interval
  metric_buffer_limit = $agent_metric_buffer_limit
  flush_buffer_when_full = $agent_flush_buffer_when_full
  collection_jitter = \"$agent_collection_jitter\"
  flush_interval = \"$agent_flush_interval\"
  flush_jitter = \"$agent_flush_jitter\"
  debug = $agent_debug
  quiet = $agent_quiet
  logfile = \"/var/log/telegraf/telegraf.log\"
  hostname = \"$agent_hostname\"


###############################################################################
#                                  OUTPUTS                                    #
###############################################################################

# Configuration for influxdb server to send metrics to
[[outputs.influxdb]]
  urls = $outputs_influxdb_url # required
  database = \"$outputs_influxdb_database\" # required
  precision = \"$outputs_influxdb_precision\"
  timeout = \"$outputs_influxdb_timeout\"


###############################################################################
#                                  INPUTS                                     #
###############################################################################

# Read metrics about cpu usage
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  fielddrop = [\"time_*\"]
  collect_cpu_time = true
  report_active = true

# Read metrics about disk usage by mount point
[[inputs.disk]]
  ignore_fs = [\"tmpfs\", \"devtmpfs\"]

# Read metrics about disk IO by device
[[inputs.diskio]]

# Read metrics about memory usage
[[inputs.mem]]

# Read metrics about swap memory usage
[[inputs.swap]]

# Read metrics about system load & uptime
[[inputs.system]]

[[inputs.ping]]
  ## List of urls to ping
  urls = $inputs_ping_url # required
  count = 1
  ping_interval = 1.0

# Get the number of processes and group them by status
[[inputs.processes]]

# Get kernel statistics from /proc/stat
[[inputs.kernel]]

# Get kernel statistics from linux_sysctl_fs
[[inputs.linux_sysctl_fs]]

# Collect statistics about itself
[[inputs.internal]]
  collect_memstats = true

[[inputs.net]]

[[inputs.netstat]]

[[inputs.nstat]]

[[inputs.influxdb_listener]]
  ## Address and port to host HTTP listener on
  service_address = \":9092\"

  ## maximum duration before timing out read of the request
  read_timeout = \"10s\"
  ## maximum duration before timing out write of the response
  write_timeout = \"10s\"

  ## Maximum allowed http request body size in bytes.
  ## 0 means to use the default of 536,870,912 bytes (500 mebibytes)
  max_body_size = 0

  ## Maximum line size allowed to be sent in bytes.
  ## 0 means to use the default of 65536 bytes (64 kibibytes)
  max_line_size = 0

  ## Set one or more allowed client CA certificate file names to
  ## enable mutually authenticated TLS connections
  # tls_allowed_cacerts = [\"/etc/telegraf/clientca.pem\"]

  ## Add service certificate and key
  # tls_cert = \"/etc/telegraf/cert.pem\"
  # tls_key = \"/etc/telegraf/key.pem\"

  ## Optional username and password to accept for HTTP basic authentication.
  ## You probably want to make sure you have TLS configured above for this.
  # basic_username = \"homeassistant\"
  # basic_password = \"homeassistant\"
"

echo "$configuration" > /etc/telegraf/telegraf.conf

# start server
exec telegraf