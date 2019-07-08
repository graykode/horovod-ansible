#!/usr/bin/env bash

ansible-playbook --private-key ../terraform/horovod test.yaml \
            -u ubuntu -vvv