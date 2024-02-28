FOR /F %%i IN ('kubectl get statefulset/dxp -o jsonpath="{.spec.replicas}"') DO set REPLICAS=%%i

kubectl scale --replicas=0 statefulset/dxp

kubectl delete persistentvolumeclaim -l 'app.kubernetes.io/name=mysql' --wait=false

kubectl rollout restart statefulset/mysql
kubectl rollout status statefulset/mysql

kubectl scale --replicas=%REPLICAS% statefulset/dxp
