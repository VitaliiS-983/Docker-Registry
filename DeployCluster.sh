#!/bin/bash
export NAME=kubern.cluster.k8s.local
export KOPS_STATE_STORE=s3://crm-system-k8s
kops create cluster --zones eu-west-1a ${NAME} --master-size=t2.small --node-size=t2.small --node-count=3 --master-volume-size=8 --node-volume-size=8
sleep 10
kops get cluster --name ${NAME} -oyaml > cluster.yaml
cat <<__EOF__>> cluster.yaml
  fileAssets:
    - content: |
        {
            "insecure-registries" : ["100.71.71.71:5000"]
        }
      name: insecure-registries
      path: /etc/docker/daemon.json
      roles:
      - Master
      - Node
__EOF__
sleep 5
kops replace -f cluster.yaml
kops update cluster ${NAME} --yes
