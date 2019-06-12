#!/bin/bash
clear

echo "+==================+"
echo "|Server Environment|"
echo "+==================+"

rpm -qa|grep "elastic\|kibana\|filebeat"
echo "jq - commandline JSON processor [version 1.6]"
read -p '$ '
clear

echo "+====================================+"
echo "|Let's output pt-query-digest to json|"
echo "+====================================+"

cat <<eof
pt-query-digest 
    --limit=0% 
    --output json 
    --filter=" \$event->{Bytes} = length(\$event->{arg}) and \$event->{hostname}=\"self_19.com\""
    /var/lib/mysql/localhost-slow.log | jq -c '.classes[]' | 
jq -c ".instance_name=\"self_19\"" > /var/log/mysql_slow_log_analysis.json
eof
read -p '$ '
clear

echo "+============================+"
echo "|Let's send json files to ELK|"
echo "+============================+"

cat <<eof
filebeat.prospectors:
  - fields_under_root: true
    ignore_older: "24h"
    json:
     keys_under_root: true
    paths:
     - "/var/log/mysql_slow_log_analysis.json"
eof
read -p '$ '
clear

while true; do
  echo "Truncating slow query log"
  > `mysql -NBe "select @@slow_query_log_file"`
  echo "Turning on slow query log"
  mysql -Ne "set global long_query_time=0; set global slow_query_log='ON';"
  echo -n "Running some fun queries "
  rnd_number=$((RANDOM/1000))
  for x in `seq 1 $rnd_number`; do
    mysql < ~/self_19/queries.sql > /dev/null
    echo -n "."
  done;
  mysql < ~/self_19/queries.sql > /dev/null
  echo "."
  echo "Turning off slow query log"
  mysql -Ne "set global slow_query_log='OFF'; set global long_query_time=10;"
  ls -l `mysql -NBe "select @@slow_query_log_file"`
  pt-query-digest \
      --limit=0% \
      --output json \
      --filter=" \$event->{Bytes} = length(\$event->{arg}) and \$event->{hostname}=\"self_19.com\""\
      /var/lib/mysql/localhost-slow.log | jq -c '.classes[]' | jq -c ".instance_name=\"self_19\"" > /var/log/mysql_slow_log_analysis.json
  ls -l /var/log/mysql_slow_log_analysis.json
  sleep 5;
done; 


