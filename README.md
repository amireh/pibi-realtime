# Pibi-Realtime

A Rack app mounting [Faye]() and communicating with [Pibi](https://github.com/amireh/pibi-rails) via Redis.

## Usage

Install the dependencies:

```bash
bundle install
```

Check out `config/application.yml` for the available configuration
environment variables or see the table below.

Run it:

```bash
bundle exec puma -p 9123
```

## Configuration

Field                       | Default | Notes
--------------------------- | ------- | --------------------------------
PIBI_REDIS_CHANNEL          | "pibi_realtime"
PIBI_REDIS_DB               | 0
PIBI_REDIS_FAYE_DB          | 1
PIBI_REDIS_HOST             | "localhost"
PIBI_REDIS_ID               | "pibi_realtime"
PIBI_REDIS_PASSWORD         | 
PIBI_REDIS_PORT             | 6379
PIBI_REDIS_TIMEOUT          | 5.0
