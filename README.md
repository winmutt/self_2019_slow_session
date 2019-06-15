# MySQL Slow Session Analysis

This was a talk I gave at SELF 2019 which included 3 live demos where we:
1. Investigated a slow log file.
2. Reviewed a raw pt-query-digest report.
3. Shipped pt-query-digest JSON reports into ES from filebeat.
4. Reviewed how we aggregate pt-query-digest reports by session rather than query.
5. Built various visualizations of the aggregated reports and discussed the usefulness of context injection into the sql logs.

These demos were run on a 4G VM on laptop with the following software:

> CentOS Linux release 7.6.1810 (Core)
> Percona-Server-shared-57-5.7.10-3.1.el7.x86_64
> Percona-Server-shared-compat-57-5.7.10-3.1.el7.x86_64
> Percona-Server-client-57-5.7.10-3.1.el7.x86_64
> Percona-Server-server-57-5.7.26-29.1.el7.x86_64
> elasticsearch-6.8.0-1.noarch
> kibana-6.8.0-1.x86_64
> filebeat-6.8.0-1.x86_64
> jq - commandline JSON processor [version 1.6]

These were largely default installs with the exception of filebeat who's relevant config files I have included in the etc directory here. We had 2 instances of filebeat running two ship to the two different ES indexes used, `mysql-slow-query` and `mysql-slow-session`

To properly map and process the pt-query-digest output you will need to load the templates from `db-template-es` into ES using the following command (each template is named after the files):
> curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_template/mysql-slow-session -d@mysql-slow-session.json

One thing to note about the templates is that filebeat changed its default type from `log` to `doc` around 5.x so if you find `/var/log/elasticsearch/elasticsearch.log` chock full o java errors about mismatched types you may need to change the defaul types in the templates (this took about an hour of googling to figure out)

I've also included my slides and don't hesitate to reach out for help.

Thanks,
-Rolf
