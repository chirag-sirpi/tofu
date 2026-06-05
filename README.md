<img src="https://cdn.prod.website-files.com/677c400686e724409a5a7409/6790ad949cf622dc8dcd9fe4_nextwork-logo-leather.svg" alt="NextWork" width="300" />

# Production DevSecOps Pipeline on GKE

**Project Link:** [View Project](https://learn.nextwork.org/projects/467554e5-3aec-45c4-8b5b-8ba8e1042ae0)

**Author:** Chirag S Kotian  
**Email:** ckotian117@gmail.com

---

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_adch8lq5)

## Project Overview: Building a Production-Grade DevSecOps Platform

### What this project proves

In this project, I'm building a production-grade DevSecOps platform on Google Kubernetes Engine (GKE) featuring a Python Flask microservice, Jenkins CI/CD, ArgoCD GitOps, Istio service mesh, and Prometheus/Grafana observability, which covers the entire software delivery lifecycle from infrastructure provisioning with OpenTofu and Ansible to automated security scanning and runtime security monitoring. This proves I can secure and automate cloud-native application delivery, implement automated security gates (SAST/DAST/SCA) that block vulnerable deployments, enforce Kubernetes security policies, detect runtime anomalies, and correlate security alerts with metrics in real-time.

## Provisioning Cloud Infrastructure with OpenTofu

### Infrastructure as Code approach

In this step, I'm provisioning a virtual private cloud (VPC) network, a secure Google Kubernetes Engine (GKE) cluster using spot nodes for cost savings, an Artifact Registry repository for container images, and IAM service accounts with least-privilege access using OpenTofu, so that I can establish a secure, isolated, and cost-effective cloud infrastructure to deploy and run the DevSecOps platform and its microservices.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_finlrju1)

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_s5iahvpw)

## Bootstrapping the Cluster with Ansible

### Automated cluster configuration

In this step, I'm setting up all required platform tools—including Jenkins for CI/CD, ArgoCD for GitOps CD, Istio Service Mesh for networking, Kyverno for policy enforcement, Falco for runtime threat detection, and the Prometheus/Grafana stack for monitoring—using an automated Ansible playbook with Helm, so that I can bootstrap the entire GKE cluster with a single, reproducible command rather than executing multiple manual Helm installs.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_ys264to6)

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_5svwrjdt)

### ArgoCD version details

I used the ArgoCD Helm chart version `9.5.17`, which bundles ArgoCD version `v3.4.3`.

## Building and Containerizing the Flask Microservice

### Microservice design and goals

In this step, I'm building a Python Flask microservice instrumented with Prometheus metrics, containerizing it using a multi-stage Dockerfile with a secure, non-root alpine base, and pushing the image to GCP Artifact Registry, so that I can run a secure, light-weight, and observable web service monitored by the platform.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_rnwpqy0q)

### Dockerfile security best practices

1. Multi-Stage Build: Dependencies are compiled in a temporary builder stage, and only the final runtime artifacts are copied to the minimal execution stage. This excludes build tools (like `gcc`, `musl-dev`) from the final image, significantly reducing the attack surface.
2. Non-Root Execution: A custom non-privileged user and group (`appuser:appgroup`) are created to run the application process instead of default `root`. This prevents container breakouts from acquiring root privileges on the GKE host nodes.
3. Minimal Base Image:Using a Python Alpine base (`python:3.12-alpine`) keeps the image footprint small and reduces the presence of unnecessary system packages and potential CVEs.

## Implementing the Jenkins CI/CD Pipeline with Security Gates

### Pipeline architecture

In this step, I'm setting up an automated Jenkins CI/CD pipeline integrated with static application security testing (SAST) and container vulnerability scanning, so that I can automatically build, scan, and safely deploy the Flask microservice to GKE only when all security gates successfully pass.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_q24npbq9)

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_91h1m6fm)

### Security gate enforcement

If Trivy finds a CRITICAL vulnerability, it exits with a non-zero exit code (`--exit-code 1`), causing the Trivy Container Scan stage to fail. This halts the pipeline execution immediately, preventing the subsequent Push Image and ArgoCD GitOps Trigger stages from running, thereby blocking the vulnerable image from being deployed to the production environment.

## Integrating SAST, Container Scanning, and DAST

### Multi-layer security scanning strategy

In this step, I'm configuring three automated security scanning layers—SonarQube for SAST, Trivy for container scanning, and OWASP ZAP for DAST dynamic scanning—so that the pipeline automatically halts and blocks vulnerable deployments to production if any high or critical severity issues are detected.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_lskacj6p)

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_yzotnwq9)

## GitOps Deployment with ArgoCD Auto-Sync and Drift Detection

### GitOps workflow design

In this step, I'm defining the application's desired state using declarative Kubernetes manifests (Deployment, Service, HorizontalPodAutoscaler, and PodDisruptionBudget) in a Git repository, and configuring an ArgoCD Application with automated sync and self-healing, so that I can implement a continuous delivery (CD) pipeline where the cluster automatically self-corrects from configuration drift and ensures high availability.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_8qqrzodt)

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_gvrzh5d2)

