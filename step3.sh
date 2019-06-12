#!/bin/bash
clear

while true; do
  # prep the slow query log
  echo "Truncating slow query log"
  > `mysql -NBe "select @@slow_query_log_file"`

  echo "Turning on slow query log"
  mysql -Ne "set global long_query_time=0; set global slow_query_log='ON';"

  echo -n "Running some fun queries "
  for x in `seq 1 5`; do
    rnd_number=$((RANDOM%10))
    for y in `seq 1 $rnd_number`; do
       cat /root/self_19/queries.sql
    done | { cat; echo "SET @sql_context_injection='{REQUEST_URI:\"/$((RANDOM))\"}';"; } # | mysql > /dev/null
    echo -n "."
  done;
  mysql < ~/self_19/queries.sql > /dev/null
  echo "."
  echo "Turning off slow query log"
  mysql -Ne "set global slow_query_log='OFF'; set global long_query_time=10;"
  ls -l `mysql -NBe "select @@slow_query_log_file"`

  # start of pt-query-digest by session
  rm -rf /tmp/localhost-slow.log.thread_id* &> /dev/null
  mkdir /tmp/localhost_slow_thread_id &> /dev/null
  echo "Processing slow log info by thread_id into JSON format, to identify top sessions"
  pt-query-digest "/var/lib/mysql/localhost-slow.log" \
    --group-by Thread_id > "/tmp/localhost-slow.log.thread_id" \
    --limit 5

  for x in $( grep Profile -A 7 "/tmp/localhost-slow.log.thread_id" |tail -n 5| awk '{print $9}' ); do
    echo "Awking to /tmp/localhost-slow.log.thread_id.${x}"
    awk "/^#.*Id: *$x/,/#\\ Time.*/" "/var/lib/mysql/localhost-slow.log" > "/tmp/localhost-slow.log.thread_id.${x}"

    echo "PQDing to /tmp/localhost-slow.log.thread_id.${x}.pqd.json"
    pt-query-digest "/tmp/localhost-slow.log.thread_id.${x}" \
      --limit 10 \
      --filter "\$event->{Thread_id} eq '$x'" \
      --output json-anon \
      > "/tmp/localhost-slow.log.thread_id.${x}.pqd.json"

    echo "Thread id ${x}"
    context=$( sed -rne "s|^SET @sql_context_injection='(.*)';|\\1|p" "/tmp/localhost-slow.log.thread_id.${x}" | \
      sed 's|\\"|"|g' | sed 's|\\/|/|g' | \
      jq -c ".thread_id=\"${x}\"" )

    if [ -z "$context" ]; then
     context="{}"
    fi;

    echo "Preparing final output ${x} with context ${context}"
    jq -c "{pqd_output: .classes, summary: .global, context: $context, instance_name: \"self_19\"}" \
      "/tmp/localhost-slow.log.thread_id.${x}.pqd.json" > "/tmp/localhost_slow_thread_id/${x}.pqd.json"
  done;

  ls -l /var/log/mysql_slow_log_analysis.json
  sleep 5;
done;
