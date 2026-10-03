# 04. AWS VPC (Virtual Private Cloud) - Networking

## Overview

Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

```text
               +-------------------------------------------------------------------------------+
               |                           AWS Region (e.g., us-east-1)                        |
               |                                                                               |
               |   VPC (CIDR: 10.0.0.0/16)                                                     |
               |   Internet Gateway (IGW) ◄═══════════════════════════════════════► Internet    |
               |         │                                                                     |
               |         ▼                                                                     |
               |   +───────────────────────────────────+   +───────────────────────────────────+   |
               |   | Availability Zone A (us-east-1a)  |   | Availability Zone B (us-east-1b)  |   |
               |   |                                   |   |                                   |   |
               |   |  Public Subnet (10.0.1.0/24)      |   |  Public Subnet (10.0.2.0/24)      |   |
               |   |  Route: 0.0.0.0/0 -> IGW          |   |  Route: 0.0.0.0/0 -> IGW          |   |
               |   |  ┌─────────────────────────────┐  |   |  ┌─────────────────────────────┐  |   |
               |   |  │ ALB / NAT Gateway (EIP)     │  |   |  │ ALB / NAT Gateway (EIP)     │  |   |
               |   |  └──────────────┬──────────────┘  |   |  └──────────────┬──────────────┘  |   |
               |   |                 │ Outbound        |   |                 │ Outbound        |   |
               |   |                 ▼ Traffic         |   |                 ▼ Traffic         |   |
               |   |  Private Subnet (10.0.11.0/24)    |   |  Private Subnet (10.0.12.0/24)    |   |
               |   |  Route: 0.0.0.0/0 -> NAT Gateway  |   |  Route: 0.0.0.0/0 -> NAT Gateway  |   |
               |   |  ┌─────────────────────────────┐  |   |  ┌─────────────────────────────┐  |   |
               |   |  │ EC2 App / Backend Service   │  |   |  │ EC2 App / Backend Service   │  |   |
               |   |  └─────────────────────────────┘  |   |  └─────────────────────────────┘  |   |
               |   |                                   |   |                                   |   |
               |   |  Database Subnet (10.0.21.0/24)   |   |  Database Subnet (10.0.22.0/24)   |   |
               |   |  Route: Local Only (Isolated)     |   |  Route: Local Only (Isolated)     |   |
               |   |  ┌─────────────────────────────┐  |   |  ┌─────────────────────────────┐  |   |
               |   |  │ RDS Primary Instance        │══╡═══│ RDS Standby (Multi-AZ) │  |   |
               |   |  └─────────────────────────────┘  |   |  └─────────────────────────────┘  |   |
               |   +───────────────────────────────────+   +───────────────────────────────────+   |
               +-------------------------------------------------------------------------------+
```

---

## 1. What is VPC?

- **Definition**: An Amazon VPC is a logically isolated virtual network dedicated to your AWS account. You have full control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.
- **Scope**: A VPC is bound to a single **AWS Region** and spans across all Availability Zones (AZs) in that Region.
- **Default vs. Custom VPC**:
  - **Default VPC**: Created automatically in every AWS Region for every account. Includes a public subnet in each AZ with pre-attached Internet Gateway and public IPv4 addressing enabled by default.
  - **Custom VPC**: Built from scratch tailored for production workloads, establishing strict network boundaries between public-facing tiers, application compute, and private database tiers.

---

## 2. CIDR (Classless Inter-Domain Routing)

VPC IP addressing is defined using IPv4 CIDR blocks (e.g., `10.0.0.0/16`).

### Understanding CIDR Notation:
- The `/16` represents the network prefix (the number of fixed bits in the 32-bit IPv4 address).
- Total available addresses = $2^{(32 - \text{prefix})}$.
- `10.0.0.0/16` provides $2^{16} = 65,536$ total IP addresses.
- `10.0.1.0/24` provides $2^8 = 256$ total IP addresses.

### AWS Reserved IP Addresses (5 per Subnet):
In every AWS subnet, AWS automatically reserves **5 IP addresses** which cannot be assigned to any resource. For example, in a `10.0.0.0/24` subnet (256 theoretical IPs, 251 usable IPs):
1. `10.0.0.0`: **Network address**.
2. `10.0.0.1`: Reserved by AWS for the **VPC default router**.
3. `10.0.0.2`: Reserved by AWS for **DNS resolution** (AmazonProvidedDNS).
4. `10.0.0.3`: Reserved by AWS for **future use**.
5. `10.0.0.255`: **Network broadcast address** (AWS does not support broadcast, but reserves the IP).

---

## 3. Subnets

A **Subnet** is a segment or sub-range of IP addresses defined within a VPC.

### Core Rules:
- Each subnet must reside entirely within a **single Availability Zone** (cannot span multiple AZs).
- Subnet CIDR blocks cannot overlap with any other subnet in the VPC.
- Instances launched inside a subnet receive a private IP from that subnet's range.

---

## 4. Route Tables

A **Route Table** contains a set of rules (called routes) that determine where network traffic from your subnet or gateway is directed.

```text
+-------------------+--------------------+-------------------------------------------+
| Destination CIDR  | Target             | Meaning                                   |
+-------------------+--------------------+-------------------------------------------+
| 10.0.0.0/16       | local              | Internal VPC communication (always on)    |
| 0.0.0.0/0         | igw-0a1b2c3d4e5f   | Outbound traffic sent to Internet Gateway |
+-------------------+--------------------+-------------------------------------------+
```

