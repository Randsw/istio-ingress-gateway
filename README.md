# Istio as a Standalone Gateway (NGINX Ingress Replacement)

This guide details how to deploy **Istio** as a high-performance Ingress Controller and **Gateway API** implementation on a **Kind** cluster, specifically configured without the sidecar service mesh.

## Prerequisites

Ensure the following are installed and updated for 2026:

- **Docker** (Engine or Desktop)
- **kubectl**
- **Kind CLI**
- **Helm** (v3.x+)

---

## 1. Cluster Infrastructure Setup

Initialize the environment by running the setup script. This creates a multi-node cluster (1 Control Plane, 3 Workers) pre-configured with MetaLB (LoadBalancer support) and local image registries.

```bash
chmod +x ./cluster-setup.sh
./cluster-setup.sh
```

## 2. Deploy VictoriaMetrics Kubernetes stack with Grafana

Run `./setup-vms.sh`

### Get grafana password

Login - admin

Password:

`kubectl get secret --namespace victoria-metrics vm-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

## 3. Deploy Istio

Run `./setup-istio.sh`

## Open web UI

- [Grafana](grafana.kind.cluster)

Working UI prove that Istio works as ingress-nginx replacement

## Recommended Dashboards

Import the following IDs into Grafana:

7636: Istio Service
7645: Istio Control Plane
23501: Istio Envoy Listeners
23502: Istio Envoy Clusters
23503: Istio Envoy HTTP Connection Manager

## 4. Use Istio as Kubernetes Gateway implementation

Run `./setup-gateway.sh`

This deploy `httpbin` application and custom resource(Gateway and HTTPRoute) to access app.

## Test that Kubernetes Gateway is working

### Set the `INGRESS_HOST` environment variable

```bash
export INGRESS_HOST=$(kubectl get gateways.gateway.networking.k8s.io gateway -n istio-ingress -ojsonpath='{.status.addresses[0].value}')
```

### Perform a Connectivity Test

```bash
curl -s -I -HHost:httpbin.example.com "http://$INGRESS_HOST/get"
```

Response Code must be 200.
