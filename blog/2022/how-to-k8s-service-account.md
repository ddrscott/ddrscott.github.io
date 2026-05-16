---
title: "How to use Kubernetes Namespaces and Service Accounts for Fun and Profit"
date: 2022-01-01
created: 2022-01-01T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
prompt: "Import from blog post: 2022/how-to-k8s-service-account.md"
---

# How to use Kubernetes Namespaces and Service Accounts for Fun and Profit

We'll create a namespace named `funland` and show how to use a token to access it.

## Create a Namespace

```sh
kubectl create namespace funland
```

## Create a Service Account

This creates a new service account, an "owner" role, and assigns the owner to the new service account _and_ to the `default`
service account.

```sh
kubectl -n funland apply -f- <<YAML
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: funland-sa
  namespace: funland
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: funland-owner
  namespace: funland
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: funland-binding
  namespace: funland
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: funland-owner
subjects:
- kind: ServiceAccount
  name: default
  namespace: funland
- kind: ServiceAccount
  name: funland-sa
  namespace: funland
YAML
```

## Get the token for the team

```sh
# Step by Step
SECRET_NAME=$(kubectl -n funland get secrets | awk '/funland-sa/ {print $1}')

TOKEN=$(kubectl -n funland get secrets ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 --decode)

# ** OR ** All at once
TOKEN=$(kubectl -n funland get secrets $(kubectl -n funland get secrets | awk '/funland-sa/ {print $1}') -o jsonpath='{.data.token}' | base64 --decode)
```

## Use the Token from another host
The `$TOKEN` variable is confidential and should be treated with care.
Transfer it carefully to the target client or user.

```sh
kubectl config set-credentials funland-sa --token="${TOKEN}"
kubectl config set-cluster funland --server=https://1.2.3.4 --insecure-skip-tls-verify
kubectl config set-context funland --user funland-sa --cluster funland --namespace=funland
kubectl config use-context funland

```


## Take it for a Spins

Verify it has nothing installed

    kubectl get all

Check the weather from inside namespace

    kubectl run weather --rm -it --restart='Never' --image curlimages/curl -- wttr.in


## Add Certificate Authority

Get `certificate-authority-data` from the `cluster` entry for the target server.

```sh
kubectl config view --flatten --minify
```

Edit `~/.kube/config` and replace `insecure-skip-tls-verify` with the `certificate-authority-data` from the previous step.

We could use the `--certificate` option in `kubectl config set-cluster`, but we find this is easier than juggling
additional variables.

Here is the `kubectl config set-cluster` method:

```sh
kubectl config set-cluster funland --server=https://1.2.3.4 --certificate-authority="${CERT_CA_DATA}"
```

## Cleanup


```sh
kubectl delete namespace funland

kubectl config delete-context funland

kubectl config delete-cluster funland

kubectl config delete-user funland-sa
```
