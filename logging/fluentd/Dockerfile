FROM fluent/fluentd:v1.11-debian-1

# Use root account to use apt
USER root

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish
RUN buildDeps="sudo make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install \
             fluent-plugin-elasticsearch \
             fluent-plugin-rewrite-tag-filter \
             fluent-plugin-detect-exceptions \
             fluent-plugin-forest \
             fluent-plugin-record-reformer \
             fluent-plugin-filter-docker_metadata \
             fluent-plugin-filter_typecast \
             fluent-plugin-filter_empty_keys \
             fluent-plugin-route \
             fluent-plugin-concat \
             fluent-plugin-detect-exceptions \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY ./fluent_agent.conf /fluentd/etc/fluent.conf
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh
USER fluent
