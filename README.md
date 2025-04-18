# Tender Trap Infrastructure

> Secure AWS Infrastructure as Code with Terraform, 1Password, and direnv  
> **Private honeynet research project**

---

## 🚀 Overview

This repository defines a minimal yet secure AWS infrastructure using [Terraform](https://www.terraform.io/), built for experimentation with honeynets and network monitoring.

It provisions:
- A custom **VPC** with public/private subnets
- A **NAT Gateway** and **Internet Gateway**
- **EC2 Instances**:
  - `tender-honeypot`: public-facing instance
  - `tender-monitor`: private instance with outbound-only internet
- **Security Groups** and **Network ACLs** to restrict and control traffic
- Route tables, tags, and outputs for future automation

---

## 🔐 Secret Management

This project is designed to keep **all secrets out of version control**. Credentials and API tokens are pulled securely from [1Password](https://1password.com/dev/) using the CLI (`op`).

Example `.envrc` file available in commit.

---

## ⚙️ Prerequisites

Make sure you have the following tools installed:

- [`op`](https://developer.1password.com/docs/cli/) (1Password CLI)
- [`direnv`](https://direnv.net/)
- [`Terraform`](https://developer.hashicorp.com/terraform/downloads)
- [`AWS CLI`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (optional for debugging)

---

## 🧠 How It Works

1. **direnv** loads the `.envrc` which fetches secrets securely from 1Password.
2. Terraform CLI initializes the project and authenticates using:
   - A **Terraform Cloud token** for remote state
   - An **AWS IAM key pair** for resource provisioning
3. Resources are provisioned in **eu-north-1** (`Stockholm`) with clearly tagged assets and a modular structure.
4. **Private EC2 instances** access the internet via the NAT Gateway.

---

## 🗂 Project Structure

```text
.
├── .envrc                # NOT committed — loads secrets from 1Password
├── .gitignore
├── terraform.tfvars      # Defines per-project input variables
├── 100_provider.tf
├── 110_variables.tf
├── 120_tags.tf
├── 130_vpc.tf
├── 140_security.tf
├── 150_instances.tf
├── 180_outputs.tf
├── terraform.lock.hcl
```

---

## 🛡 Security Best Practices

- NACLs configured with **explicit ephemeral port ranges** for return traffic
- SGs follow a **deny-all except explicitly allowed** policy
- Public route tables and default behaviors are **overridden manually** or tagged
- SSH Agent Forwarding used for hopping from the public honeypot to the private monitor (via trusted local key)

---

## 📝 Future Plans

- Add CloudWatch monitoring
- Automate instance hardening
- Export logs to a hardened S3 bucket
- Consider VPN or SSM tunnel access instead of SSH

---

## 📜 License

Private research project. No license yet — not intended for public use at this stage.

