#!/bin/bash
clear

echo "+==================+"
echo "|Server Environment|"
echo "+==================+"

uname -a
echo
cat /etc/redhat-release
echo
rpm -qa|grep -i percona-server
read -p '$ '
clear

echo "+=======================+"
echo "|Sakila Example Database|"
echo "+=======================+"
mysql -e "select table_name, table_rows from information_schema.tables where table_schema='sakila';"
read -p '$ '
clear

echo "+=====================+"
echo "|Sakila Sample Queries|"
echo "+=====================+"
cat queries.sql
read -p '$ '
clear

echo "+========================+"
echo "|Slow Query Log Variables|"
echo "+========================+"
> `mysql -NBe "select @@slow_query_log_file"`
echo '> `mysql -NBe "select @@slow_query_log_file"`'
mysql -vvve "show global variables like 'slow_query%'; show global variables like 'long%';"
read -p '$ '
clear

echo "+=============================+"
echo "|Turning on the slow query log|"
echo "+=============================+"
mysql -vvve "set global long_query_time=0; set global slow_query_log='ON';"
read -p '$ '
clear

cat <<map
          --------------------------------------------------------------------
           The bat bites!

               ------
               |....|    ----------
               |.<..|####...@...$.|
               |....-#   |...B....+
               |....|    |.d......|
               ------    -------|--



           Player the Rambler     St:12 Dx:7 Co:18 In:11 Wi:9 Ch:15  Neutral
           Dlvl:1 $:0  HP:9(12) Pw:3(3) AC:10 Exp:1/19 T:257 Weak

          --------------------------------------------------------------------
map

echo -n "Running some fun queries "
for x in {1..20}; do
  mysql < ~/self_19/queries.sql > /dev/null
  echo -n "."
done;
mysql < ~/self_19/queries.sql > /dev/null
echo "."
read -p '$ '
clear

echo "+==============================+"
echo "|Turning off the slow query log|"
echo "+==============================+"
mysql -vvve "set global slow_query_log='OFF'; set global long_query_time=10;"
echo
echo "Slow log file has been generated"
ls -l `mysql -NBe "select @@slow_query_log_file"`
read -p '$ '
clear

echo "Let's generate a pt-query-digest and dig in"
echo "`mysql -NBe "select @@slow_query_log_file"`"
echo


