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

### Question: What does strict mTLS mode do for your Flask application?
**Answer:**
Strict mTLS mode ensures that all communication to and from the Flask application is encrypted in transit and requires both the client and server to authenticate each other using mutually validated cryptographically secure certificates, thereby blocking any unencrypted plain-text traffic or unauthorized service access in the cluster.

---

## Step 8: Configure NGINX Ingress with Rate Limiting

### Question: What are we doing in this step?
**Answer:**
In this step, I'm deploying an NGINX Ingress Controller via Helm and configuring an Ingress resource with rate-limiting annotations (`limit-rps: 10`) to expose the Flask microservice through a public LoadBalancer IP, so that I can provide a single external entry point with built-in abuse protection that throttles excessive requests at the edge before they reach the application pods.

### Question: What happens when the rate limit is exceeded?
**Answer:**
When the rate limit of 10 requests per second is exceeded, the NGINX Ingress Controller returns an HTTP 503 Service Unavailable response to the client, effectively throttling excessive traffic at the edge and protecting the backend Flask application pods from being overwhelmed by a flood of requests.

---

## Step 9: Enforce Kyverno Security Policies

### Question: What are we doing in this step?
**Answer:**
In this step, I'm deploying four Kyverno ClusterPolicies in `Enforce` mode—requiring non-root user execution, disallowing privileged containers, mandating CPU and memory resource limits, and restricting image pulls to approved registries—so that the Kubernetes admission controller automatically blocks any workload that violates these security baselines before it is ever scheduled.

### Question: What happened when you tried to create a privileged pod?
**Answer:**
The Kyverno admission webhook immediately denied the request. It returned four distinct policy violation errors: (1) `disallow-privileged-containers` blocked the privileged security context, (2) `require-non-root-user` blocked the missing `runAsNonRoot: true`, (3) `require-resource-limits` blocked the missing CPU/memory limits, and (4) `restrict-image-registries` blocked the `nginx` image because `docker.io` was not in the allowed registry list for the `flask-app` namespace. The pod was never created.

---

## Step 10: Implement Runtime Security with Falco

### Question: What are we doing in this step?
**Answer:**
In this step, I'm deploying Falco as a DaemonSet for real-time kernel-level system call monitoring, defining custom detection rules for suspicious container activity (shell spawning, unauthorized file writes), and forwarding alerts to Falcosidekick UI for centralized visualization, so that I can detect and respond to runtime threats like container breakouts, reverse shells, and unauthorized file modifications in real-time.

### Question: What types of runtime events does Falco detect in your cluster?
**Answer:**
Falco detects multiple categories of runtime security events in the cluster: (1) **Unexpected K8S API Server connections** from containers (rule: `Contact K8S API Server From Container`), flagging when application containers make direct API server calls which could indicate credential theft or lateral movement, (2) **STDOUT/STDIN redirection to network connections** (rule: `Redirect STDOUT/STDIN to Network Connection in Container`), detecting potential reverse shell activity, and (3) custom rules defined in the `falco-custom-rules` ConfigMap for detecting **terminal shell spawning** inside containers and **unauthorized file writes** under `/app/`, both of which are strong indicators of container compromise in a production environment.

### Question: What information does the Falco alert include that would help a security team investigate the incident?
**Answer:**
A Falco alert provides comprehensive forensic information extracted directly from kernel-level system calls and Kubernetes API context, which is critical for security investigations:
1. **Event Meta-information**: Exact timestamp of the event, the severity/priority level (e.g., `WARNING`, `CRITICAL`), and the matched signature rule name (e.g., `Terminal shell in container`).
2. **Process Execution Details**: The name of the process that triggered the event (`proc.name`, e.g., `sh`), the exact command line arguments used (`proc.cmdline`, e.g., `sh -c ls /app`), and the parent process name (`proc.pname`, e.g., `gunicorn` or `containerd-shim`), which traces the execution hierarchy.
3. **Container Context**: The container ID (`container.id`), container name (`container.name`), and container image repository/tag, confirming exactly which container was targeted.
4. **Kubernetes Cluster Context**: The Kubernetes namespace (`k8s.ns.name=flask-app`), pod name (`k8s.pod.name`), and associated labels, helping map the anomaly to a specific service topology.
5. **User Context**: The system UID (`user.uid=1000`) and username (`user.name`), showing if the process executed with root privileges or restricted user context.

