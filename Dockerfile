FROM isaaclevin/dps-provision-tool-base:latest

WORKDIR /

# declare environment variables "subscription_id", "app_id", "tenant_id", "sp_secret"
ENV subscription_id=""
ENV app_id=""
ENV tenant_id=""
ENV sp_secret=""
ENV GITHUB_TOKEN=""
ENV action="deploy"
ENV skip_deployment="false"
ENV running_in_action="false"
ENV create_devbox="true"
ENV create_ade="true"

COPY scripts/ /scripts/
RUN chmod -R +x /scripts/

COPY src/ /src/
RUN chmod -R +x /src/

COPY /run.sh /run.sh
RUN chmod +x /run.sh

RUN find /scripts -type f -print0 | xargs -P 4 -0 -n 1  dos2unix

RUN find /src -type f -print0 | xargs -P 4 -0 -n 1  dos2unix

ENTRYPOINT ["/run.sh"]
#ENTRYPOINT [ "/bin/bash" ]