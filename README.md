# Run Liferay Portal in Kubernetes via Tilt

System Requirements:
* 32 GB RAM minimum
* 8 (logical) CPUs minimum

Install these tools first:
* `docker` (use whichever platform compatible implementation is most suitable to you)
* `kubectl` (simplest via `brew install kubectl`)
* `k3d` (simplest via `brew install k3d`)
* `tilt` (simplest via `brew install tilt`)

Run this to create a k3d cluster (with local docker registry):

```shell
k3d cluster create liferay-tilt -p "8880:80@loadbalancer" --registry-create registry:0.0.0.0:5000
```

# Tilt/k3d usage

* Starting in the root of the repository.

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

## When `tilt` is `up`

* Access the Tilt UI at

  http://localhost:10350/r/(all)/overview

* You can access the default virtual instance at the address:

  http://vi1.localtest.me:8880

  You can access the other virtual instances at:

  http://vi2.localtest.me:8880

  and

  http://vi3.localtest.me:8880

## The K3d cluster

K3d runs in the background and uses resources even after system restarts if you let it (as part if it's mission of being resilient).

* Stop the k3d cluster when you're done with it to recover the resources

  ```shell
  k3d cluster stop liferay-tilt
  ```

* To start a stopped k3d cluster (to avoid having to recreate it)

  ```shell
  k3d cluster start liferay-tilt
  # then
  tilt up
  ```

## Connect to specific Liferay replicas

To open ports directly to a specific Liferay replica, run the following command:

> __Note:__ Replicas are integer indexed from `0`.

```shell
# specify the replica to connect to
REPLICA="#" # e.g. 0

kubectl port-forward dxp-${REPLICA} \
  808${REPLICA}:8080 \
  800${REPLICA}:8000 \
  1131${REPLICA}:11311
```

### Debug a specific Liferay replica

To remote debug replica `dxp-${REPLICA}` use the address: `localhost:800${REPLICA}`.

### Gogo Shell to a specific Liferay replica

Telnet to `dxp-${REPLICA}` using the command: `telnet localhost 1131${REPLICA}`

## Configuration (`tilt_config.json`)

The `Tilefile` is setup to support 3 configuration properties:

* __`domainBase`__ (default `localtest.me`) - The base domain used for all domains (resolves globally to `127.0.0.1` which makes it convenient for testing.)
* __`dxpDockerTag`__ (default `liferay/dxp:latest`) - Set the docker tag of the Liferay service you want to run.
* __`replicas`__ (default `1`) - The number of replicas of the Liferay service to keep online.

To override the defaults permanently, create a `tilt_config.json` in the root of the repository and set place the properties as the root keys of a JSON map.

e.g. `tilt_config.json`

```json
{
  "dxpDockerTag": "liferay/dxp:7.4.13.nightly"
}
```