### Drift detection in action

I observed that ArgoCD detected the drift and immediately triggered a self-heal operation. The replica count returned to 2 in the cluster to match the desired state defined in the Git repository without any human intervention.


## Securing Service Communication with Istio mTLS

### Service mesh configuration goals

In this step, I'm configuring an Istio Service Mesh by enabling sidecar injection on the application namespace, enforcing strict mutual TLS (mTLS) for encrypted service-to-service communication, and defining traffic rules with retry policies and circuit breakers, so that my application can benefit from secure, resilient, and observable network communication.


![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_zx8q3heg)

### How strict mTLS protects the application

Strict mTLS mode ensures that all communication to and from the Flask application is encrypted in transit and requires both the client and server to authenticate each other using mutually validated cryptographically secure certificates, thereby blocking any unencrypted plain-text traffic or unauthorized service access in the cluster.

## Exposing the Application via NGINX Ingress with Rate Limiting

### Ingress controller setup

In this step, I'm deploying an NGINX Ingress Controller via Helm and configuring an Ingress resource with rate-limiting annotations (`limit-rps: 10`) to expose the Flask microservice through a public LoadBalancer IP, so that I can provide a single external entry point with built-in abuse protection that throttles excessive requests at the edge before they reach the application pods.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_ovd2hpv8)

### Rate limiting and DDoS protection

I used the annotation nginx.ingress.kubernetes.io/limit-rps: "10", which limits each client IP to 10 requests per second (with a burst allowance of 50), to protect against DoS attacks, brute-force attempts, and resource exhaustion on the Flask pods.

## Enforcing Security Policies with Kyverno

### Policy as Code approach

In this step, I'm deploying four Kyverno ClusterPolicies in `Enforce` mode—requiring non-root user execution, disallowing privileged containers, mandating CPU and memory resource limits, and restricting image pulls to approved registries—so that the Kubernetes admission controller automatically blocks any workload that violates these security baselines before it is ever scheduled.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_3x7vlbid)

### Three policies and what they enforce

The Kyverno admission webhook immediately denied the request. It returned four distinct policy violation errors: 
(1) `disallow-privileged-containers` blocked the privileged security context, 
(2) `require-non-root-user` blocked the missing `runAsNonRoot: true`, 
(3) `require-resource-limits` blocked the missing CPU/memory limits, and 
(4) `restrict-image-registries` blocked the `nginx` image because `docker.io` was not in the allowed registry list for the `flask-app` namespace. The pod was never created.

## Detecting Runtime Threats with Falco

### Runtime security monitoring goals

In this step, I'm deploying Falco as a DaemonSet for real-time kernel-level system call monitoring, defining custom detection rules for suspicious container activity (shell spawning, unauthorized file writes), and forwarding alerts to Falcosidekick UI for centralized visualization, so that I can detect and respond to runtime threats like container breakouts, reverse shells, and unauthorized file modifications in real-time.

### Custom Falco rule design

Falco detects multiple categories of runtime security events in the cluster: 
(1) Unexpected K8S API Server connections from containers (rule: `Contact K8S API Server From Container`), flagging when application containers make direct API server calls which could indicate credential theft or lateral movement, 
(2) STDOUT/STDIN redirection to network connections (rule: `Redirect STDOUT/STDIN to Network Connection in Container`), detecting potential reverse shell activity, and
(3) custom rules defined in the `falco-custom-rules` ConfigMap for detecting terminal shell spawning inside containers and unauthorized file writes under `/app/`, both of which are strong indicators of container compromise in a production environment.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_hxa1uul2)

### Incident investigation data

A Falco alert provides comprehensive forensic information extracted directly from kernel-level system calls and Kubernetes API context, which is critical for security investigations:
1. Event Meta-information: Exact timestamp of the event, the severity/priority level (e.g., `WARNING`, `CRITICAL`), and the matched signature rule name (e.g., `Terminal shell in container`).
2. Process Execution Details: The name of the process that triggered the event (`proc.name`, e.g., `sh`), the exact command line arguments used (`proc.cmdline`, e.g., `sh -c ls /app`), and the parent process name (`proc.pname`, e.g., `gunicorn` or `containerd-shim`), which traces the execution hierarchy.
3. Container Context: The container ID (`container.id`), container name (`container.name`), and container image repository/tag, confirming exactly which container was targeted.
4. Kubernetes Cluster Context: The Kubernetes namespace (`k8s.ns.name=flask-app`), pod name (`k8s.pod.name`), and associated la

## Observability with Prometheus and Grafana RED Metrics

### Monitoring stack setup

In this step, I'm establishing comprehensive observability for the Flask application using Prometheus and Grafana. I connect Prometheus to scrape the Flask microservice metrics by applying a custom ServiceMonitor resource, import a custom Grafana dashboard displaying the RED metrics (Request rate, Error rate, Duration) and correlating them with Falco runtime security events, and deploy a custom PrometheusRule alerting resource (`FlaskHighErrorRate`) to automatically alert when error rates spike. This correlation lets operations and security teams monitor application health and detect if security incidents (like shell spawning or brute-force attacks) are causing performance degradation or service outages in real-time.

