# 02. AWS EC2 (Elastic Compute Cloud) - Compute

## Overview

Amazon Elastic Compute Cloud (Amazon EC2) provides scalable computing capacity in the AWS Cloud. It eliminates the need to invest in physical hardware upfront, allowing you to develop, deploy, and scale applications faster through secure, resizable virtual servers known as **EC2 Instances**.

```text
               +-------------------------------------------------------------+
               |                  Amazon EC2 Architecture                    |
               +-------------------------------------------------------------+
               |                                                             |
               |   AMI (OS, Software, Config)                                |
               |      │                                                      |
               |      ▼                                                      |
               |   +-----------------------------------------------------+   |
               |   |            EC2 Instance (e.g., t3.micro)            |   |
               |   |  - CPU & RAM (Instance Type)                        |   |
               |   |  - Private IP (VPC internal)                        |   |
               |   |  - Public IP / Elastic IP (External)                |   |
               |   +-----------------------------------------------------+   |
               |      │                           │                          |
               |      ▼                           ▼                          |
               |   +-------------------+      +---------------------------+  |
               |   |  Security Group   |      |  EBS Volume (gp3 / io2)   |  |
               |   |  (Virtual Fire-   |      |  - Persistent Storage     |  |
               |   |   wall at ENI)    |      |  - OS Root & Data Disks   |  |
               |   +-------------------+      +---------------------------+  |
               |                                                             |
               +-------------------------------------------------------------+
```

---

## 1. What is EC2?

- **Definition**: Amazon EC2 is an **Infrastructure as a Service (IaaS)** solution providing on-demand, resizable compute virtual servers (instances) running on top of AWS Nitro or Xen hypervisors.
- **Elasticity**: Quickly scale capacity up or down within minutes to handle traffic spikes or scale down to save costs.
- **Pay-as-you-go**: Pay only for the compute time you consume, billed per-second or per-hour depending on instance type and OS.
- **Purchasing Options**:
  - **On-Demand**: Maximum flexibility, pay by the second/hour without long-term commitment.
  - **Savings Plans / Reserved Instances (RI)**: Up to 72% discount in exchange for a 1-year or 3-year commitment.
  - **Spot Instances**: Spare AWS capacity at up to 90% discount, subject to 2-minute termination warnings when AWS needs capacity back.
  - **Dedicated Hosts / Dedicated Instances**: Physical servers dedicated entirely to your account for compliance or licensing.

---

## 2. AMI (Amazon Machine Image)

An **AMI** is a pre-configured template that contains the software configuration (operating system, application server, and applications) required to launch an instance.

```text
               +-----------------------------------------------+
               |                 AMI Template                  |
               |  - OS: Ubuntu 24.04 / Amazon Linux 2023       |
               |  - Pre-installed runtime (Node.js, Docker)    |
               |  - Root volume block device mapping           |
               +-----------------------------------------------+
                                      │
                   Launch Multiple Identical Instances
                   ┌──────────────────┼──────────────────┐
                   ▼                  ▼                  ▼
             [EC2 Instance 1]   [EC2 Instance 2]   [EC2 Instance 3]
```

### Sources of AMIs:
- **AWS Quick Start AMIs**: Official base images maintained by AWS (Amazon Linux 2023, Ubuntu, Red Hat, Debian, Windows Server).
- **Custom AMIs (Golden Images)**: Created from your own configured EC2 instance, packaging customized security hardening, monitoring agents, and baseline code for instant deployment.
- **AWS Marketplace**: Commercial software images pre-packaged by third-party vendors (e.g., Cisco, Fortinet, WordPress, OpenVPN).
- **Community AMIs**: Publicly shared AMIs created by the global AWS community.

---

## 3. Instance Types

AWS categorizes EC2 instances into families optimized for different workloads. The naming convention describes the instance specification:

```text
                         t3.xlarge
                         ─── ──────
                          │    │
  Family & Generation ────┘    └──── Size (vCPUs, Memory, Network Bandwidth)
  t  = General purpose burstable
  3  = 3rd generation
  x  = extra
  large = 4 vCPUs, 16 GiB Memory
```

