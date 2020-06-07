## Necesarry Metrics and How to Monitor These by Prometheus

| Necesarry Metrics   | How to Monitor These by Prometheus |
| ------------------- | ---------------------------------- |
| OS Resouce of Pods  | cAdvisor                           |
|                     | kube-state-metrics                 |
| OS Resouce of Nodes | node-exporter                      |

### cAdvisor

- node の 10255 ポートの metrics/cadvisor にリクエストなげるとコンテナ単位のが取れる
- cAdvisor は kubelet バイナリに統合されているので、デフォルトで取得可能。
- scrape config で取得するための設定が必要

```yaml
# Scrape config for Kubelet cAdvisor.
- job_name: "kubernetes-cadvisor"
  scheme: https

  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  kubernetes_sd_configs:
    - role: node

  relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
    - target_label: __address__
      replacement: kubernetes.default.svc:443
    - source_labels: [__meta_kubernetes_node_name]
      regex: (.+)
      target_label: __metrics_path__
      replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
```

### kube-state-metrics

### node-exporter
