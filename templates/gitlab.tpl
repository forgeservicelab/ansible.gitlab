# GITLAB
# Maintainer: @randx

# CHUNKED TRANSFER
# It is a known issue that Git-over-HTTP requires chunked transfer encoding [0] which is not
# supported by Nginx < 1.3.9 [1]. As a result, pushing a large object with Git (i.e. a single large file)
# can lead to a 411 error. In theory you can get around this by tweaking this configuration file and either
# - installing an old version of Nginx with the chunkin module [2] compiled in, or
# - using a newer version of Nginx.
#
# At the time of writing we do not know if either of these theoretical solutions works. As a workaround
# users can use Git over SSH to push large files.
#
# [0] https://git.kernel.org/cgit/git/git.git/tree/Documentation/technical/http-protocol.txt#n99
# [1] https://github.com/agentzh/chunkin-nginx-module#status
# [2] https://github.com/agentzh/chunkin-nginx-module

upstream gitlab {
  server unix:{{ git_user_home }}/gitlab/tmp/sockets/gitlab.socket;
}

server {
  listen *:80 default_server;         # e.g., listen 192.168.1.1:80; In most cases *:80 is a good idea
  return 301 https://$host$request_uri;
}
server {
  listen *:443 ssl;
  server_name {{ web_domain }};     # e.g., server_name source.example.com;
  server_tokens off;     # don't show the version number, a security best practice
  add_header Strict-Transport-Security "max-age=31536000";
  add_header Public-Key-Pins 'pin-sha256="Fq3YMR2ibLgpoD509egJDn5cPXPfnXC5MUd2IWwV/qA="; pin-sha256="lqMfOTYct9rMx/Y2LpHI8aZt9xgWHX/TwLLQ51NQl04="; max-age=2592000';

  ssl on;
  ssl_certificate {{ ssl_cert_location }};
  ssl_certificate_key {{ ssl_key_location }};

  # SSL strengthening
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:!AES128;
  ssl_prefer_server_ciphers on;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  keepalive_timeout 70;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  root {{ git_user_home }}/gitlab/public;

  # Increase this if you want to upload large attachments
  # Or if you want to accept large git objects over http
  client_max_body_size 20m;

  # individual nginx logs for this gitlab vhost
  access_log  /var/log/nginx/gitlab_access.log;
  error_log   /var/log/nginx/gitlab_error.log;

  location / {
    # serve static files from defined root folder;.
    # @gitlab is a named location for the upstream fallback, see below
    try_files $uri $uri/index.html $uri.html @gitlab;
  }

  # if a file, which is not found in the root folder is requested,
  # then the proxy pass the request to the upsteam (gitlab unicorn)
  location @gitlab {
    # If you use https make sure you disable gzip compression
    # to be safe against BREACH attack
    # gzip off;

    proxy_read_timeout 300; # Some requests take more than 30 seconds.
    proxy_connect_timeout 300; # Some requests take more than 30 seconds.
    proxy_redirect     off;

    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_set_header   Host              $http_host;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;

    proxy_pass http://gitlab;
  }

  # Enable gzip compression as per rails guide: http://guides.rubyonrails.org/asset_pipeline.html#gzip-compression
  location ~ ^/(assets)/  {
    root {{ git_user_home }}/gitlab/public;
    gzip_static on; # to serve pre-gzipped version
    expires max;
    add_header Cache-Control public;
  }

  error_page 502 /502.html;
}
