# Setup for render using docker and nginx
Render is a project by the saalfeld lab at janelia for rendering microscopy datasets.

The docker compose file should be installed first, it is configured to build the docker image from the render github repo at `./render`.

The docker compose file uses the uid:gid 1018 for the render-ws user, create a new user to own the data for render-ws on disk: `adduser --uid 1018 --gid 1018 --home-dir / --no-create-home render-ws`

To build, clone the render repo next to the location of the docker compose file: `git clone https://github.com/saalfeldlab/render`, then run the docker compose file.

When running the docker compose file a directory with the database files will be created in the local directory named "persistent".

### nginx config
nginx is configured as a reverse proxy and connects to the port specified in the docker compose file.

Render is added to a subdirectory on our domain using the reverse proxy.

certbot is used to get an ssl certificate from letsencrypt and edit the configuration for it.
A 301 redirect should be added to direct http port 80 to https.

It is recommended to restrict access to the service as it does not have its own access restrictions, for example ip whitelisting and basic http authentication.

See nginx's documentation: https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/

nginx conf example:
```nginx
server {
    server_name etc...

    # other services
    ...

    location /render-ws/ {
        # recommended to whitelist ip ranges eg:
        allow 192.168.0.0/16;

        # recommended to require http password
        auth_basic "authentication required";
        auth_basic_user_file /etc/nginx/basic_auth_passwd;
        
        location ~ /render-ws/$ {  # redirect to the index page
            return 302 https://$host/render-ws/view/index.html;
        }
        
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://127.0.0.1:8081; # this port is used in the docker compose file
        proxy_redirect off;
    }

    ...

}
```

### updating
If any changes in render are made the github repository needs to be updated (eg `git pull`), then use --build when running the docker compose file to rebuild the image.
