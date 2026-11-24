#!/bin/bash
# Railway mounts the volume root-owned and with a lost+found directory that ClickHouse would read as a database.
set -eo pipefail
DATA_DIR=/var/lib/clickhouse
mkdir -p "$DATA_DIR"
rm -rf "$DATA_DIR/lost+found" || true
# The funnel UDFs and Kafka schemas must sit under the data directory, which the volume hides, so copy them at every boot.
mkdir -p "$DATA_DIR/format_schemas" "$DATA_DIR/user_scripts"
cp -r /opt/posthog/idl/. "$DATA_DIR/format_schemas/"
cp -r /opt/posthog/user_scripts/. "$DATA_DIR/user_scripts/"
chmod -R 755 "$DATA_DIR/user_scripts"
chown -R clickhouse:clickhouse "$DATA_DIR"
# system.crash_log must exist before PostHog's custom_metrics migration runs (mirrors upstream init-db.sh).
(
  for i in $(seq 1 90); do
    if clickhouse-client --query "SELECT 1" >/dev/null 2>&1; then
      clickhouse-client --query "SYSTEM FLUSH LOGS" && echo "[posthog] system logs flushed" && break
    fi
    sleep 2
  done
) &
exec /entrypoint.sh "$@"
