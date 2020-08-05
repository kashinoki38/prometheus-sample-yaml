## USE x RED

### サービス監視（RED）

- Rate : =Throughput, 秒間リクエスト数, 秒間 PV 数
- Error Rate : エラー率, 5xx とか
- Duration : =ResponseTime, %ile 評価が一般的

### リソース監視（USE）http://www.brendangregg.com/usemethod.html

- Utilization : 使用率 E.g. CPU 使用率
- Saturation : 飽和度, どれくらいキューに詰まっているか  
  E.g. ロードアベレージ
- Errors : エラーイベントの数

## 必要な Exporter

| Exporter           | Link                                                                                                                                       |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Node Exporter      | NodeExporter<br/>https://github.com/kashinoki38/microservices-demo/blob/master/deploy/kubernetes/manifests-monitoring/node-exporter-ds.yml |
| kube-state-metrics | kube-state-metrics<br/>https://github.com/kubernetes/kube-state-metrics/tree/master/docs                                                   |

## 各 Exporter に対する Scrape 方針

| Exporter              | Scrape Target Endpoint                                                                                                                                       | Scrape Config Sample の job name |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------- |
| cadvisor              | apiserver の以下 metrics パス<br/>https://kubernetes.default.svc:443/api/v1/nodes/gke-cn-horiuchiysh-s-cn-horiuchiysh-s-2b141725-5coq/proxy/metrics/cadvisor | kubernetes-cadvisor              |
| NodeExporter          | 各 pod のコンテナポートの/metrics へ投げる<br/>nodexporter/metrics                                                                                           | kubernetes-pods                  |
| go                    | 各 pod のコンテナポートの/metrics へ投げる<br/>go/metrics                                                                                                    | kubernetes-service-endpoints     |
| nodejs                | 各 pod のコンテナポートの/metrics へ投げる<br/>nodejs/metrics                                                                                                | kubernetes-service-endpoints     |
| mongodb               | 各 pod のコンテナポートの/metrics へ投げる<br/>mongodb/metrics                                                                                               | kubernetes-pods                  |
| Istio Mesh            | istio-telemetry サービスの endpoint port name が prometheus<br/>http://10.48.2.14:42422/metrics                                                              | istio-mesh                       |
| kubelet               | 各ノードの 10255 ポート<br/>http://10.30.3.20:10255/metrics10255                                                                                             | kubernetes-nodes                 |
| kube-apiserver        | default namespace に api server 向けの svc と endpoint がある<br/>https://104.198.95.200:443/metrics                                                         | kubernetes-service-endpoints     |
| kube-state-metrics    | 各サービスの/metrics へ投げる<br/>http://kube-state-metrics:8080/metrics                                                                                     | kubernetes-service-endpoints     |
| prove                 | /api/v1/nodes/gke-cn-horiuchiysh-s-cn-horiuchiysh-s-2b141725-5coq/proxy/metrics/probes<br/>                                                                  | ベット job が必要                |
| kube-controll-manager | デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする<br/>/metrics                                           |                                  |
| kube-proxy            | デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする<br/>/metrics                                           |                                  |
| kube-scheduler        | デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする<br/>/metrics                                           |

### Scrape Config Sample

#### kubernetes-pods

```yaml
- job_name: kubernetes-pods
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
  - role: pod
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
    separator: ;
    regex: ""true""
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_pod_node_name]
    separator: ;
    regex: (.*)
    target_label: node
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    regex: (.*)
    target_label: namespace
    replacement: $1
    action: replace
  - source_labels: [__meta_kubernetes_pod_name]
    separator: ;
    regex: (.*)
    target_label: pod_name
    replacement: $1
    action: replace
```

#### kubernetes-nodes

各ノードの 10255 ポート

```yaml
- job_name: kubernetes-nodes
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
    - role: node
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    insecure_skip_verify: true
  relabel_configs:
    - separator: ;
      regex: (.*)
      target_label: __scheme__
      replacement: https
      action: replace
    - source_labels: [__meta_kubernetes_node_label_kubernetes_io_hostname]
      separator: ;
      regex: (.*)
      target_label: instance
      replacement: $1
      action: replace
    - source_labels: [__address__]
      separator: ;
      regex: ^(.+?)(?::\d+)?$
      target_label: __address__
      replacement: $1:10255
      action: replace
```

#### kubernetes-cadvisor

apiserver の以下 metrics パス  
`/api/v1/nodes/gke-cn-horiuchiysh-s-cn-horiuchiysh-s-2b141725-5coq/proxy/metrics/cadvisor`

```yaml
- job_name: kubernetes-cadvisor
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: https
  kubernetes_sd_configs:
    - role: node
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: false
  relabel_configs:
    - separator: ;
      regex: __meta_kubernetes_node_label_(.+)
      replacement: $1
      action: labelmap
    - separator: ;
      regex: (.*)
      target_label: __address__
      replacement: kubernetes.default.svc:443
      action: replace
    - source_labels: [__meta_kubernetes_node_name]
      separator: ;
      regex: (.+)
      target_label: __metrics_path__
      replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      action: replace
```

#### istio-mesh

istio-telemetry サービスの endpoint port name が prometheus の port

```yaml
- job_name: istio-mesh
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
    - role: endpoints
      namespaces:
        names:
          - istio-system
  relabel_configs:
    - source_labels:
        [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      separator: ;
      regex: istio-telemetry;prometheus
      replacement: $1
      action: keep
```

#### kubernetes-service-endpoints

```yaml
- job_name: kubernetes-service-endpoints
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  kubernetes_sd_configs:
    - role: endpoints
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    insecure_skip_verify: false
  relabel_configs:
    - source_labels: [__meta_kubernetes_service_label_component]
      separator: ;
      regex: apiserver
      target_label: __scheme__
      replacement: https
      action: replace
    - source_labels:
        [__meta_kubernetes_service_label_kubernetes_io_cluster_service]
      separator: ;
      regex: "true"
      replacement: $1
      action: drop
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      separator: ;
      regex: "false"
      replacement: $1
      action: drop
    - source_labels: [__meta_kubernetes_pod_container_port_name]
      separator: ;
      regex: .*-noscrape
      replacement: $1
      action: drop
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
      separator: ;
      regex: ^(https?)$
      target_label: __scheme__
      replacement: $1
      action: replace
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
      separator: ;
      regex: ^(.+)$
      target_label: __metrics_path__
      replacement: $1
      action: replace
    - source_labels:
        [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
      separator: ;
      regex: ^(.+)(?::\d+);(\d+)$
      target_label: __address__
      replacement: $1:$2
      action: replace
    - separator: ;
      regex: ^__meta_kubernetes_service_label_(.+)$
      replacement: $1
      action: labelmap
    - source_labels: [__meta_kubernetes_namespace]
      separator: ;
      regex: (.*)
      target_label: namespace
      replacement: $1
      action: replace
    - source_labels: [__meta_kubernetes_pod_name]
      separator: ;
      regex: (.*)
      target_label: pod_name
      replacement: $1
      action: replace
```

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

## Jmeter との連携

https://github.com/kubernauts/jmeter-operator
