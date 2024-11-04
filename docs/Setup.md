# Hoogenboom lab electron microscopy infrastructure setup
This documentation details our lab's digital infrastructure for electron microscopy, we have multiple services running on our server:
- render ws https://github.com/saalfeldlab/render
- Webknossos https://github.com/scalableminds/webknossos/
- CATMAID https://github.com/catmaid/CATMAID/
- Delmic's proprietary data processing service for the FAST-EM
- nginx reverse proxy
- postfix mail server
- borgmatic system backup
- smartmontools disk monitoring

We use Ubuntu Linux and docker containers to run these services, nginx reverse proxy is used to host multiple services on our multiple domains: https://sonic.tnw.tudelft.nl https://webknossos.tnw.tudelft.nl

In addition this repository contains docker files and scripts to set up and maintain these services.

See the docker compose documentation on more detailed information on how to use docker compose: https://docs.docker.com/compose/

## Installation
Supporting software like nginx is installed through apt from Ubuntu's software repositories, then configured depending on the desired configuration.
Our choices for these could be changed for alternatives if needed.

Here are more detailed guides for the services running in docker containers:
- [Render](./Render-ws.md)
- [Webknossos](./Webknossos.md)
- [CATMAID](./catmaid.md)

Basic installation overview:
1. install docker compose and nginx
2. run docker-compose for each container
3. edit nginx config
4. check firewall configuration to only allow web traffic over port 80 and 433
