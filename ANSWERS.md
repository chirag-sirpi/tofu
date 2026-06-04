# Project Questions and Answers

## Step 0: Before We Start

### Question: What are we doing in this project?
**Answer:**
In this project, I'm building a production-grade DevSecOps platform on Google Kubernetes Engine (GKE) featuring a Python Flask microservice, Jenkins CI/CD, ArgoCD GitOps, Istio service mesh, and Prometheus/Grafana observability, which covers the entire software delivery lifecycle from infrastructure provisioning with OpenTofu and Ansible to automated security scanning and runtime security monitoring. This proves I can secure and automate cloud-native application delivery, implement automated security gates (SAST/DAST/SCA) that block vulnerable deployments, enforce Kubernetes security policies, detect runtime anomalies, and correlate security alerts with metrics in real-time.

---

## Step 1: Provision GKE Infrastructure with OpenTofu

### Question: What are we doing in this step?
**Answer:**
In this step, I'm provisioning a virtual private cloud (VPC) network, a secure Google Kubernetes Engine (GKE) cluster using spot nodes for cost savings, an Artifact Registry repository for container images, and IAM service accounts with least-privilege access using OpenTofu, so that I can establish a secure, isolated, and cost-effective cloud infrastructure to deploy and run the DevSecOps platform and its microservices.

---

## Step 2: Bootstrap Cluster with Ansible

### Question: What are we doing in this step?
**Answer:**
In this step, I'm setting up all required platform tools—including Jenkins for CI/CD, ArgoCD for GitOps CD, Istio Service Mesh for networking, Kyverno for policy enforcement, Falco for runtime threat detection, and the Prometheus/Grafana stack for monitoring—using an automated Ansible playbook with Helm, so that I can bootstrap the entire GKE cluster with a single, reproducible command rather than executing multiple manual Helm installs.

### Question: Which Helm chart version did you use for ArgoCD, and what version of ArgoCD does it bundle?
**Answer:**
I used the ArgoCD Helm chart version `9.5.17`, which bundles ArgoCD version `v3.4.3`.

---

## Step 3: Build the Flask Microservice

### Question: What are we doing in this step?
**Answer:**
In this step, I'm building a Python Flask microservice instrumented with Prometheus metrics, containerizing it using a multi-stage Dockerfile with a secure, non-root alpine base, and pushing the image to GCP Artifact Registry, so that I can run a secure, light-weight, and observable web service monitored by the platform.

### Question: What security practices did you apply in the Dockerfile and why do they matter?
**Answer:**
1. **Multi-Stage Build:** Dependencies are compiled in a temporary builder stage, and only the final runtime artifacts are copied to the minimal execution stage. This excludes build tools (like `gcc`, `musl-dev`) from the final image, significantly reducing the attack surface.
2. **Non-Root Execution:** A custom non-privileged user and group (`appuser:appgroup`) are created to run the application process instead of default `root`. This prevents container breakouts from acquiring root privileges on the GKE host nodes.
3. **Minimal Base Image:** Using a Python Alpine base (`python:3.12-alpine`) keeps the image footprint small and reduces the presence of unnecessary system packages and potential CVEs.

---

## Step 4: Set Up Jenkins CI/CD Pipeline

### Question: What are we doing in this step?
**Answer:**
In this step, I'm setting up an automated Jenkins CI/CD pipeline integrated with static application security testing (SAST) and container vulnerability scanning, so that I can automatically build, scan, and safely deploy the Flask microservice to GKE only when all security gates successfully pass.

### Question: What happens if the Trivy container scan finds a CRITICAL vulnerability in your image?
**Answer:**
If Trivy finds a CRITICAL vulnerability, it exits with a non-zero exit code (`--exit-code 1`), causing the Trivy Container Scan stage to fail. This halts the pipeline execution immediately, preventing the subsequent Push Image and ArgoCD GitOps Trigger stages from running, thereby blocking the vulnerable image from being deployed to the production environment.

---

## Step 5: Integrate Security Scanning

### Question: What are we doing in this step?
**Answer:**
In this step, I'm configuring three automated security scanning layers—SonarQube for SAST, Trivy for container scanning, and OWASP ZAP for DAST dynamic scanning—so that the pipeline automatically halts and blocks vulnerable deployments to production if any high or critical severity issues are detected.

---

## Step 6: Deploy with ArgoCD GitOps

### Question: What are we doing in this step?
**Answer:**
In this step, I'm defining the application's desired state using declarative Kubernetes manifests (Deployment, Service, HorizontalPodAutoscaler, and PodDisruptionBudget) in a Git repository, and configuring an ArgoCD Application with automated sync and self-healing, so that I can implement a continuous delivery (CD) pipeline where the cluster automatically self-corrects from configuration drift and ensures high availability.

### Question: What happened when you manually scaled the deployment to 4 replicas?
**Answer:**
I observed that ArgoCD detected the drift and immediately triggered a self-heal operation. The replica count returned to 2 in the cluster to match the desired state defined in the Git repository without any human intervention.

---

## Step 7: Configure Istio Service Mesh

### Question: What are we doing in this step?
**Answer:**
In this step, I'm configuring an Istio Service Mesh by enabling sidecar injection on the application namespace, enforcing strict mutual TLS (mTLS) for encrypted service-to-service communication, and defining traffic rules with retry policies and circuit breakers, so that my application can benefit from secure, resilient, and observable network communication.