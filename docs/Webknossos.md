# Setup for webknosssos using docker and nginx
The docker compose file should be installed first, make sure to edit the file if your domain is not `https://webknossos.tnw.tudelft.nl`.

The docker compose file uses the uid:gid 1014 for the webknossos user, create a new user to own the data for webknossos on disk: `adduser --uid 1014 --gid 1014 --home-dir / --no-create-home webknossos`

The docker compose file is configured to use an smtp server running on the host server, the server is used to send email verification links, we have found no real benefit to these as accounts will always have to be manually activated anyway so the options starting with -Dmail could simply be removed.

When running the docker compose file a directory with the database files will be created in the local directory named "persistent".
Webknossos requires a location to store datasets, this location should have large amounts of storage available, our configuration uses the location `/long_term_storage/webknossos/binaryData`, this location needs to be owned by the webknossos user, in addition we'd like this location to remain owned by the webknossos user so we configure it to inherit group ownership: `chown webknossos:webknossos

Follow the guide here on how to set up the instance's first run: https://docs.webknossos.org/webknossos/installation.html

### nginx config
nginx is configured as a reverse proxy and connects to the port specified in the docker compose file.

Webknossos requires a subdomain and is not compatible with a setup as subdirectory, ie in the nginx config: `location /`.

certbot is used to get an ssl certificate from letsencrypt and edit the configuration for it.
A 301 redirect should be added to direct http port 80 to https.

nginx conf example:
```nginx
server {
    server_name webknossos.tnw.tudelft.nl;
    client_max_body_size 0;
    proxy_http_version 1.1; # very important

    location / {
        proxy_pass http://127.0.0.1:9002/; # 9002 is the port used in the docker-compose.yml
    }

    # letsencrypt ssl stuff is added by certbot
}
```

### updating
The webknossos version is pinned in the docker compose file, when this is changed it might be needed to run a database migration, check webknossos's changelog for this, a script is added to run migrations on the running postgres instance: `postgres_evolution.sh`

### scripts
Some other useful scripts are provided for managing the webknossos database, some of these features have been added already to the web interface however.
