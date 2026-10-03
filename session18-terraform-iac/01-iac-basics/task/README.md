# Task 2: AWS Services Research

This document contains research and documentation on core Amazon Web Services (AWS) infrastructure components, covering architecture, security, lifecycle, networking, compute, storage, and databases.

---

## Deliverables Directory Structure

```text
session18-terraform-iac/01-iac-basics/task/
├── README.md                          # Master overview and research index
└── aws-services/
    ├── 01-iam/
    │   └── README.md                  # IAM: Governance, Users, Groups, Roles, Policies, Best Practices
    ├── 02-ec2/
    │   └── README.md                  # EC2: Compute, AMIs, Instance Types, EBS, Security Groups, Lifecycle
    ├── 03-s3/
    │   └── README.md                  # S3: Object Storage, Buckets, Storage Classes, Versioning, Encryption
    ├── 04-vpc/
    │   └── README.md                  # VPC: Networking, CIDR, Subnets, Route Tables, IGW, NAT Gateway, NACLs
    └── 05-dynamodb-rds/
        └── README.md                  # Databases: DynamoDB (NoSQL) & RDS (Relational), Multi-AZ, Replicas
```

---

## Service Navigation Links

| Service | Category | Focus Area | Detailed Documentation |
|---|---|---|---|
| **01. IAM** | Governance & Security | Identity, Access Control, Least Privilege, Policies | [01-iam/README.md](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/01-iam/README.md) |
| **02. EC2** | Compute | Virtual Machines, AMIs, Storage, Firewalls, Lifecycle | [02-ec2/README.md](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/02-ec2/README.md) |
| **03. S3** | Object Storage | Scalable Storage, Versioning, Encryption, Lifecycles | [03-s3/README.md](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/03-s3/README.md) |
| **04. VPC** | Networking | Virtual Networks, Subnets, Route Tables, NAT, Security | [04-vpc/README.md](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/04-vpc/README.md) |
| **05. DynamoDB & RDS** | Database Services | NoSQL vs. Relational, Multi-AZ, Read Replicas, Scaling | [05-dynamodb-rds/README.md](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/05-dynamodb-rds/README.md) |

---

## Global AWS Architecture Overview

The following diagram illustrates how these core AWS services integrate in an enterprise 3-tier production architecture:

