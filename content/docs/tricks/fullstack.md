---
title: Full-stack Dart
description: Full-stack Dart project with Serverpod as back-end
weight: 15
---

## Getting started

```sh
dart pub global activate serverpod_cli
serverpod create property_log
cd property_log
```

Run this in a terminal to start the back-end server.

```sh
cd property_log_server
docker compose up --build -d
dart bin/main.dart --apply-migrations
```

And this in another to execute code generation as files change.

```sh
cd property_log_server
serverpod generate --watch
```

## First endpoint

`property_log_server/lib/src/properties/property.spy.yaml`

```yaml
### A user can manage logs for one or more properties
class: Property
table: properties
fields:
  ### ID of the owner
  owner: String
  ### Name of Property
  name: String
```

```sh
cd property_log_server
serverpod generate
serverpod create-migration
```

## Test the app

```sh
cd property_log/property_log_server
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

## Authentication

Follow [Getting Started with Serverpod: Authentication — Part
1](https://medium.com/serverpod/getting-started-with-serverpod-authentication-part-1-72c25280e6e9).
