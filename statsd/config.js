{
  port: 8125,
  mgmt_port: 8126,

  percentThreshold: [99],

  graphitePort: 2003,
  graphiteHost: "127.0.0.1",
  flushInterval: 10000,
  
  deleteIdleStats: true,

  backends: ['./backends/graphite'],
  graphite: {
    legacyNamespace: false
  }
}
// https://github.com/etsy/statsd/blob/master/exampleConfig.js
// https://grafana.com/blog/2016/03/03/25-graphite-grafana-and-statsd-gotchas/#graphite.quantization