### Major Instance Families:

| Family | Name | Characteristics | Typical Workloads |
|---|---|---|---|
| **General Purpose** | `t3`, `t4g`, `m6i`, `m7g` | Balanced ratio of compute, memory, and networking | Web servers, small databases, code repositories, microservices |
| **Compute Optimized** | `c6i`, `c7g`, `c7i` | High compute-to-memory ratio, high-performance processors | Batch processing, scientific modeling, media transcoding, machine learning inference |
| **Memory Optimized** | `r6i`, `r7g`, `x2idn` | High memory capacity per vCPU | In-memory caches (Redis, Memcached), high-performance relational/NoSQL databases |
| **Storage Optimized** | `i3en`, `i4i`, `d3` | Ultra-fast local NVMe SSD storage with high sequential read/writes | Data warehousing (Cassandra, Elasticsearch), distributed file systems, Kafka clusters |
| **Accelerated Computing** | `p4d`, `p5`, `g5`, `trn1` | Dedicated GPUs or AWS custom silicon (Trainium, Inferentia) | Deep learning model training/inference, graphics rendering, genomic analysis |

### Burstable Instances (`t` family) & CPU Credits:
- Burstable instances provide a baseline level of CPU performance with the ability to burst above the baseline when needed.
- While running below baseline, the instance accumulates **CPU credits**; during traffic spikes, it spends credits to sustain 100% CPU utilization.

---

## 4. Key Pairs

A **Key Pair** consists of a **public key** that AWS stores on the instance (in `~/.ssh/authorized_keys`) and a **private key** file (`.pem` or `.ppk`) that you securely retain on your local machine.

### Accessing EC2 Instances:
- **Linux Instances (SSH)**:
  ```bash
  chmod 400 my-key.pem
  ssh -i my-key.pem ec2-user@<public-ip>
  ```
- **Windows Instances (RDP)**: Use the private key to decrypt the initial Administrator password via the AWS Console or CLI, then connect using Remote Desktop.
- **Modern Best Practice - AWS Systems Manager (SSM) Session Manager**:
  - Connect securely to instances directly from the browser or AWS CLI **without needing an SSH key pair**, without opening inbound port 22 in security groups, and without public IP addresses. Every command session is logged to S3 and CloudWatch for compliance.

---

## 5. Security Groups

A **Security Group** acts as a virtual firewall for your EC2 instance to control inbound and outbound network traffic at the Elastic Network Interface (ENI) level.

```text
               Inbound Traffic                       Outbound Traffic
               (e.g., HTTP :80, SSH :22)              (e.g., All traffic)
                         │                                     ▲
                         ▼                                     │
               +-------------------------------------------------------+
               |                  Security Group                       |
               |  - STATEFUL: Return traffic is automatically allowed  |
               |  - Default: DENY all Inbound, ALLOW all Outbound     |
               |  - Rules can reference CIDRs or other Security Groups |
               +-------------------------------------------------------+
                                           │
                                           ▼
                                    [EC2 Instance]
```

### Key Rules and Characteristics:
- **Stateful**: If you send an outbound request from your instance, the response traffic for that request is allowed in regardless of inbound security group rules. Similarly, responses to incoming requests are allowed out.
- **Allow Rules Only**: You cannot create explicit deny rules in a Security Group (Network ACLs handle explicit deny rules).
- **Security Group Chaining**: You can specify another Security Group ID as a traffic source/destination (e.g., allow port 3306 on the database instance *only* from the web server security group).

---

## 6. EBS (Elastic Block Store)

Amazon EBS provides persistent block-level storage volumes for use with EC2 instances. Unlike local disks, EBS volumes behave like raw, unformatted physical hard drives connected over a dedicated high-speed network.

