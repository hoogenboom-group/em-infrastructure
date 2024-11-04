# Setup for CATMAID using docker and nginx
CATMAID is a tool for visualising datasets in a browser, it can be used in a similar way to Webknossos.
While Webknossos is favored over CATMAID because of its better performance, previous publications of ours have linked to datasets on CATMAID and those need to stay available

The docker compose file should be installed first, it is in a git submodule, if the submodule hasn't been checked out yet use `git submodule update --init`.
See https://git-scm.com/book/en/v2/Git-Tools-Submodules for more info on submodules.

Check the submodule's README.md and the official documentation here: https://catmaid.readthedocs.io/en/stable/docker.html

### nginx config
nginx is configured as a reverse proxy and connects to the port specified in the docker compose file.

CATMAID is added to a subdirectory on our domain using the reverse proxy.

In addition to the web service an alias to the data is added to host images used on catmaid at, the subdirectory `catmaid_projects` is used for this.
For us this is mapped to `/long_term_storage/catmaid_projects`, replace this location if needed.
When adding a project to CATMAID the project's files need to be placed in this local directory in order for the images to be accessible.
Note that this location will be accessible to anyone, even if not logged in.
Because of this it is only to be used for public data.

certbot is used to get an ssl certificate from letsencrypt and edit the configuration for it.
A 301 redirect should be added to direct http port 80 to https.

nginx conf example:
```nginx
server {
    server_name etc...

    # other services
    ...

    location /catmaid/ {
        proxy_pass http://127.0.0.1:8012/; # this port is used in the docker compose file
    }

    location /catmaid_projects/ {
        # this is publicly accessible to the outside world for catmaid
        # that means people can guess file names in this folder and access them from anywhere
        alias /long_term_storage/catmaid_projects/;
        expires max;
        add_header Cache-Control public;
        add_header Access-Control-Allow-Origin *;
    }

    ...

}
```

### updating
When the submodule is updated use --build with docker compose in order to build the new image.
