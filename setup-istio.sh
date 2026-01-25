#!/usr/bin/env bash

set -e

#!/usr/bin/env bash

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
  local INGRESS_LB_IP=$(get_service_lb_ip istio-ingress istio-ingress)
  echo "$INGRESS_LB_IP grafana.kind.cluster alertmanager.kind.cluster agent.kind.cluster single.kind.cluster" | sudo tee -a /etc/hosts
}

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: istio
spec:
  controller: istio.io/ingress-controller
EOF

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
EOF

#Install istio gateway
helm upgrade --install --wait --timeout 35m --atomic --namespace istio-ingress --create-namespace \
    --repo https://istio-release.storage.googleapis.com/charts istio-ingressgateway gateway --values - <<EOF
service:
  type: LoadBalancer
EOF

#dnsmasq