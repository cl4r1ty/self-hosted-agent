FROM nginx:stable

RUN set -e ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    apt-get upgrade -y

COPY  /tonginx/* /usr/share/nginx/html/

COPY run.sh /
ENTRYPOINT ["/run.sh"]