### Characteristics:
- **Main Route Table**: Created automatically when a VPC is created. Associated with subnets by default unless explicitly associated with a custom route table.
- **Custom Route Table**: Created explicitly to route traffic for specific subnets (e.g., a Public Route Table pointing `0.0.0.0/0` to an Internet Gateway).
- **Subnet Association**: Every subnet must be associated with exactly one route table at a time. Multiple subnets can share the same route table.

---

## 5. Internet Gateway (IGW)

An **Internet Gateway** is a horizontally scaled, redundant, and highly available VPC component that enables communication between resources in your VPC and the external internet.

### How It Works:
- Does not impose any bandwidth availability risks or single points of failure.
- Provides a target in your VPC route tables for internet-routable traffic (via `0.0.0.0/0`).
- Performs **Network Address Translation (1:1 NAT)** for instances that have been assigned public IPv4 addresses, mapping their private IP to public IP seamlessly.
- Limit: Exactly **one Internet Gateway** can be attached to a VPC at a time.

---

## 6. NAT Gateway (Network Address Translation)

A **NAT Gateway** enables instances in a **private subnet** to connect to services outside your VPC (e.g., downloading software updates, Docker images, security patches) while preventing the external internet from establishing inbound connections to those private instances.

```text
               Internet (OS updates, yum, apt)
                             ▲
                             │ (Outbound only)
                   [ Internet Gateway ]
                             ▲
                             │
               Public Subnet │
                   [ NAT Gateway (Elastic IP) ]
                             ▲
                             │ (0.0.0.0/0 routed via NAT Gateway)
               Private Subnet│
                   [ EC2 Private Instance ]
```

### Key Properties:
- Must be deployed in a **public subnet**.
- Requires an **Elastic IP (EIP)** address.
- Managed service by AWS: scales automatically up to 45 Gbps of bandwidth.
- **High Availability**: A NAT Gateway is redundant within an Availability Zone. For multi-AZ fault tolerance, deploy a separate NAT Gateway in each AZ's public subnet and associate each private subnet with its local AZ's NAT Gateway.

---

## 7. Security Groups vs. Network ACLs (NACLs)

Understanding the distinction between Security Groups and Network ACLs is critical for AWS networking defense-in-depth:

```text
                     Incoming Request from Internet
                                   │
                                   ▼
                  +---------------------------------+
                  |      Network ACL (NACL)         |  ◄── Subnet Level Firewall
                  |  - Stateless                    |
                  |  - Processed in numerical order |
                  |  - Explicit ALLOW & DENY        |
                  +---------------------------------+
                                   │
                                   ▼
                  +---------------------------------+
                  |       Security Group            |  ◄── Instance / ENI Level Firewall
                  |  - Stateful                     |
                  |  - Evaluates all rules          |
                  |  - Explicit ALLOW only          |
                  +---------------------------------+
                                   │
                                   ▼
                            [ EC2 Instance ]
```

### Detailed Comparison:

| Feature | Security Group (SG) | Network ACL (NACL) |
|---|---|---|
| **Level of Operation** | Instance / ENI (Elastic Network Interface) | Subnet boundary |
| **State** | **Stateful**: Return traffic is automatically allowed regardless of inbound rules | **Stateless**: Return traffic must be explicitly allowed by outbound rules |
| **Rule Types** | **ALLOW rules only** (everything else denied) | Both **ALLOW and DENY rules** supported |
| **Rule Order** | All rules evaluated together | Evaluated in **numerical order** (lowest number first, e.g., 100, 200) |
| **Applicability** | Applies only to instances explicitly assigned the security group | Automatically applies to all traffic entering or leaving the subnet |
| **Ephemeral Ports** | Handled automatically due to stateful tracking | Must explicitly open outbound ephemeral ports (1024–65535) for client traffic |

---

## 8. Public vs. Private Subnet

| Dimension | Public Subnet | Private Subnet |
|---|---|---|
| **Definition** | A subnet whose route table directs default internet traffic (`0.0.0.0/0`) to an **Internet Gateway (IGW)** | A subnet whose route table does NOT direct internet traffic to an IGW (routes through a **NAT Gateway** or local only) |
| **Internet Accessibility** | Resources can be accessed directly from the public internet if assigned a Public IP | Resources **cannot** be accessed directly from the public internet |
| **Outbound Internet Access** | Directly via Internet Gateway | Indirectly via NAT Gateway located in a public subnet |
| **Typical Resources Hosted** | - Application Load Balancers (ALBs)<br>- NAT Gateways<br>- Bastion / Jump Hosts | - Application / Backend Web Servers<br>- Microservices / EKS Pods<br>- Relational Databases (RDS, Aurora)<br>- Cache Clusters (ElastiCache) |
| **Security Posture** | Exposed to internet-facing scan attempts; protected by Security Groups | Fully isolated; zero direct public exposure |

---

## 9. Common Architectural Patterns

1. **Standard 3-Tier Web Architecture**:
   - **Public Subnet (Web / Ingress Tier)**: Application Load Balancers and NAT Gateways.
   - **Private Subnet (Application Tier)**: Auto-scaling EC2 instances running application code, receiving traffic only from the ALB.
   - **Isolated Database Subnet (Data Tier)**: Multi-AZ Amazon RDS or Aurora database instances with route tables that only have `local` routes.
2. **VPC Peering**:
   - Connecting two VPCs directly using private IP addresses as if they were in the same network, without traffic traversing the public internet.
3. **VPC Endpoints (AWS PrivateLink)**:
   - Accessing AWS services (like S3 or DynamoDB) privately from within your VPC without using an Internet Gateway or NAT Gateway, saving bandwidth costs and improving security posture.
