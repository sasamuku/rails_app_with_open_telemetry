# README

https://signoz.io/blog/opentelemetry-ruby/

set below in your `.envrc`

```
export OTEL_EXPORTER=otlp
export OTEL_SERVICE_NAME=RailsApp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_RESOURCE_ATTRIBUTES=application=sparkapp
```