---

## Step 11: Monitor with Prometheus and Grafana

### Question: What are we doing in this step?
**Answer:**
In this step, I'm establishing comprehensive observability for the Flask application using Prometheus and Grafana. I connect Prometheus to scrape the Flask microservice metrics by applying a custom ServiceMonitor resource, import a custom Grafana dashboard displaying the RED metrics (Request rate, Error rate, Duration) and correlating them with Falco runtime security events, and deploy a custom PrometheusRule alerting resource (`FlaskHighErrorRate`) to automatically alert when error rates spike. This correlation lets operations and security teams monitor application health and detect if security incidents (like shell spawning or brute-force attacks) are causing performance degradation or service outages in real-time.

### Question: What PromQL expression did you use for the error rate panel, and what does the `for: 5m` clause do in your PrometheusRule?
**Answer:**
1. **PromQL Expression for Error Rate Panel:**
   ```promql
   sum(rate(http_requests_total{status=~"5.."}[5m])) by (status, endpoint)
   ```
   *Explanation:* This expression calculates the per-second rate of HTTP requests returning a server error status code (matching regex `5..` such as 500, 503) over a rolling 5-minute window (`[5m]`) using the `rate()` function, and then groups and aggregates the rates using `sum() by (status, endpoint)` to display the total error rate per endpoint and status code.

2. **The `for: 5m` Clause in the PrometheusRule:**
   The `for: 5m` clause specifies the time duration that the alert condition (e.g., error rate > 5%) must continuously remain active (true) before transitioning from `pending` to the `firing` state in Alertmanager. This prevents transient network spikes, temporary pod restarts, or short-lived traffic spikes from triggering loud, false-positive alerts, ensuring notifications are only sent for persistent, sustained incidents.

---

## Step 12: Configure Self-Healing and Auto-Scaling

### Question: What are we doing in this step?
**Answer:**
In this step, I'm verifying the self-healing and auto-scaling capabilities of the microservice deployment in GKE to ensure operational resilience. I check that ArgoCD automatically self-heals the deployment by reverting manual changes back to the Git-defined configuration, confirm that the liveness and readiness probes restart unhealthy containers, and run a CPU load test to observe the Horizontal Pod Autoscaler (HPA) scale the replica count up dynamically from 2 to 4 in real-time as CPU utilization crosses the 80% threshold.

### Question: Why does scale-down take longer than scale-up?
**Answer:**
Scale-down takes longer because the Horizontal Pod Autoscaler (HPA) has a default downscale stabilization window of 300 seconds (5 minutes). This stabilization window prevents "flapping," where the replica count rapidly bounces up and down during bursty or transient traffic spikes. On the other hand, the scale-up stabilization window is 0 seconds by default, allowing Kubernetes to respond immediately to load increases and prevent application performance degradation.

---

## Secret Mission: Create a Security Correlation Dashboard

### Question: What are we doing in this step?
**Answer:**
In this secret mission, I'm creating a centralized security correlation dashboard in Grafana that displays both application performance metrics (latency, HTTP requests/errors) and runtime security alerts (Falco system events) on the same timeline. I also configure a custom templated variable selector (`$priority`) based on the `priority_raw` label, allowing security analysts to dynamically filter alerts by critical or warning severity tiers across both correlation panels.

### Question: Describe how the combined alert rule reduces false positives compared to alerting on Falco events or error rate alone.
**Answer:**
A combined alert rule requires both a runtime anomaly (like a Falco shell spawn) and application-level impact (elevated 5xx error rate) to trigger simultaneously, reducing false positives:
1. **Alerting on Falco alone** creates noise from routine, authorized tasks (e.g., developers or sysadmins running debug shells inside containers).
2. **Alerting on error rate alone** triggers false alarms during transient network drops, external dependency downtime, or benign traffic surges.
By correlating both signals, the combined rule ensures alerts only fire when a runtime security event directly causes application disruption, confirming a successful exploit or active compromise rather than background noise.