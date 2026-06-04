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

