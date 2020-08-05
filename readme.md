## 必要メトリクス一覧

### サービス監視（RED）

#### Jmeter

##### Grafana Dashboard

性能試験時のクライアント  
Jmeter のメトリクスを収集<br/>BackendListner->InfluxDB->Grafana

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/jmeter-metrics-dashboard.json

| メトリクス   |     | USE x RED |
| ------------ | --- | --------- |
| Throughput   |     | R         |
| ResponseTime |     | D         |
| Error%       |     | E         |

#### システムサイド　 Istio Telemet

Istio のテレメトリ機能で各 service のメトリクスを収集

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/Istio-Mesh-Dashboard.json  
https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/Istio-Workload-Dashboard.json  
https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/Istio-Service-dashboard.json

| メトリクス   |     | USE x RED | Prometheus |
| ------------ | --- | --------- | ---------- |
| Throughput   |     | R         | o          |
| ResponseTime |     | D         | o          |
| Error%       |     | E         | o          |

#### システムサイド　 Prometheus クライアントライブラリを利用

• 各言語のクライアントライブラリ使って Prometheus にメトリクスとして送る（request_duration_seconds をヒストグラム集計）
https://github.com/devopsdemoapps/sockshop/search?q=request_duration_seconds&unscoped_q=request_duration_seconds

- go
  - github.com/prometheus/client_golang/prometheus
  - https://github.com/devopsdemoapps/sockshop/blob/13041ac53907b1de51f39160e6ed5be7efdc8bf7/payment/wiring.go#L17
- nodejs
  - prom-client
  - https://github.com/devopsdemoapps/sockshop/blob/13041ac53907b1de51f39160e6ed5be7efdc8bf7/front-end/api/metrics/index.js#L11
- java
  - io.prometheus.client.Histogram
  - https://github.com/devopsdemoapps/sockshop/blob/13041ac53907b1de51f39160e6ed5be7efdc8bf7/carts/src/main/java/works/weave/socks/cart/middleware/HTTPMonitoringInterceptor.java#L23

##### Grafana Dashboard

TBD

| メトリクス   |                                             | USE x RED | Prometheus | Grafana Dashboard | Prometheus metrics |
| ------------ | ------------------------------------------- | --------- | ---------- | ----------------- | ------------------ |
| Throughput   | request_duration_seconds をヒストグラム集計 | R         | o          | TBD               |                    |
| ResponseTime |                                             | D         | o          |                   |                    |
| Error%       |                                             | E         | o          |

### OS リソース監視（USE）

#### クラスタ全体

NodeExporter と cAdvisor にて収集

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/kubernetes-cluster-dashboard.json

| メトリクス             |                                                                        | USE x RED    | Prometheus |
| ---------------------- | ---------------------------------------------------------------------- | ------------ | ---------- |
| Node Availability      | ノード全体の稼働率<br/>各ノードの Ready 時間合計/(集計期間 × ノード数) | Availability |            |
|                        | Node 数                                                                | Availability | o          |
|                        | unschedulable Node 数                                                  | Availability | o          |
|                        | Node の詳細<br/>kubernetes.node.name,各リソース量                      | Conf         | o          |
| Pods Availability      | Available Pods 数                                                      | Availability | o          |
|                        | Pods status<br/>Running / Pending / Failed / Unknown                   | Availability | o          |
| Container Availability | Containers status<br/>Ready / Terminated / Waiting / Running           | Availability | o          |
| Deployment Count       | Deployment Count                                                       | Availability | o          |
| StatefulSet Count      | StatefulSet Count                                                      | Availability | o          |
| DaemonSet Count        | DaemonSet Count                                                        | Availability | o          |
| Job Count              | Job Count                                                              | Availability | o          |
|                        | Failed Job Count                                                       | Availability | o          |

#### Node

Node Exporter で収集

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/node-exporter-dashboard.json

