$ KIALI_USERNAME=$(read -p 'Kiali Username: ' uval && echo -n $uval | base64)
# Kiali Username: admin
$ KIALI_PASSPHRASE=$(read -sp 'Kiali Passphrase: ' pval && echo -n $pval | base64)
# Kiali Passphrase:
$ cat <<EOF | kubectl apply -f - apiVersion: v1 kind: Secret metadata: name: kiali namespace: $NAMESPACE labels: app: kiali type: Opaque data: username: $KIALI_USERNAME passphrase: $KIALI_PASSPHRASE EOF
$ istioctl manifest apply --set values.kiali.enabled=true --set values.tracing.enabled=true