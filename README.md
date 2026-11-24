# PostHog on Railway

Wrapper image for the [PostHog](https://github.com/PostHog/posthog) Railway template.

`ghcr.io/bon5co/posthog-railway-clickhouse` is the stock ClickHouse server plus PostHog's own ClickHouse
configuration, Kafka table schemas and funnel UDFs (fetched from the PostHog repo at the same commit as the app
image), listening on the Railway private network (IPv6) and with ZooKeeper pointed at its own service.
The rest of the stack runs unmodified upstream images through start commands.

PostHog is MIT licensed (outside `ee/`); this wrapper changes no upstream source.