| メトリクス        |                                                                        | USE x RED    | Prometheus |
| ----------------- | ---------------------------------------------------------------------- | ------------ | ---------- |
| Node Availability | ノード全体の稼働率<br/>各ノードの Ready 時間合計/(集計期間 × ノード数) | Availability | o          |
|                   | Node 数                                                                | Availability | o          |
|                   | unschedulable Node 数                                                  | Availability | o          |
|                   | Node の詳細<br/>kubernetes.node.name,各リソース量                      | Conf         | o          |
| pods              | Pods Allocatable                                                       | Conf         | o          |
|                   | Pods Capacity                                                          | Conf         | o          |
|                   | Pods Allocation                                                        |              | o          |
| CPU               | CPU 使用率                                                             | U            | o          |
|                   | CPU 使用率コアごと                                                     | U            | o          |
|                   | ロードアベレージ                                                       | S            | o          |
|                   | CPU Core Capacity                                                      | Conf         | o          |
|                   | CPU Core Limits                                                        | Conf         | o          |
|                   | CPU Core Requests                                                      | Conf         | o          |
|                   | CPU Core Allocatable                                                   | Conf         | o          |
| メモリ            | メモリ使用量                                                           | U            | o          |
|                   | スワップイン量                                                         | S            | o          |
|                   | スワップアウト量                                                       | S            | o          |
|                   | スワップ使用率                                                         | S            | o          |
|                   | スワップサイズ                                                         | S            | o          |
|                   | Memory Capacity                                                        | Conf         | o          |
|                   | Memory Limits                                                          | Conf         | o          |
|                   | Memory Requests                                                        | Conf         | o          |
|                   | Memory Allocatable                                                     | Conf         | o          |
| ディスク          | ディスクビジー率                                                       | U            | o          |
|                   | ディスク I/O 待ち数                                                    | S            | o          |
|                   | ディスク I/O 待ち時間                                                  | S            | o          |
|                   | ディスク読込み量                                                       | U            | o          |
|                   | ディスク書込み量                                                       | U            | o          |
|                   | ディスク読込み回数                                                     | U            | o          |
|                   | ディスク書込み回数                                                     | U            | o          |
|                   | パーティション使用率                                                   | U            | o          |
|                   | パーティションサイズ                                                   | U            | o          |
|                   | inode 総数/使用率                                                      | U            | o          |
| ネットワーク      | 送信トラフィック量                                                     | U            | o          |
|                   | 受信トラフィック量                                                     | U            | o          |
|                   | ポート/Socket                                                          | U            |            |
|                   | Drops                                                                  | E            | o          |
|                   | Errs                                                                   | E            | o          |
|                   | ping                                                                   | Availability |            |
|                   | ファイルディスクリプタ                                                 | U            | o          |
| プロセス          | プロセス数                                                             | U            |            |
|                   | プロセス数(ゾンビ)                                                     | U            |            |
|                   | 占有プロセス状況(プロセスキューサイズ)                                 | U            |

#### Pod/Container

cAdvisor にて収集
(Kubelet バイナリに統合されているので scrape の設定のみで OK)

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/pod_detail-dashboard.json

| メトリクス             |                                                                    | USE x RED    | Prometheus |
| ---------------------- | ------------------------------------------------------------------ | ------------ | ---------- |
| Pods Availability      | Available Pods 数                                                  | Availability | o          |
|                        | Pods Restarts                                                      | Availability | o          |
|                        | Pods status<br/>Running / Pending / Failed / Unknown               | Availability | o          |
| Container Availability | Restarts                                                           | Availability | o          |
|                        | Errors<br/>Terminated Reason<br/>Waiting Reason<br/>Restart Reason | E            | o          |
|                        | Containers status<br/>Ready / Terminated / Waiting / Running       | Availability | o          |
| CPU                    | CPU 使用率                                                         | U            | o          |
|                        | ロードアベレージ                                                   | S            | o          |
|                        | Throttle                                                           | S            | o          |
|                        | CPU Core Limits                                                    | Conf         | o          |
|                        | CPU Core Requests                                                  | Conf         | o          |
| メモリ                 | メモリ使用量                                                       | U            | o          |
|                        | スワップイン量                                                     | S            | x          |
|                        | スワップアウト量                                                   | S            | x          |
|                        | スワップ使用量                                                     | S            | o          |
|                        | スワップサイズ                                                     | S            | x          |
|                        | Memory Limits                                                      | Conf         | o          |
|                        | Memory Requests                                                    | Conf         | o          |
| ディスク               | ディスクビジー率                                                   | U            | o          |
|                        | ディスク I/O 待ち数                                                | S            | o          |
|                        | ディスク I/O 待ち時間                                              | S            | o          |
|                        | ディスク読込み量                                                   | U            | o          |
|                        | ディスク書込み量                                                   | U            | o          |
|                        | ディスク読込み回数                                                 | U            | o          |
|                        | ディスク書込み回数                                                 | U            | o          |
|                        | パーティション使用率                                               | U            | o          |
|                        | パーティションサイズ                                               | U            | △          |
|                        | inode 総数/使用率                                                  | U            | o          |
| ネットワーク           | 送信トラフィック量                                                 | U            | o          |
|                        | 受信トラフィック量                                                 | U            | o          |
|                        | ポート/Socket                                                      | U            | △          |
|                        | Drops                                                              | E            | o          |
|                        | Errs                                                               | E            | o          |
|                        | ping                                                               | Availability |            |
|                        | ファイルディスクリプタ                                             | U            | △          |