```text
+---------------------------------------------------------------------------------------------------------+
|                                              AWS Cloud                                                  |
|                                                                                                         |
|   +---------------------------------------+                                                             |
|   |         AWS IAM & Governance          | ──► Governs access to all resources & API calls             |
|   | (Roles, Policies, Least Privilege)    |                                                             |
|   +---------------------------------------+                                                             |
|                                                                                                         |
|   +-------------------------------------------------------------------------------------------------+   |
|   |  Virtual Private Cloud (VPC: 10.0.0.0/16)                                                       |   |
|   |  Internet Gateway (IGW) ◄══════════════════════════════════════════════════════════► Internet    |   |
|   |                                                                                                 |   |
|   |  +───────────────────────────────────────────────────+   +───────────────────────────────────+  |   |
|   |  | Availability Zone A                               |   | Availability Zone B               |  |   |
|   |  |                                                   |   |                                   |  |   |
|   |  | [Public Subnet - 10.0.1.0/24]                     |   | [Public Subnet - 10.0.2.0/24]     |  |   |
|   |  |  - Application Load Balancer (ALB)                |   |  - Application Load Balancer      |  |   |
|   |  |  - NAT Gateway (Elastic IP)                       |   |  - NAT Gateway (Elastic IP)       |  |   |
|   |  +─────────────────────────┬─────────────────────────+   +─────────────────┬─────────────────+  |   |
|   |                            │                                               │                    |   |
|   |  +─────────────────────────▼─────────────────────────+   +─────────────────▼─────────────────+  |   |
|   |  | [Private Subnet - 10.0.11.0/24]                   |   | [Private Subnet - 10.0.12.0/24]   |  |   |
|   |  |  - EC2 Application Instances (ASG)                |   |  - EC2 Application Instances (ASG)|  |   |
|   |  |  - Attached EBS Volumes (gp3)                     |   |  - Attached EBS Volumes (gp3)     |  |   |
|   |  |  - IAM Instance Profile (Access S3 / DynamoDB)    |   |  - IAM Instance Profile           |  |   |
|   |  +─────────────────────────┬─────────────────────────+   +─────────────────┬─────────────────+  |   |
|   |                            │                                               │                    |   |
|   |  +─────────────────────────▼─────────────────────────+   +─────────────────▼─────────────────+  |   |
|   |  | [Database Subnet - 10.0.21.0/24]                  |   | [Database Subnet - 10.0.22.0/24]  |  |   |
|   |  |  - RDS Primary DB Instance (Multi-AZ)             |═══╡  - RDS Standby / Read Replica     |  |   |
|   |  +───────────────────────────────────────────────────+   +───────────────────────────────────+  |   |
|   +-------------------------------------------------------------------------------------------------+   |
|                                │                                               │                        |
|                                ▼                                               ▼                        |
|   +------------------------------------------------------+   +--------------------------------------+   |
|   |                  Amazon S3 Bucket                    |   |           Amazon DynamoDB            |   |
|   |  - Static Assets, Backups, Data Lake                 |   |  - Real-Time User Sessions & State   |   |
|   |  - Server-Side Encryption (KMS) & Versioning         |   |  - Sub-millisecond Key-Value / NoSQL |   |
|   +------------------------------------------------------+   +--------------------------------------+   |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

---

## 01. IAM - Governance Summary

- **What is IAM**: AWS Identity and Access Management is a global, free service controlling authentication (AuthN) and authorization (AuthZ) across AWS.
- **Users**: Unique identities representing human operators or systems with long-term credentials (passwords, access keys).
- **Groups**: Collections of users facilitating bulk policy attachment without managing individual accounts.
- **Roles**: Identities assumed temporarily by users, external entities (OIDC), or services (EC2 instance profiles) issuing short-lived STS tokens.
- **Policies**: Formal JSON documents declaring `Effect` (`Allow`/`Deny`), `Action`, `Resource` (ARN), and `Condition`.
- **Permissions Evaluation**: Explicit Deny overrides all; Explicit Allow overrides default; Default is Implicit Deny.
- **Least Privilege**: Granting strictly the minimum permissions required to perform an action, preventing unauthorized lateral movement.
- **Best Practices**:
  - Enforce Multi-Factor Authentication (MFA) on all accounts.
  - Eliminate root account usage for daily operations.
  - Prefer IAM roles with temporary credentials over static access keys.
  - Regularly audit permissions using AWS CloudTrail and IAM Access Analyzer.
- [Read full IAM documentation](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/01-iam/README.md)

---

## 02. EC2 - Compute Summary

- **What is EC2**: Amazon Elastic Compute Cloud provides on-demand, resizable compute virtual servers (instances).
- **AMI (Amazon Machine Image)**: Pre-configured operating system and application template used to launch instances (AWS Quickstart, Custom Golden Images, Marketplace).
- **Instance Types**: Categorized into families:
  - **General Purpose (`t3`, `m6i`)**: Balanced compute/memory.
  - **Compute Optimized (`c6i`)**: High CPU for batch/compute tasks.
  - **Memory Optimized (`r6i`)**: In-memory databases and caching.
  - **Storage Optimized (`i3en`)**: High IOPS NVMe SSDs.
  - **Accelerated Computing (`p4`, `g5`)**: GPU processing for AI/ML.
- **Key Pairs**: Asymmetric cryptography (public key on instance, private `.pem` key retained by client) for secure SSH and RDP access.
- **Security Groups**: Stateful virtual firewalls operating at the instance Elastic Network Interface (ENI) level, supporting allow rules only.
- **EBS (Elastic Block Store)**: Network-attached persistent block storage (`gp3`, `io2`, `st1`, `sc1`) with snapshot capabilities to S3.
- **Public vs. Private IP**: Private IPs are fixed within the VPC; Public IPs are dynamically re-assigned on instance restarts unless an Elastic IP (EIP) is allocated.
- **Lifecycle**: `pending` ──► `running` ──► `stopping` ──► `stopped` ──► `shutting-down` ──► `terminated`. (Compute billing stops when stopped).
- [Read full EC2 documentation](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/02-ec2/README.md)

---

## 03. S3 - Storage Summary

- **What is S3**: Scalable object storage designed for **99.999999999% (11 9's)** durability, replicating data across at least 3 Availability Zones.
- **Buckets**: Globally unique named containers residing in a specific AWS Region.
- **Objects**: Data files stored as key-value pairs with metadata, version IDs, and sizes up to 5 TB.
- **Storage Classes**:
  - `S3 Standard`: Frequently accessed data.
  - `S3 Intelligent-Tiering`: Automatic tiering with no retrieval fees.
  - `S3 Standard-IA`: Infrequently accessed data (retrieval fee applies).
  - `S3 One Zone-IA`: Single-AZ cost-optimized storage.
  - `S3 Glacier Instant / Flexible / Deep Archive`: Long-term archive from milliseconds to hours.
- **Versioning**: Preserves previous versions of objects; supports recovery from accidental overwrites or deletes using Delete Markers.
- **Lifecycle Policies**: Automated rules to transition data down storage classes and delete expired objects.
- **Encryption**: SSE-S3 (AES-256), SSE-KMS (audited keys), SSE-C (customer-managed), and client-side encryption.
- **Bucket Policies**: Resource-based JSON policies to enforce HTTPS, control cross-account access, and restrict IP origins.
- [Read full S3 documentation](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/03-s3/README.md)

---

## 04. VPC - Networking Summary

- **What is VPC**: A logically isolated virtual network in an AWS Region giving complete control over IP addressing, subnets, and routing.
- **CIDR**: Classless Inter-Domain Routing blocks (e.g., `10.0.0.0/16`). Note that AWS reserves **5 IP addresses** in every subnet.
- **Subnets**: Subdivisions of a VPC tied to a single Availability Zone.
- **Route Tables**: Sets of routing rules directing network traffic to local targets, Internet Gateways, NAT Gateways, or VPC peering.
- **Internet Gateway (IGW)**: Horizontally scaled gateway enabling two-way communication between VPC resources and the internet.
- **NAT Gateway**: Outbound-only gateway deployed in a public subnet with an Elastic IP, enabling instances in private subnets to reach the internet safely.
- **Security Groups vs. NACLs**:
  - **Security Groups**: Stateful, instance-level, allow rules only.
  - **Network ACLs**: Stateless, subnet-level, numbered allow and deny rules.
- **Public vs. Private Subnet**: Public subnets route `0.0.0.0/0` directly to an IGW; private subnets route internet-bound traffic through a NAT Gateway.
- [Read full VPC documentation](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/04-vpc/README.md)

---

## 05. DynamoDB & RDS - Database Services Summary

### DynamoDB (NoSQL)
- Serverless key-value and document database with horizontal auto-partitioning.
- Single-digit millisecond latency at any throughput scale.
- Data model based on **Tables**, **Items** (up to 400 KB), and **Attributes**.
- Primary keys: **Partition Key** (Hash key) alone, or composite with a **Sort Key** (Range key).
- Secondary indexes: **Global Secondary Index (GSI)** and **Local Secondary Index (LSI)**.
- Capacity modes: **On-Demand** (pay-per-request) or **Provisioned** (RCUs/WCUs).

### RDS (Relational Database Service)
- Managed relational database service supporting: **Amazon Aurora, PostgreSQL, MySQL, MariaDB, Oracle, SQL Server**.
- Supports standard SQL schemas, complex joins, and full ACID compliance.
- **Security**: Private subnet isolation, Security Groups, KMS encryption at rest, SSL in transit.
- **Backups**: Continuous automated backups with Point-in-Time Recovery (PITR up to 35 days) + manual snapshots.
- **Multi-AZ**: Synchronous physical replication to a warm standby in a separate AZ with automatic failover in < 60 seconds.
- **Read Replicas**: Asynchronous read-only copies to scale read-heavy applications across AZs or Regions.

### DynamoDB vs. RDS Comparison Matrix
| Feature | Amazon DynamoDB | Amazon RDS |
|---|---|---|
| **Data Model** | NoSQL Key-Value / Document | Relational (Tables, Rows, Columns) |
| **Schema** | Flexible / Schemaless | Fixed, strict SQL schema |
| **Scaling** | Horizontal (Automatic partitioning) | Vertical (Compute/Storage) + Read Replicas |
| **Latency** | Sub-10ms single-digit milliseconds | 5–20ms |
| **Joins** | Not supported (Denormalized) | Fully supported SQL JOINs |
| **High Availability** | Built-in multi-AZ redundancy | Optional Multi-AZ standby deployment |
| **Pricing** | Requests (On-Demand) or RCU/WCU | Hourly instance rate + allocated EBS storage |
- [Read full DynamoDB & RDS documentation](file:///home/jenil/Desktop/Devops-Practice/session18-terraform-iac/01-iac-basics/task/aws-services/05-dynamodb-rds/README.md)
