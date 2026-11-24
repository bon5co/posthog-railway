# PostHog ClickHouse for Railway: the stock server plus PostHog's own configuration, Kafka table schemas and
# funnel UDFs, fetched at build time from the PostHog repo at the same commit as the app image.
FROM alpine:3.21 AS assets
ARG POSTHOG_COMMIT=1e7b36ebe0da38a738fed250d175809a899ef422
RUN apk add --no-cache git
WORKDIR /src
RUN git init -q . \
 && git remote add origin https://github.com/PostHog/posthog.git \
 && git sparse-checkout set --no-cone /docker/clickhouse/ /posthog/idl/ /posthog/user_scripts/ \
 && git -c protocol.version=2 fetch -q --depth 1 --filter=blob:none origin "$POSTHOG_COMMIT" \
 && git checkout -q FETCH_HEAD

# upstream: ClickHouse/ClickHouse
FROM clickhouse/clickhouse-server:26.6.1.1193@sha256:1d1f6508eba2dccce2cee9913907c5f7766327debc57a6b1991f2c9e3176c163
COPY --from=assets /src/docker/clickhouse/config.xml /etc/clickhouse-server/config.xml
COPY --from=assets /src/docker/clickhouse/config.d/default.xml /etc/clickhouse-server/config.d/default.xml
COPY --from=assets /src/docker/clickhouse/users.xml /etc/clickhouse-server/users.xml
COPY --from=assets /src/docker/clickhouse/user_defined_function.xml /etc/clickhouse-server/user_defined_function.xml
COPY --from=assets /src/posthog/idl /opt/posthog/idl
COPY --from=assets /src/posthog/user_scripts /opt/posthog/user_scripts
COPY listen.xml /etc/clickhouse-server/config.d/zz-railway-listen.xml
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
# The cluster definitions dial the compose service name "clickhouse"; inside this container that is the server itself.
# ZooKeeper lives in its own Railway service.
RUN sed -i 's#<host>clickhouse</host>#<host>127.0.0.1</host>#g' /etc/clickhouse-server/config.d/default.xml \
 && sed -i 's#<host>zookeeper</host>#<host>zookeeper.railway.internal</host>#' /etc/clickhouse-server/config.xml \
 && grep -q zookeeper.railway.internal /etc/clickhouse-server/config.xml \
 && ! grep -q '<host>clickhouse</host>' /etc/clickhouse-server/config.d/default.xml \
 && chmod +x /usr/local/bin/railway-entrypoint.sh
ENV CLICKHOUSE_SKIP_USER_SETUP=1
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
