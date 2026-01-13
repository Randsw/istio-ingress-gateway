#!/usr/bin/env bash

set -e

#Install base istio chart
helm upgrade --install --wait --timeout 35m --atomic --namespace istio-system --create-namespace \
    --repo https://istio-release.storage.googleapis.com/charts istio-base base

#Install istiod
helm upgrade --install --wait --timeout 35m --atomic --namespace istio-system --create-namespace \
    --repo https://istio-release.storage.googleapis.com/charts istiod istiod --values - <<EOF
global:
  proxy:
    autoInject: disabled
meshConfig:
  accessLogFile: /dev/stdout
  enableAutoMtls: false
pilot:
  autoscaleEnabled: false
  replicaCount: 1
  resources:
    requests:
      cpu: 100m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1024Mi
  sidecarInjectorWebhook:
    enabled: false
istio_cni:
  enabled: false
EOF

#Install istio gateway
helm upgrade --install --wait --timeout 35m --atomic --namespace istio-ingress --create-namespace \
    --repo https://istio-release.storage.googleapis.com/charts istio-ingress gateway