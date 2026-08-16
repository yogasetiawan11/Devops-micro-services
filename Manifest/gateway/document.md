To integrate Gateway in Kubernetes First. You have to install Gateway resources. In this case I'am using Envoy Gateway controller, with helm as the bridge. 

## Install the Gateway API CRDs and Envoy Gateway 

helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.8.3 -n envoy-gateway-system --create-namespace


## Verify the Gateway has installed

kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available


## Define app in The Gateway manifest
Once you have installed, next define your app into the file using HTTP route methode, Using this methode I'am able to access my app through HTTP.

