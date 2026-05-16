---
title: "How to Setup Airflow in its own Kubernetes namespace using Helm"
date: 2022-01-01
created: 2022-01-01T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
prompt: "Import from blog post: 2022/how-to-airflow-with-helm.md"
---

# How to Setup Airflow in its own Kubernetes namespace using Helm


Create a Helm values file to contain settings specific to your needs.
The main settings we listed demonstrate a few things:

1. pull dags from a git repository
2. enable Airflow API endpoints
3. enable Airflow to use KubernetesPodOperator on itself
4. use simple database setup
5. disable Redis and enable KubernetesExecutor

```yaml
git:
  dags:
    enabled: true
    repositories:
      - repository: https://ro_user:seeeecret@bitbucket.org/some-project/dags-repo.git
        name: some-project
        branch: main

scheduler:
  extraEnvVars:
  - name: PYTHONPATH
    value: /opt/bitnami/airflow/dags/git_some-project/dags

web:
  extraEnvVars:
  - name: PYTHONPATH
    value: /opt/bitnami/airflow/dags/git_some-project/dags
  - name: AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX
    value: "True"
  - name: AIRFLOW_BASE_URL
    value: https://airflow.example.com
  - name: AIRFLOW__API__AUTH_BACKEND
    value: "airflow.api.auth.backend.default"
  - name: AIRFLOW__API__ENABLE_EXPERIMENTAL_API
    value: "True"

worker:
  extraEnvVars:
  - name: PYTHONPATH
    value: /opt/bitnami/airflow/dags/git_some-project/dags

# begin https://artifacthub.io/packages/helm/bitnami/airflow#kubernetesexecutor
executor: KubernetesExecutor
redis:
  endable: false
serviceAccount:
  create: true
rbac:
  create: true
# end   https://artifacthub.io/packages/helm/bitnami/airflow#kubernetesexecutor

postgresql:
  # standalone is default, but its nice to call it out in case we forget.
  architecture: standalone
```

Install it using Helm

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm upgrade --install --namespace funland \
    airflow bitnami/airflow                \
    --version 12.0.14                      \
    --values deploy/h2m-airflow-prod.yml
```

Get the admin password

```sh
echo $(kubectl get secret --namespace "ilabs" airflow -o jsonpath="{.data.airflow-password}" | base64 --decode)
```



## References

- https://docs.bitnami.com/kubernetes/infrastructure/apache-airflow/
- https://artifacthub.io/packages/helm/bitnami/airflow