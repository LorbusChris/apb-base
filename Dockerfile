FROM centos:7
MAINTAINER Ansible Playbook Bundle Community

LABEL "com.redhat.apb.version"="0.1.0"

RUN mkdir -p /root/.kube /usr/share/ansible/openshift \
            /etc/ansible /opt/apb /opt/ansible
COPY config /root/.kube/config
RUN yum -y install epel-release centos-release-openshift-origin \
    && yum -y update \
    && yum -y install origin origin-clients net-tools bind-utils \
    && yum install -y python-setuptools python-pip gcc python-devel python-cffi openssl-devel ansible \
    && yum clean all

RUN pip install openshift

RUN echo "localhost ansible_connection=local" > /etc/ansible/hosts \
    && echo '[defaults]' > /etc/ansible/ansible.cfg \
    && echo 'roles_path = /etc/ansible/roles:/opt/ansible/roles' >> /etc/ansible/ansible.cfg

RUN ansible-galaxy install ansible.kubernetes-modules

COPY oc-login.sh entrypoint.sh /usr/bin/

RUN useradd -u 1001 -r -g 0 -M -b /opt/apb -s /sbin/nologin -c "apb user" apb
RUN chown -R apb: /opt/{ansible,apb}

ENTRYPOINT ["entrypoint.sh"]