### PromQL expressions and alerting rules

1. PromQL Expression for Error Rate Panel:
   
sum(rate(http_requests_total{status=~"5.."}[5m])) by (status, endpoint)
  
 Explanation: This expression calculates the per-second rate of HTTP requests returning a server error status code (matching regex `5..` such as 500, 503) over a rolling 5-minute window (`[5m]`) using the `rate()` function, and then groups and aggregates the rates using `sum() by (status, endpoint)` to display the total error rate per endpoint and status code.

2. The `for: 5m` Clause in the PrometheusRule:
   The `for: 5m` clause specifies the time duration that the alert condition (e.g., error rate > 5%) must continuously remain active (true) before transitioning from `pending` to the `firing` state in Alertmanager. This prevents transient network spikes, temporary pod restarts, or short-lived traffic spikes from triggering loud, false-positive alerts, ensuring notifications are only sent for persistent, sustained incidents.

## Self-Healing and Auto-Scaling Under Load

### Resilience configuration goals

In this step, I'm verifying the self-healing and auto-scaling capabilities of the microservice deployment in GKE to ensure operational resilience. I check that ArgoCD automatically self-heals the deployment by reverting manual changes back to the Git-defined configuration, confirm that the liveness and readiness probes restart unhealthy containers, and run a CPU load test to observe the Horizontal Pod Autoscaler (HPA) scale the replica count up dynamically from 2 to 4 in real-time as CPU utilization crosses the 80% threshold.

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_kcaqkiaq)

### How HPA, PDB, and probes work together

Scale-down takes longer because the Horizontal Pod Autoscaler (HPA) has a default downscale stabilization window of 300 seconds (5 minutes). This stabilization window prevents "flapping," where the replica count rapidly bounces up and down during bursty or transient traffic spikes. On the other hand, the scale-up stabilization window is 0 seconds by default, allowing Kubernetes to respond immediately to load increases and prevent application performance degradation.

## Secret Mission: Correlating Security Alerts with Application Metrics

![Image](https://learn.nextwork.org/encouraged_cyan_heroic_salamander/uploads/467554e5-3aec-45c4-8b5b-8ba8e1042ae0_5oso0vqn)

### Reducing false positives with combined alerting

A combined alert rule requires both a runtime anomaly (like a Falco shell spawn) and application-level impact (elevated 5xx error rate) to trigger simultaneously, reducing false positives:

1.Alerting on Falco alone creates noise from routine, authorized tasks (e.g., developers or sysadmins running debug shells inside containers).

2.Alerting on error rate alone triggers false alarms during transient network drops, external dependency downtime, or benign traffic surges. By correlating both signals, the combined rule ensures alerts only fire when a runtime security event directly causes application disruption, confirming a successful exploit or active compromise rather than background noise.

## Reflections and Lessons Learned

### Key tools and concepts mastered

Key tools used: OpenTofu (infrastructure provisioning), Ansible (automated configuration), Jenkins (CI/CD pipelines), SonarQube (SAST), Trivy (dependency & container scanning), OWASP ZAP (DAST), ArgoCD (GitOps CD), Istio (service mesh), Kyverno (admission control policies), Falco & Falcosidekick (runtime security), and Prometheus/Grafana (observability).

Key concepts learned:
1. Infrastructure-as-Code (IaC) for secure cloud network and GKE cluster design.
2. GitOps workflows for self-healing, declarative continuous deployment.
3. DevSecOps integration: automated static analysis (SAST), software composition analysis (SCA), and dynamic scanning (DAST) in a release pipeline.
4. Least-privilege container virtualization: non-root executions, minimal base images, and strict Kyverno security policies.
5. Service Mesh topology: enforcing strict mTLS communication and path-level overrides.
6. Runtime security: system call monitoring, anomaly detection, and correlation metrics.

### Time and challenges

This project took approximately 12 hours to complete.
The most challenging part was resolving network connectivity issues between the GMP Prometheus scraper (running outside the service mesh) and the Flask application sidecar (enforcing strict mTLS in the mesh). Configuring a pod-level permissive mTLS selector for port 5000 in PeerAuthentication was critical to solve this. Another major challenge was scoping the Kyverno require-non-root-user policy to prevent it from blocking third-party system components (like Grafana, Prometheus Operator, or Falco) in other namespaces while strictly enforcing security boundaries on the Flask app.


I completed this project to learn how to design, implement, and operate a secure, highly available, and observable cloud-native DevSecOps platform on Google Kubernetes Engine. It allowed me to bridge the gap between infrastructure automation, automated pipeline security gates, service mesh policy control, and real-time security observability.

Another skill I want to learn is cloud-native security orchestration, specifically automated incident response playbooks (SOAR) that automatically isolate or restart pods in response to high-severity Falco runtime alerts.


---

*Built with [NextWork](https://learn.nextwork.org) - [View this project](https://learn.nextwork.org/projects/467554e5-3aec-45c4-8b5b-8ba8e1042ae0)*