### EBS vs. Instance Store:
- **EBS (Persistent)**: Data persists independently of the lifecycle of the EC2 instance. You can detach an EBS volume from one instance and attach it to another in the same Availability Zone. Supports point-in-time **snapshots** saved to Amazon S3.
- **Instance Store (Ephemeral)**: Physical disks directly attached to the host computer. Offers ultra-low latency and very high IOPS, but **data is lost** if the instance is stopped or terminated. Ideal for temporary swap files, caches, and scratch data.

### EBS Volume Types:

| Volume Type | API Name | Use Case | Max Throughput / IOPS |
|---|---|---|---|
| **General Purpose SSD** | `gp3` | Baseline for most workloads (OS root, dev, test, web servers) | 3,000 IOPS baseline (scale to 16,000), 125–1,000 MB/s |
| **Provisioned IOPS SSD** | `io2` / `io2 Block Express` | Mission-critical low-latency databases (Oracle, SAP HANA) | Up to 256,000 IOPS, sub-millisecond latency |
| **Throughput Optimized HDD** | `st1` | Big data, data warehouses, log processing | 500 MB/s throughput, sequential I/O |
| **Cold HDD** | `sc1` | Infrequently accessed large datasets | Lowest cost per GB |

---

## 7. Public vs. Private IP Addresses

| Feature | Private IPv4 | Public IPv4 | Elastic IP (EIP) |
|---|---|---|---|
| **Scope** | VPC internal only | Accessible over Internet | Accessible over Internet |
| **Persistence** | Retained for lifetime of the instance/ENI | **Lost** when instance is stopped or restarted | **Static**; remains assigned until manually released |
| **Cost** | Free | AWS charges a small fee per hour for all public IPv4 addresses | Free when attached to a running instance; charged when idle |
| **DNS Name** | Private DNS within VPC | Public DNS (resolves to public IP externally, private IP internally) | Can be linked to Route 53 domain name |

---

## 8. EC2 Instance Lifecycle

An EC2 instance transitions through several distinct states from launch to deletion:

```text
                  +-------------------+
                  |      pending      | <── Launch Instance
                  +-------------------+
                            │
                            ▼
                  +-------------------+
            ┌───> |      running      | <── Start
            │     +-------------------+
            │        │             │
      Start │   Stop │             │ Terminate
            │        ▼             │
            │     +-------------------+
            └──── |      stopped      |
                  +-------------------+
                            │
                  Terminate │
                            ▼
                  +-------------------+
                  |  shutting-down    |
                  +-------------------+
                            │
                            ▼
                  +-------------------+
                  |    terminated     |
                  +-------------------+
```

### State Breakdown & Billing:
1. **pending**: Instance is being prepared and provisioned on physical hardware. (No billing)
2. **running**: Instance is fully operational. Compute charges and EBS storage charges accrue.
3. **stopping / stopped**: Instance OS is shut down. **Compute charges stop immediately**. EBS volumes remain attached and continue to be billed for storage space.
4. **shutting-down / terminated**: Instance is permanently removed. The root EBS volume is deleted by default (unless `DeleteOnTermination` is set to `false`). All compute billing ceases.
5. **Reboot**: Keeps the same public and private IP addresses, stays on the same physical host, and does not trigger a new billing hour.

---

## 9. Common Use Cases

1. **Scalable Web Applications**:
   - Running web servers (Nginx/Apache) inside an **Auto Scaling Group (ASG)** behind an **Application Load Balancer (ALB)**, automatically scaling EC2 instances up or down based on CPU or request count.
2. **Microservices Hosting**:
   - Containerized workloads running Docker or Kubernetes (Amazon EKS worker nodes) on compute-optimized or general-purpose EC2 instances.
3. **Batch Processing & Data Pipelines**:
   - Processing large-scale workloads (video rendering, genomic processing, ETL jobs) using **Spot Instances** to reduce operational computing costs by up to 90%.
4. **Enterprise Databases & Applications**:
   - Hosting enterprise ERP systems (SAP, Microsoft SharePoint) and custom databases requiring specialized operating systems, specific kernel tuning, or root-level host access.
