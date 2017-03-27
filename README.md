# K8S Monitoring: Prometheus, AlertManager and Grafana

Currently, this project is strongly based on: https://github.com/kayrus/prometheus-kubernetes

This is Work in Progress, but I believe that works

## Setup

### 1. Create a namespace to group our resources and export `NAMESPACE` env, in our case we named it `monitoring`
```
$ kubectl create namespace monitoring
namespace "monitoring" created
$ export NAMESPACE=monitoring
```

### 2. Create a TLS [secret](https://kubernetes.io/docs/user-guide/secrets/#overview-of-secrets) named `etcd-tls-client-certs` 
Our [Prometheus Deployment](/deployments/prometheus-deploy-svc.yaml#L63) uses TLS keypair and TLS auth for etcd cluster

2.1  Generate keys

```
$ openssl req \
  -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt -subj '/CN=localhost'
Generating a 2048 bit RSA private key
.................................................................+++
............................................................................................+++
writing new private key to 'tls.key'https://prometheus.io/docs/alerting/configuration/
-----
```

2.2 Create secret
```
$ kubectl create secret tls etcd-tls-client-certs --cert=tls.crt --key=tls.key -n=monitoring
secret "tls-secret" created
```

### 3 Configure Alerting

We have only slack alert template and configuration for Slack alerts. Change the [slack api url](/config/alertmanager-cm/config.yml#L5) properly according to your [Slack Hooks](https://api.slack.com/incoming-webhooks) configuration.

#### Included alert rules

Prometheus alert rules which are already included in this repo:

* NodeCPUUsage > 50%
* NodeLowRootDisk > 80% (relates to `/root-disk` mount point inside `node-exporter` pod)
* NodeLowDataDisk > 80% (relates to `/data-disk` mount point inside `node-exporter` pod)
* NodeSwapUsage > 10%
* NodeMemoryUsage > 75%
* NodeLoadAverage (alerts when node's load average divided by amount of CPUs exceeds 1)

### 4 Just run the script deploy.sh  
```
$ cd scripts/
$ . deploy.sh 
configmap "external-url" created
configmap "grafana-imports" created
configmap "prometheus-rules" created
configmap "alertmanager-templates" created
configmap "alertmanager" created
configmap "prometheus" created
deployment "alertmanager" created
service "alertmanager" created
deployment "grafana" created
service "grafana" created
daemonset "node-exporter" created
configmap "prometheus-env" created
deployment "prometheus-deployment" created
service "prometheus-svc" created
Successfully deployed!
NAME                                    READY     STATUS              RESTARTS   AGE
alertmanager-670954578-gw5c0            0/1       ContainerCreating   0          2s
grafana-1556722099-xmkh1                0/2       ContainerCreating   0          1s
node-exporter-mt9c4                     0/1       ContainerCreating   0          1s
node-exporter-pgf51                     0/1       ContainerCreating   0          1s
node-exporter-v028j                     0/1       ContainerCreating   0          1s
node-exporter-vbj2k                     0/1       ContainerCreating   0          1s
prometheus-deployment-534706379-965p6   0/1       ContainerCreating   0          1s

```

___
## Project organization:

### The [config directory](/config) contains the configuration's files used for creation of [ConfigMaps](https://kubernetes.io/docs/user-guide/configmap/) by [deploy.sh](scripts/deploy.sh) 

* The [config/alertmanager-cm](/config/alertmanager-cm) directory contains the configuration file for the alertmanager. The ConfigMap is called by [alertmanager deployment](/deployments/alertmanager-deploy-svc.yaml#L41). More info in the [docs](https://prometheus.io/docs/alerting/configuration/)
* The [config/alertmanager-templates-cm](/config/alertmanager-templates-cm) directory contains custom alertmanager templates. The ConfigMap is called by [alertmanager deployment](/deployments/alertmanager-deploy-svc.yaml#L44). More info [here](https://prometheus.io/blog/2016/03/03/custom-alertmanager-templates/).
* The [config/grafana-imports-cm](/config/grafana-imports-cm) directory contains [Grafana Dashboards](https://grafana.com/dashboards) and [Prometheus Datasource Plugin](https://grafana.com/plugins/prometheus). The ConfigMap is called by [grafana deployment](/deployments/grafana-deploy-svc.yaml#L84). 
* The [config/prometheus-cm](/config/prometheus-cm) directory contains the configuration file for Prometheus, including the [K8S Service Discovery](https://prometheus.io/docs/operating/configuration/#kubernetes_sd_config) configs. The ConfigMap is called by [prometheus deployment](/deployments/prometheus-deploy-svc.yaml#L70). More info in the [docs](https://prometheus.io/docs/operating/configuration/). 
* The [config/prometheus-rules-cm](/config/prometheus-rules-cm) directory contains the prometheus alert rules. The ConfigMap is called by [prometheus deployment](/deployments/prometheus-deploy-svc.yaml#L73). More info in the [docs](https://prometheus.io/docs/alerting/rules/)

### The [deployments directory](/deployments) contains the definitions of our deployments and services. We exposed our services by NodePort, however, you can edit the following files removing the `type: NodePort` spec of services and use Ingress instead. Both approaches can be found [here](https://github.com/arthur0/exposing-k8s-svc). 

* [alertmanager-deploy-svc.yaml](/deployments/alertmanager-deploy-svc.yaml):  Deployment and Service of alertmanager 
* [grafana-deploy-svc.yaml](/deployments/grafana-deploy-svc.yaml):  Deployment and Service of Grafana, including dashboard/datasource imports 
* [node-exporter-ds.yaml](/deployments/node-exporter-ds.yaml):  Deamonset to export hardware and OS metrics 
* [prometheus-deploy-svc.yaml](/deployments/prometheus-deploy-svc.yaml): Deployment and Service of Prometheus 

### The [Scripts](/scripts) directory contains automatized routines 

* [deploy.sh](/scripts/deploy.sh): Initialize all resources
* [undeploy.sh](/scripts/undeploy.sh):  Delete all resources
* [update_alertmanager_config.sh](/scripts/update_alertmanager_config.sh): Updates the alertmanager ConfigMap by changes made in [alertmanager-cm](/config/alertmanager-cm)
* [update_alertmanager_templates.sh](/scripts/update_alertmanager_templates.sh): Updates the alertmanager-templates ConfigMap by changes made in [alertmanager-templates-cm](/config/alertmanager-templates-cm)
* [update_grafana_imports.sh](/scripts/update_grafana_imports.sh): Updates the grafana-imports ConfigMap by changes made in [grafana-imports-cm](/config/grafana-imports-cm)
* [update_prometheus_config.sh](/scripts/update_prometheus_config.sh): Updates the prometheus ConfigMap by changes made in [prometheus-cm](/config/prometheus-cm)
* [update_prometheus_rules.sh](/scripts/update_prometheus_rules.sh): Updates the prometheus-rules ConfigMap by changes made in [prometheus-rules-cm](/config/prometheus-rules-cm)


Any question or suggestion: artmr@lsd.ufcg.edu.br
