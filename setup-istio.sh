#!/usr/bin/env bash

set -e

log(){
  echo "---------------------------------------------------------------------------------------"
  echo $1
  echo "---------------------------------------------------------------------------------------"
}

get_service_lb_ip(){
  kubectl get svc -n $1 $2 -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

dnsmasq(){
  log "Hosts ..."
  local INGRESS_LB_IP=$(get_service_lb_ip istio-ingress istio-ingressgateway)
  echo "$INGRESS_LB_IP grafana.kind.cluster alertmanager.kind.cluster agent.kind.cluster single.kind.cluster" | sudo tee -a /etc/hosts
}

# kubectl apply -f - <<EOF
# apiVersion: networking.k8s.io/v1
# kind: IngressClass
# metadata:
#   name: istio
# spec:
#   controller: istio.io/ingress-controller
# EOF

# #Install base istio chart
# helm upgrade --install --wait --timeout 35m --atomic --namespace istio-system --create-namespace \
#     --repo https://istio-release.storage.googleapis.com/charts istio-base base

# #Install istiod
# helm upgrade --install --wait --timeout 35m --atomic --namespace istio-system --create-namespace \
#     --repo https://istio-release.storage.googleapis.com/charts istiod istiod --values - <<EOF
# global:
#   proxy:
#     autoInject: disabled
# meshConfig:
#   accessLogFile: /dev/stdout
#   enableAutoMtls: false
# pilot:
#   autoscaleEnabled: false
#   replicaCount: 1
# EOF

# #Install istio gateway
# helm upgrade --install --wait --timeout 35m --atomic --namespace istio-ingress --create-namespace \
#     --repo https://istio-release.storage.googleapis.com/charts istio-ingressgateway gateway --values - <<EOF
# service:
#   type: LoadBalancer
# EOF

# kubectl apply -f - <<EOF
# apiVersion: monitoring.coreos.com/v1
# kind: PodMonitor
# metadata:
#   name: istiod-monitor
#   namespace: istio-system
#   labels:
#     # Match the label selector of your Prometheus Operator (e.g., release: kube-prometheus)
#     release: kube-prometheus
# spec:
#   selector:
#     matchLabels:
#       app: istiod
#   namespaceSelector:
#     matchNames:
#       - istio-system
#   podMetricsEndpoints:
#     - port: http-monitoring # This maps to port 15014 in the istiod container
#       path: /metrics
#       interval: 15s
# EOF

# kubectl apply -f - <<EOF
# apiVersion: monitoring.coreos.com/v1
# kind: PodMonitor
# metadata:
#   name: istio-ingressgateway-monitor
#   namespace: istio-ingress
#   labels:
#     # This label must match your Prometheus Operator's serviceMonitorSelector
#     release: kube-prometheus-stack
# spec:
#   selector:
#     matchLabels:
#       # Targets the gateway pods based on their standard label
#       app: istio-ingressgateway
#   namespaceSelector:
#     matchNames:
#       - istio-ingress
#   podMetricsEndpoints:
#     - port: http-envoy-prom # Standard name for port 15020 in Istio 2026
#       path: /stats/prometheus
#       interval: 15s
#       relabelings:
#         - action: replace
#           replacement: istio-ingressgateway
#           targetLabel: job
# EOF

dnsmasq