#!/usr/bin/env bash

touch /root/.ssh/config
if ! grep -rnw '/root/.ssh/config' -e 'ServerAliveInterval 50'
then
    echo 'ServerAliveInterval 50' > /root/.ssh/config
fi

ansible-playbook --private-key ../terraform/horovod playbook.yaml -u ubuntu