#### Persistent Volume

kubelet の metics エンドポイントから収集

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/pv-dashboard.json

| メトリクス       |                    | USE x RED | Prometheus |
| ---------------- | ------------------ | --------- | ---------- |
| ファイルシステム | ディスク領域使用量 | U         | o          |
|                  | inode 総数/使用率  | U         | o          |

### MW リソース監視

#### Nginx

##### Grafana Dashboard

TBD

| メトリクス     |                  | USE x RED | Prometheus |
| -------------- | ---------------- | --------- | ---------- |
| コネクション数 | Active / Dropped | S         |            |
| スループット   | request per sec  | R         |            |
| HTTP           | レスポンスコード | E         |            |
| レイテンシ     | Response Time    | D         |            |
| Network bytes  |

#### Java (Jetty on SpringBoot)

SpringBoot2 系以降から実装の、Micrometer Actuator を使用  
（pom.xml 変更のみで良いはず）

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/jmx-exporter-dashboard.json

| メトリクス               |                          | USE x RED | Prometheus |
| ------------------------ | ------------------------ | --------- | ---------- |
| ヒープメモリ             | 全体ヒープメモリ使用量   | U         | o          |
|                          | Young                    | U         | o          |
|                          | Old                      | U         | o          |
|                          | Metaspace                | U         | o          |
|                          | Code Cache               | U         | o          |
| GC                       | 頻度（Full/Young）       | S         | o          |
|                          | 時間（Full/Young）       | S         | o          |
| レスポンスタイム         | レスポンスタイム         | D         | ?          |
| レスポンスコード         | レスポンスコード         | E         | ?          |
| スレッド数               | スレッド数               | S         | o          |
| 空きスレッド数           | 空きスレッド数           | Conf      | ?          |
| スレッドプール使用率     | スレッドプール使用率     | S         | ?          |
| コネクションプール使用数 | コネクションプール使用数 | S         | ?          |

#### Go

golang クライアントライブラリの promhttp を使用  
https://github.com/prometheus/client_golang/tree/master/prometheus/promhttp

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/go-process-dashboard.json

| メトリクス     |     | USE x RED | Prometheus |
| -------------- | --- | --------- | ---------- |
| Process Memory |     | U         | o          |
| Memory Stats   |     | U         | o          |
| Goroutines     |     | S         | o          |
| GC duration    |     | S         | o          | ##### Grafana Dashboard |

#### Nodejs

nodejs クライアントライブラリの prom-client を使用  
https://github.com/siimon/prom-client

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/nodejs-dashboard.json

| メトリクス      |     | USE x RED | Prometheus |
| --------------- | --- | --------- | ---------- |
| Process Memory  |     | U         | o          |
| Active Handlers |     | S         | o          |

#### MySQL

##### Grafana Dashboard

#### mongodb

##### Grafana Dashboard

#### Redis

##### Grafana Dashboard

### Kubernetes コンポーネント

#### kube-api-server

kube-api-server の metrics エンドポイントから収集

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/kube-apiserver-dashboard.json

| メトリクス              |                                | USE x RED | Prometheus |
| ----------------------- | ------------------------------ | --------- | ---------- |
| API コール              | REST リクエスト数              | R         | o          |
|                         | API リクエストレイテンシ       | D         | o          |
|                         | API リクエストエラー           | E         | o          |
| Controller Manager から | ワークキューの追加率           |           | o          |
|                         | ワークキューの待ち時間         |           | o          |
|                         | ワークキューの深さ             |           | o          |
| etcd から               | etcd キャッシュエントリ        |           | x          |
|                         | etcd キャッシュのヒット/ミス率 |           | x          |
|                         | etcd キャッシュ期間            |           | x          |
| リソース                | メモリ使用量                   |           | o          |
|                         | CPU 使用量                     |           | o          |
|                         | Go routine                     |           | o          |

#### kube-controller-manager

Controller manager の metrics エンドポイントから収集  
デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする

##### Grafana Dashboard

TBD

| メトリクス       |                                          | USE x RED | Prometheus |
| ---------------- | ---------------------------------------- | --------- | ---------- |
| インスタンス     | kube-controller-manager インスタンスの数 |           |            |
| ワークキュー情報 | ワークキューのレイテンシー               |           |            |
|                  | ワークキューレート                       |           |            |
|                  | ワークキューの深さ                       |           |            |
| kube-api         | kube-api リクエストレート                |           |            |
|                  | kube-api リクエストレイテンシ            |           |            |
| リソース         | メモリ使用量                             |           |            |
|                  | CPU 使用量                               |           |            |
|                  | Go routine                               |

