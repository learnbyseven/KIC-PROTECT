# Usecases
## Nginx Ingress controller use_Cases
### Usecases Phase1

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
curl http://<host_fqdn>/?a=<script> 
```
* (Eg. above for SQL injection , TOP 10 OWASP)
