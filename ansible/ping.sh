#!/usr/bin/env bash

ansible -m ping --private-key ../terraform/horovod \
          -i inventory.ini -u ubuntu all -vvv