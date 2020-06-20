## Necessary Metrics and How to Monitor These by Prometheus

| Necesarry Metrics   | How to Monitor These by Prometheus | Document Link                                                             |
| ------------------- | ---------------------------------- | ------------------------------------------------------------------------- |
| OS Resouce of Pods  | cAdvisor                           | https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md |
|                     | kube-state-metrics                 |                                                                           |
| OS Resouce of Nodes | node-exporter                      |                                                                           |

### 監視項目

#### RED

#### USE

##### Node

##### Pod

- CPU
  - usage
  - requests
  - limits
  - throttled seconds
- Memory
- Network
- Disk
- Throttling

##### Container

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

## prometheus.yaml の relabel_config

- https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
- relabel_configs で取得すべき項目のラベルを作っている

  - source_labels：元ネタ
  - regex で正規表現抽出した項目について replace、keep、drop、labelmap、labeldrop,labelkeep でアクションする
  - replace：regex 連結され source_labels たと照合します。次に、設定 target_label に replacement 一致グループの参照（と、${1}、${2}、...）で replacement、その値によって置換されました。regex 一致しない場合、置換は行われません。  
    → 一致した部分を target_label に挿入
  - keep：regex 連結に一致しないターゲットをドロップします source_labels。
  - drop：regex 連結に一致するターゲットを削除し source_labels ます。
  - hashmod：連結されたハッシュのに設定さ target_label れ modulus ます source_labels。
  - labelmap：regex すべてのラベル名と照合します。その後で与えられたラベル名に一致するラベルの値をコピー replacement 一致グループの参照を（${1}、${2}中、...）replacement その値によって置換されています。
  - labeldrop：regex すべてのラベル名と照合します。一致するラベルは、ラベルのセットから削除されます。
  - labelkeep：regex すべてのラベル名と照合します。一致しないラベルは、ラベルのセットから削除されます。

- 元ネタには以下のような meta タグを使用する

```
__meta_kubernetes_namespace: The namespace of the service object.
__meta_kubernetes_service_annotation_<annotationname>: Each annotation from the service object.
__meta_kubernetes_service_annotationpresent_<annotationname>: "true" for each annotation of the service object.
__meta_kubernetes_service_cluster_ip: The cluster IP address of the service. (Does not apply to services of type ExternalName)
__meta_kubernetes_service_external_name: The DNS name of the service. (Applies to services of type ExternalName)
__meta_kubernetes_service_label_<labelname>: Each label from the service object.
__meta_kubernetes_service_labelpresent_<labelname>: true for each label of the service object.
__meta_kubernetes_service_name: The name of the service object.
__meta_kubernetes_service_port_name: Name of the service port for the target.
__meta_kubernetes_service_port_protocol: Protocol of the service port for the target.
__meta_kubernetes_service_type: The type of the service.
```

## 検討必要事項

- メモリを食うので VictoriaMetrics とかで工夫するかメトリクスを減らす必要がある
- バージョンによって設定項目が変わってしまうので、設定を Code として git 上に残していくことが重要
