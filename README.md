# Run Liferay Portal in Kubernetes via Tilt

Install these tools first:
* docker
* k3d (simplest via `brew`)
* tilt (simplest via `brew`)

Run this to create k3d cluster (with local docker registry):

```shell
k3d cluster create liferay-tilt -p "8080:80@loadbalancer" --registry-create registry:0.0.0.0:5000
```

# Tilt/k3d usage

* To bring everything up with defaults

  ```shell
  tilt up
  ```

* To start with clustering

  ```shell
  tilt up -- --replicas=2
  ```

* To bring everything down

  ```shell
  tilt down
  ```

* When `tilt` is "up" access the Tilt UI at

    http://localhost:10350/r/(all)/overview

* When `tilt` is "up" access DXP at

    http://localhost:8080

* Stop the k3d cluster when you're done to recover the resources. (K3d will keep running in the background even after system restarts if you let it.)

  ```shell
  k3d cluster stop liferay-tilt
  ```

* To start a stopped k3d cluster (to avoid having to recreate it)

  ```shell
  k3d cluster start liferay-tilt
  # then
  tilt up
  ```

## Debug a specific Liferay pod

Manually port forward the debug port of a pod to a local port:

```shell
kubectl port-forward dxp-1 8001:8000
```

.. then connect a remote debugger to `localhost:8001`

## Use a different (even custom) Liferay image

Edit `config.yaml` and set the value of `dxp.image`.

## Increase the number of Liferay replicas

Edit `config.yaml` and set the value of `dxp.replicas`.
