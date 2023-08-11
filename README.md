# Usecases Phase1

1. HTTP Load Balancing 
2. TCP Load Balancing 
3. Session Persistence 
4. Active Health-Check
5. HTTP Header based Routing 
6. SSL/TLS Termination
7. URL Rewrite/Redirect
8. Rate-Limiting
9. WAF - Default Policy 

* Use header flag with curl, in case of absence of DNS entry for <Host_Fqdn> , curl -H "Host: <host_fqdn>" http/https://<NIC-IP>


#### Case 1 
```
kubectl create namespace <namespace>  
kubectl create -f cafe_Application/  
cd virtual_Server 
kubectl -n <namespace> create -f httpLoadbalancing_virtualServer.yaml 
```
 
#### Case 2 (With TCP sample APP)


#### Case 3
```
kubectl -n <namespace> create -f sessionPersistence_virtualServer.yaml \
```
* Open -> Browser -> place <host_fqdn> as url -> developer tool -> Browse >host_fqdn>. \
* Inside Developer tool look for Response header -> srv_id (Persist session to backend server). 

#### Case 4 
* Pod spec should have Readiness probe for a healthcheck URL/Path , check Cafe deployment spec for reference. \
```
kubectl -n <namespace> create -f activeHealthcheck_virtualServer.yaml
```
* Open NIC DB (If not enabled please check official doc. for enabling NIC Dash board) , Verify Active health check.
#### Case 5
```
kubectl -n <namespace> create -f headerbasedRouting_virtualServer.yaml 
curl <host_fqdn> --cookie "order=coffee" 
curl <host_fqdn> --cookie "order=tea"
```
#### Case 6
* Create TLS Cert & Key. 
* Create kubernetes secret with above cert & key. 
```
kubectl -n <namespace> create -f tlsTermination_virtualServer.yaml
```
* Verify by accessing url over https. 
 
#### Case 7
```
kubectl -n <namespace> create -f rewriteURL_virtualServer.yaml 
kubectl -n <namespace> create -f redirectURL_virtualServer.yaml 
curl <host_fdqn>/<path>
```
#### Case 8
```
kubectl -n <namespace> create -f rateLimiting_virtualServer.yaml 
for i in {1..21}; do curl <host_fqdn>; done 
```
* Verify "(HTTP) 503 Service Unavailable" page.
 
#### Case 9
```
cd ../ 
kubectl -n <namespace> create -f policycontrol_WAF/nap_WAF/
curl -X POST -i --data '<script>alert(/XSS/)</script>' http://cafeshop.giri.local
```
* (Eg. above for SQL injection , TOP 10 OWASP)


# Usecases Phase2
1. NIC - Custom Logs with UUID data, format-JSON as STD-OUTPUT/ERR (Pods Logs) , Collected by FluentBIT 
   Verifcation : OB team to validate the log format and custom UUID data collection. 
2. NIC metrics export in Promethues format 
   Verification: OB team to validate the metrics exported from the endpoint in promethues format and collected by the metrics collector. 
3. NAP - Security Logs forwarding format JSON as STD-OUTPUT/ERR (Pods Logs) , Collected by FluentBIT 
   Verifcation : OB team to validate the log format and collection.
 
#### Case 1 

- nginx-config-map.yaml (Config name, Namespace must be similar to the applied config map eg. name: my-release-nginx-ingress , namespace: nginx-ingress)
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: my-release-nginx-ingress
  namespace: nginx-ingress
data:
  log-format-escaping: json
  log-format: '{"time":"$msec","proxyHost":"$proxy_host", "host": "$http_host", "UUID" : "abcd1235-789-xz"}'
  stream-log-format-escaping: json
  stream-log-format: '{"remote_addr":"$remote_addr [$time_local]", "protocol":"$protocol", "ssl_server": "$ssl_preread_server_name"}'

```
```
kubectl apply -f nginx-config-map.yaml
```
#### Case 2
Annotations:     
- prometheus.io/port: 9113
- prometheus.io/scheme: http
- prometheus.io/scrape: true

Promethues endpoint : /metrics
 
Metrics Example 
- nginx_ingress_nginxplus_upstream_zombies{class="nginx",upstream="vs_dev-ops_vs-app-dev_vsr_app-dev-cafeshop_vsr-cafeshop_cafeshop"} 0
 
```
curl http://<pod_ip>:9113/metrics
```
#### Case 3 
```
Testing in progress
```

MISC Observability
-----------------
POD health 
- health-status-uri=/nginx-health
- ready-status-port=8081


#### RBAC high-level view

##### Procedure to test, validate resources after running $kubectl create/apply -f /directory
```
1. kubectl create ns appdev
2. kubectl create ns secops
3. git clone https://github.com/learnbyseven/kicWAF.git && cd kicWAF/2-phase-observability
4. kubectl apply -f appdev_NS/
5. kubectl apply -f secops_NS/project_appdev/
6. kubectl apply -f nginx-ingress_NS/project_appdev/
7. Validate resources created by point 1,2,4,5,6,7
8. Application/Route verification step $curl -H "Host: appdev.giri.local" http://nic_ip:nic_port
9. curl -X POST -i --data '<script>alert(/XSS/)</script>' -H "Host: appdev.giri.local" http://nic_ip:nic_port
```
<img width="799" alt="image" src="https://github.com/learnbyseven/kicWAF/assets/34051943/c6463b6c-1618-4517-833d-0f3ca28a4eb7">

