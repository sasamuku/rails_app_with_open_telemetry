# README

## Pattern1: Use SigNoz

><img src="https://signoz.io/img/architecture-signoz-clickhouse.svg">
>ref: https://signoz.io/img/architecture-signoz-clickhouse.svg

### 1. Setup SigNoz

Git clone:

```
git clone -b main https://github.com/SigNoz/signoz.git && cd signoz/deploy/
```

Run docker compose:

```
docker compose -f docker/clickhouse-setup/docker-compose.yaml up -d
```

see: https://signoz.io/docs/install/docker/#install-signoz-using-docker-compose

### 2. Initialize the OpenTelemetry SDK

Install gem:

```
gem 'opentelemetry-sdk'
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'
```

```
bundle install
```

Migrate Database:

```
rails db:migrate
```

Add configuration `config/environment.rb`:

```ruby
require 'opentelemetry/sdk'
require_relative 'application'

OpenTelemetry::SDK.configure do |c|
  c.use_all
end

Rails.application.initialize!
```

### 3. Add Env

Set below in `.envrc`:

```
export OTEL_EXPORTER=otlp
export OTEL_SERVICE_NAME=RailsApp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
export OTEL_RESOURCE_ATTRIBUTES=application=sparkapp
```

<details>

<summary>Tips: Use SigNoz Cloud</summary>

```
OTEL_EXPORTER=otlp \
OTEL_SERVICE_NAME=<service_name> \
OTEL_EXPORTER_OTLP_ENDPOINT=https://ingest.{region}.signoz.cloud:443 \
OTEL_EXPORTER_OTLP_HEADERS=signoz-access-token=SIGNOZ_INGESTION_KEY \
```

see: https://signoz.io/docs/instrumentation/ruby-on-rails/

</details>

see: https://signoz.io/blog/opentelemetry-ruby/

## Pattern2: Use Datadog

><img src="https://datadog-docs.imgix.net/images/metrics/otel/datadog_exporter.1fb18ef75a1925c9593e1c10b288fb4e.png?auto=format">
>ref: https://datadog-docs.imgix.net/images/metrics/otel/datadog_exporter.1fb18ef75a1925c9593e1c10b288fb4e.png?auto=format

### 1. Pull Docker image

```
docker pull otel/opentelemetry-collector-contrib:0.90.1
```

### 2. Configure the Datadog Exporter and Connector

Add config file `otel-collector-config.yaml`:

```yaml
receivers:
  otlp:
    protocols:
      http:
        endpoint: 0.0.0.0:4318
      grpc:
        endpoint: 0.0.0.0:4317

processors:
  batch:

exporters:
  datadog:
    api:
      site: ${env:DD_SITE}
      key: ${env:DD_API_KEY}

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [datadog]
```

### 3. Add API Key and Site

Add api key in `.envrc`:

```
export DD_API_KEY=xxx
export DD_SITE="ap1.datadoghq.com" # Rewite your location
```

### 4. Run Docker

If you use gRPC, use port 4317.

```
docker run -d \
  -p 4318:4318 \
  --hostname $(hostname) \
  -v $(pwd)/otel-collector-config.yaml:/etc/otelcol-contrib/config.yaml \
  -e DD_API_KEY \
  -e DD_SITE \
  otel/opentelemetry-collector-contrib:0.90.1
```

see: https://docs.datadoghq.com/ja/opentelemetry/collector_exporter/otel_collector_datadog_exporter/?tab=onahost
