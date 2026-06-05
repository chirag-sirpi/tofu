# 🚀 GKE DevSecOps Platform

A production-grade, highly available, and secure DevSecOps platform built on Google Kubernetes Engine (GKE). This project integrates automated infrastructure provisioning, multi-stage CI/CD security gates, GitOps continuous delivery, service mesh networking, admission controller policy enforcement, runtime threat detection, and real-time security observability.

---

## 🏗️ Platform Architecture

```mermaid
graph TD
    User([Public Access]) -->|HTTPS| Ingress[NGINX Ingress Controller]
    subgraph GKE Cluster
        Ingress -->|Rate Limiting| Forwarder[Istio Gateway Forwarder]
        Forwarder -->|HTTP| Gateway[Istio Ingress Gateway]
        
        subgraph Service Mesh (flask-app namespace)
            Gateway -->|Strict mTLS| Sidecar[Istio Proxy Sidecar]
            Sidecar -->|localhost:5000| Flask[Python Flask Microservice]
        end
        
        subgraph Control Plane & Observability
            Prom[Prometheus Operator] -->|Permissive Scrape| Flask
            Prom -->|Scrape| FalcoSide[Falcosidekick Exporter]
            Grafana[Grafana Dashboard] -->|Query| Prom
            Falco[Falco DaemonSet] -->|Syscalls| FalcoSide
            FalcoSide -->|POST Alerts| FalcoUI[Falcosidekick Web UI]
        end
        
        subgraph Policy Enforcement
            Kyverno[Kyverno Admission Controller] -.->|Enforce Security Policies| Flask
        end
    end
    
    subgraph CI/CD & GitOps
        Developer -->|Git Push| GitHub[GitHub Repo]
        Jenkins[Jenkins Pipeline] -->|Pull Code| GitHub
        Jenkins -->|SAST| Sonar[SonarQube]
        Jenkins -->|SCA| Trivy[Trivy File Scanner]
        Jenkins -->|Container Scan| TrivyImg[Trivy Image Scanner]
        Jenkins -->|Push Image| Registry[(Artifact Registry)]
        Argo[ArgoCD GitOps] -->|Sync Manifests| GitHub
        Argo -->|Deploy Workload| GKE
    end
```

---

## 🛠️ Key Components & Technologies

| Layer | Component | Description |
| :--- | :--- | :--- |
| **Infrastructure** | **OpenTofu** | Provisioning Google VPC, secure GKE cluster, subnets, and service accounts. |
| **Configuration** | **Ansible** | Automated Helm-based bootstrapping of all platform tools and services. |
| **CI/CD Pipeline** | **Jenkins** | Orchestrating automated builds, SAST, SCA, and image scanning gates. |
| **Security SAST/SCA** | **SonarQube / Trivy** | Scanning source code, dependencies, and container images before pushing. |
| **GitOps CD** | **ArgoCD** | Declarative GitOps continuous deployment with automated self-healing and sync. |
| **Service Mesh** | **Istio** | Mutual TLS (mTLS) encryption, traffic management, and path routing. |
| **Edge Gateway** | **NGINX Ingress** | LoadBalancer exposure with built-in request rate limiting (10 RPS). |
| **Policy Controller** | **Kyverno** | Webhook validating non-root execution, resource limits, and registry constraints. |
| **Runtime Security** | **Falco** | DaemonSet analyzing system calls to flag shell executions and app directory writes. |
| **Observability** | **Prometheus / Grafana** | Collecting RED metrics and security events to correlate performance with threat profiles. |

---

## 📁 Repository Structure

```text
├── ansible/               # Ansible cluster bootstrapping playbooks
│   └── roles/             # Roles for installing Helm charts (ArgoCD, Istio, Falco, etc.)
├── app/                   # Flask microservice source code
│   ├── app.py             # Python script with Prometheus instrumentation
│   ├── Dockerfile         # Hardened multi-stage non-root container image
│   └── requirements.txt   # Microservice library dependencies
├── k8s/                   # Kubernetes YAML manifests synced via ArgoCD GitOps
│   ├── deployment.yaml    # Flask deployment + ServiceMonitor definitions
│   ├── service.yaml       # Core service exposing Flask pod port
│   ├── ingress.yaml       # NGINX Ingress manifest with rate-limit annotations
│   ├── istio-gateway.yaml # Istio Ingress Gateway exposure configurations
│   ├── kyverno-policy.yaml# Kyverno ClusterPolicies in Enforce mode
│   ├── peerauthentication.yaml # Port-level mTLS rules for Prometheus scraping
│   ├── prometheus-rule.yaml    # Alertmanager rules for Flask high error rates
│   └── falcosidekick-servicemonitor.yaml # ServiceMonitor scraping Falco alerts
├── monitoring/            # Grafana dashboard templates
│   └── grafana-dashboard.json # Templated Security & Performance Correlation JSON
├── opentofu/              # OpenTofu IaC configs for Google Cloud
└── ANSWERS.md             # Detailed lab question writeups (Steps 0 to 12)
```

---

## 🚀 Verification & Manual Testing

### 1. NGINX Ingress & Rate Limiting
Validate the NGINX Ingress controller endpoint:
```bash
curl -i http://34.136.244.197/
```
Generate burst load to trigger a `503 Service Unavailable` response:
```bash
for i in {1..20}; do curl -s -o /dev/null -w "%{http_code}\n" http://34.136.244.197/; done
```

### 2. Kyverno Security Policies
Verify Kyverno is blocking non-compliant pod definitions. Run a privileged pod in the application namespace:
```bash
kubectl run privileged-test --image=nginx --privileged -n flask-app
```
*Expected Result:* Kyverno admission controller webhook rejects the pod creation, listing violations on registry restrictions, resource limits, privileged mode, and root execution.

### 3. Falco Runtime Anomalies
Trigger the custom Falco threat detection rule by executing a shell inside a running Flask pod container:
```bash
kubectl exec -n flask-app <pod-name> -c flask-app -- sh -c "ls /app"
```
Check the alerts instantly in the Falcosidekick Web UI (`http://localhost:2802/`):
*   **Source:** `syscall`
*   **Priority:** `Warning`
*   **Rule:** `Terminal shell in container`

### 4. Horizontal Pod Autoscaler (HPA)
Generate CPU load inside the container to trigger auto-scaling:
```bash
kubectl exec -n flask-app <pod-name> -c flask-app -- sh -c "nohup sh -c 'while true; do true; done' >/dev/null 2>&1 &"
```
Monitor the HPA scaling replicas up from `2` to `4`:
```bash
kubectl get hpa -n flask-app --watch
```
*Cleanup Load:*
```bash
kubectl exec -n flask-app <pod-name> -c flask-app -- killall sh
```