#### etcd

kube-scheduler の metrics エンドポイントから収集  
デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする

##### Grafana Dashboard

TBD

| メトリクス  |                           | USE x RED | Prometheus |
| ----------- | ------------------------- | --------- | ---------- |
| Leader      | Leader 変更回数           |           |            |
| Database 系 | DB サイズ                 |           |            |
|             | Disk 同期レイテンシ       |           |            |
|             | Disk 操作 (fsync, commit) |           |            |
| Network     | Client Trafic             |           |            |
|             | Peer Trafic               |           |            |
|             | Raft Proposal             |           |            |
|             | Proposal Committed        |           |            |
|             | Proposal Pending          |           |            |
|             | grpc                      |           |            |
| snapshot    | snapshot レイテンシ       |

##### Grafana Dashboard

#### kube-scheduler

##### Grafana Dashboard

TBD

| メトリクス |                               | USE x RED | Prometheus |
| ---------- | ----------------------------- | --------- | ---------- |
| Scheduling | Scheduling レート             |           |            |
|            | Scheduling レイテンシ         |           |            |
| kube-api   | kube-api リクエストレート     |           |            |
|            | kube-api リクエストレイテンシ |           |            |
| リソース   | メモリ使用量                  |           |            |
|            | CPU 使用量                    |           |            |
|            | Go routine                    |           |            |
| Leader     | Leader 変更回数               |

#### kube-proxy

kube-proxy の metrics エンドポイントから収集  
デフォルトでエンドポイントを公開しないコンポーネントの場合、--bind-address フラグを使用して有効にする

##### Grafana Dashboard

TBD

| メトリクス          |                                | USE x RED | Prometheus |
| ------------------- | ------------------------------ | --------- | ---------- |
| Proxy ルール Sync   | Proxy ルール Sync レート       | R         |            |
|                     | Proxy ルール Sync レイテンシ   | D         |            |
| Network Programming | Network Programming レート     | R         |            |
|                     | Network Programming レイテンシ | D         |            |
| kube-api            | kube-api リクエストレート      |           |            |
|                     | kube-api リクエストレイテンシ  |           |            |
| リソース            | メモリ使用量                   |           |            |
|                     | CPU 使用量                     |           |            |
|                     | Go routine                     |

#### kubelet

各ノードの 10255 ポート

##### Grafana Dashboard

https://github.com/kashinoki38/prometheus-sample-yaml/blob/master/grafana/kubelet-dashboard.json

| メトリクス                               |                                                                                                                                                                                                                | USE x RED    | Prometheus |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ---------- |
| インスタンス                             | kubelet インスタンスの数                                                                                                                                                                                       | Availability | o          |
|                                          | ボリュームの数                                                                                                                                                                                                 | Availability | o          |
| error                                    | error                                                                                                                                                                                                          | E            | o          |
| オペレーション                           | 各タイプのランタイムオペレーションの総数                                                                                                                                                                       | U            | o          |
|                                          | オペレーションのエラーの数<br/>※コンテナランタイムの問題など、ノード内の低レベルの問題を示す良い指標                                                                                                           | E            | o          |
|                                          | オペレーションの間隔時間                                                                                                                                                                                       | S            | o          |
| Pod の管理                               | ポッドのスタートレートと間隔時間<br/>コンテナのランタイムまたはイメージへのアクセスの問題を示している可能性がある                                                                                              | S            | o          |
|                                          | ポッドスタートオペレーションの数                                                                                                                                                                               | U            | o          |
| ストレージ                               | ストレージオペレーション数                                                                                                                                                                                     | U            | o          |
|                                          | ストレージオペレーションエラー                                                                                                                                                                                 | E            | o          |
|                                          | ストレージオペレーション時間                                                                                                                                                                                   | S            | o          |
| Cgroup マネージャ                        | Cgroup マネージャのオペレーション数                                                                                                                                                                            | U            | o          |
|                                          | Cgroup マネージャのオペレーション時間                                                                                                                                                                          | S            | o          |
| ポッドライフサイクルイベントジェネレータ | ポッドライフサイクルイベントジェネレーター（PLEG）：<br/>relist レート、relist インターバル、relist 間隔時間。これらの値のエラーまたは過度の遅延は、ポッドの Kubernetes ステータスに問題を引き起こす可能性があ | U            | o          |

#### Prometheus

##### Grafana Dashboard
