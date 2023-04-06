telegraf2rrd
========

Config and an auxiliary program for the [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) (server-based agent for collecting and sending all metrics and events from databases, systems, and IoT sensors) to pass numeric data to the [RRDtool database](https://oss.oetiker.ch/rrdtool/) (data logging and graphing system for time series data).

Simply:

```text
                                   [this tool]
┌─────────────┐          ┌──────────┐      ┌───────────┐        ┌───────────┐
│ IoT data    │          │          │      │ RRDtool   │        │           │
│ system data ├─ ─ ─ ─ ─►│ telegraf ├─────►│ database  │─ ─ ─ ─►│ graphs    │
│ or other    │          │          │      │           │        │           │
└─────────────┘          └──────────┘      └───────────┘        └───────────┘
```

each data source (e.g. mqtt topic) will be stored in the separate RRDtool database. Eg: data from `/iot/home/temp` topic will go to `iot_home_temp.rrd` etc.

## How to

### 1. telegraf.conf

Add the following configuration to your `telegraf.conf`, to the section `OUTPUT PLUGINS`:

```
[[outputs.exec]]
  ## Command to ingest metrics via stdin.
  command = ["/usr/local/bin/telegraf2rrd.sh"]
  data_format = "csv"
```

### 2. The program to digest the data

Copy the `telegraf2rrd.sh` to your server, eg to `/usr/local/bin/telegraf2rrd.sh`. Remember to adjust the path in the `telegraf.conf` accordingly.

Variables to modify:
- `topics_to_search` list the topics or text strings to forward to RRD. This will be used by `grep -E` to search incoming messages from the telegraf.
- `dbDir` the directory where the rrd databases will be stored
