# Run Liferay Portal in Kubernetes via Tilt

System Requirements:
* 32 GB RAM minimum
* 8 (logical) CPUs minimum

Install these tools first:
* docker (use whichever platform compatible implementation is most suitable to you)
* kubectl (simplest via `brew install kubectl`)
* k3d (simplest via `brew install k3d`)
* tilt (simplest via `brew install tilt`)

Run this to create a k3d cluster (with local docker registry):

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

  > __Note__: This deletes everything including the database volume.

  ```shell
  tilt down
  ```

* When `tilt` is "up" access the Tilt UI at

  http://localhost:10350/r/(all)/overview

* When `tilt` is "up" you'll likely want to access DXP. To do so, run the following command:

  ```
  kubectl port-forward dxp-0 8080:8080 8000:8000 11310:11311
  ```

  > __Note:__ This port-forward targets the first "replica" of DXP. If you have specified more than one replica and want to interact with them directly you can specify a different suffix to the port-forward argument `dxp-0` (replicas are integer indexed from `0`) and specifying a different port for each forward (e.g. `... dxp-1 8081:8080 8001:8000 11311:11311` and so on).

  Then you can access the default virtual instance at the address:

  http://vi1.localtest.me:8080

  You can access the other virtual instances at:

  http://vi2.localtest.me:8080

  and

  http://vi3.localtest.me:8080

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

To connect a remote debugger to replica `dxp-0` use the address: `localhost:8000`

## Telnet to the gogo shell of a a specific Liferay pod

Telnet to `dxp-0` using the command: `telnet localhost 11310`

## Use a different (even custom) Liferay image

Edit `config.yaml` and set the value of `dxp.image`.

## Increase the number of Liferay replicas

First you need to place a cluster license in `dxp-docker-root/deploy`. Then
edit `config.yaml` and set the value of `dxp.replicas` to a number higher than 1.
