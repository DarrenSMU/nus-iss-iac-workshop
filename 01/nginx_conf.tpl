user www-data;
worker_processes auto;
pid /run/nginx.pid;
events {
worker_connections 768;
}
http {
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
gzip on;
upstream apps {
least_conn;
# the following list the container endpoints
# one server line for each endpoint
# eg server <docker_host_ip>:<exposed_port>;
server ${ip}:${ports[0]};
server ${ip}:${ports[1]};
server ${ip}:${ports[2]};
}
server {
listen 80;
location / {
proxy_pass http://apps;
}
}
}