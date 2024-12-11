FROM ghcr.io/ansible/community-ansible-dev-tools:latest

USER root

RUN microdnf install -y jq

RUN setcap cap_sys_admin,cap_sys_resource=eip /usr/bin/ansible-playbook

CMD ["/bin/bash"]
