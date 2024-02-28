#!/usr/bin/env bash
set -euo pipefail

REPLICAS=$(kubectl get statefulset/dxp -o jsonpath='{.spec.replicas}')

kubectl scale --replicas=0 statefulset/dxp

kubectl delete persistentvolumeclaim -l 'app.kubernetes.io/name=mysql' --wait=false

kubectl rollout restart statefulset/mysql
kubectl rollout status statefulset/mysql

kubectl scale --replicas=${REPLICAS} statefulset/dxp
