openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=amz Inc./CN=amazonaws.com' -keyout ca.key -out ca.crt
sleep 2
openssl req -out server.csr -newkey rsa:2048 -nodes -keyout server.key -subj "/CN=ec2-35-154-229-189.ap-south-1.compute.amazonaws.com/O=amz"
sleep 2
openssl x509 -req -sha256 -days 365 -CA ca.crt -CAkey ca.key -set_serial 2 -in server.csr -out server.crt
sleep 2
kubectl -n bg create secret  tls tls-cert --key server.key --cert server.crt
