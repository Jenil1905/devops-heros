# 05. AWS Database Services: DynamoDB & RDS

## Overview

AWS provides purpose-built database engines designed for distinct data access patterns, scalability requirements, and consistency models. The two primary managed database services in AWS are:
- **Amazon DynamoDB**: A fully managed, serverless NoSQL key-value and document database offering single-digit millisecond performance at any scale.
- **Amazon RDS (Relational Database Service)**: A managed relational database service supporting industry-standard SQL engines with automated provisioning, patching, backup, and high-availability failover.

```text
+----------------------------------------------------+  +----------------------------------------------------+
|                Amazon DynamoDB                     |  |                    Amazon RDS                      |
|                (Serverless NoSQL)                  |  |                (Managed Relational)                |
+----------------------------------------------------+  +----------------------------------------------------+
|  - Key-Value & Document model                      |  |  - Relational SQL engines (PostgreSQL, MySQL...)   |
|  - Massive horizontal auto-partitioning            |  |  - Vertical scaling (Instance type) + Read Replicas|
|  - Predictable single-digit millisecond latency    |  |  - Strict ACID transactions & complex joins        |
|  - Schema-less attributes                          |  |  - Fixed schema with foreign keys                  |
|  - On-Demand or Provisioned Capacity               |  |  - Multi-AZ synchronous replication failover       |
+----------------------------------------------------+  +----------------------------------------------------+
```

---

# Part 1: Amazon DynamoDB

## 1. NoSQL Architecture

- **Definition**: DynamoDB is a fully managed, multi-Region, multi-Active distributed NoSQL database.
- **Serverless**: No servers to manage, patch, or monitor. Capacity scales automatically up or down based on incoming request traffic.
- **Horizontal Scaling**: Automatically spreads data and throughput over an arbitrary number of internal physical storage servers (partitions) using SSD storage.
- **Single-Digit Millisecond Latency**: Delivers consistent sub-10 millisecond response times regardless of whether the table contains 100 items or 100 billion items.

---

## 2. Core Concepts: Tables, Items, and Attributes

```text
Table: "Users"
+---------------------------+-------------------+----------------------------+-----------------------------+
| Partition Key (UserID)    | Sort Key (Date)   | Attribute (Email)          | Attribute (Preferences)     |
+---------------------------+-------------------+----------------------------+-----------------------------+
| "usr-101" (String)        | "2026-10-01"      | "alice@example.com"        | {"theme": "dark"}           |
| "usr-101" (String)        | "2026-10-02"      | "alice@example.com"        | {"theme": "light"}          |
| "usr-102" (String)        | "2026-10-01"      | "bob@example.com"          | {"notifications": true}     |
+---------------------------+-------------------+----------------------------+-----------------------------+
 ◄──────── Item 1 ──────────────────────────────►
```

### Breakdown:
- **Table**: A collection of data items (equivalent to a relational table or MongoDB collection).
- **Item**: A group of attributes uniquely identifiable among all other items (equivalent to a row, record, or document). Maximum item size is **400 KB** (including attribute names and values).
- **Attributes**: A fundamental data element, requiring no pre-definition beyond the primary key. Attributes can be scalar (String, Number, Binary, Boolean, Null), complex documents (List, Map), or sets (String Set, Number Set).
- **Schemaless**: Except for the required primary key attributes, items in the same table do not need to share the same attributes or data structures.

---

## 3. Primary Keys: Partition Key & Sort Key

Every DynamoDB table requires a primary key defined at table creation time to uniquely locate items across storage partitions.

### A. Simple Primary Key (Partition Key Only)
- Composed of a single attribute known as the **Partition Key (PK)** or **Hash Key**.
- DynamoDB passes the partition key value into an internal hash function to determine the exact physical storage partition where the item is stored.
- No two items can share the same partition key.

### B. Composite Primary Key (Partition Key + Sort Key)
- Composed of two attributes: **Partition Key (PK)** and **Sort Key (SK)** (also known as a **Range Key**).
- Items with the same partition key are stored physically together in sorted order by their sort key.
- Two items can have the same partition key, as long as their sort keys are distinct.
- Enables rich query capabilities:
  - Find all orders for user `usr-101`.
  - Find all orders for user `usr-101` where `OrderDate BETWEEN '2026-01-01' AND '2026-06-30'`.
  - Find all events starting with prefix `SK begins_with('LOGIN#')`.

```text
                    Partition Key (PK) Value
                              │
                              ▼
                     Internal Hash Function
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
       Partition 1       Partition 2      Partition 3
      [ PK = "US" ]     [ PK = "UK" ]    [ PK = "IN" ]
       Sorted by SK      Sorted by SK     Sorted by SK
```

---

## 4. Secondary Indexes

- **Global Secondary Index (GSI)**: An index with a partition key and sort key that can be different from those on the base table. Can be created at any time and spans across all partitions.
- **Local Secondary Index (LSI)**: An index that has the same partition key as the base table, but a different sort key. Must be created at table creation time.

---

## 5. Capacity Modes

1. **On-Demand Capacity Mode**:
   - Pay per request for read and write requests.
   - Automatically adapts to unpredictable spikes in traffic without capacity planning.
2. **Provisioned Capacity Mode**:
   - You specify Read Capacity Units (RCUs) and Write Capacity Units (WCUs).
   - Auto-scaling automatically adjusts provisioned capacity based on target utilization.
   - Offers lower cost for steady, predictable workloads.

---

## 6. DynamoDB Use Cases

- **User Session Stores & Shopping Carts**: High-throughput, sub-millisecond key-value lookups for web and mobile e-commerce platforms.
- **Real-Time Gaming Leaderboards**: Tracking and updating player scores, game state, and inventories with high write velocity.
- **IoT Sensor Telemetry**: Ingesting massive time-series event streams using device ID as partition key and timestamp as sort key.
- **Serverless Microservices**: Direct native integration with **AWS Lambda** and **Amazon API Gateway** with zero connection pooling limits.

---

# Part 2: Amazon RDS (Relational Database Service)

## 1. What is Amazon RDS?

- **Definition**: Amazon RDS is a fully managed service that makes it easy to set up, operate, and scale a relational database in the AWS cloud.
- **Automated Administration**: Handles complex time-consuming administrative tasks such as hardware provisioning, database setup, patching, backups, failure detection, and recovery.
- **Relational Integrity**: Supports full SQL capabilities, ACID (Atomicity, Consistency, Isolation, Durability) transactions, foreign key constraints, and relational joins.

---

## 2. Supported Database Engines

AWS RDS supports six major relational database engines:

1. **Amazon Aurora**: AWS-native cloud-optimized relational database compatible with PostgreSQL and MySQL. Delivers up to 5x throughput of standard MySQL and 3x of standard PostgreSQL, with distributed storage auto-scaling up to 128 TiB.
2. **PostgreSQL**: Popular open-source object-relational database.
3. **MySQL**: Widely-used open-source relational database.
4. **MariaDB**: Community-developed fork of MySQL.
5. **Oracle Database**: Enterprise database (Enterprise Edition, Standard Edition Two) under "Bring Your Own License" (BYOL) or "License Included".
6. **Microsoft SQL Server**: Enterprise Windows-based relational database (Express, Web, Standard, Enterprise).

---

## 3. DB Instances

A **DB Instance** is an isolated database environment in the cloud. It contains one or more user-created databases.

### Instance Classes:
- **General Purpose (`db.m6g`, `db.m6i`)**: Balanced compute and memory for typical business applications.
- **Memory Optimized (`db.r6g`, `db.r6i`, `db.x2g`)**: Heavy caching and large in-memory data processing.
- **Burstable (`db.t3`, `db.t4g`)**: Cost-effective for dev, test, and small staging databases.

---

## 4. Security

- **Network Isolation**: DB instances must run inside a private subnet of an Amazon VPC, unreachable directly from the public internet.
- **Security Groups**: Firewall rules restrict database port access (e.g., PostgreSQL port `5432` or MySQL port `3306`) exclusively to approved application server security groups.
- **Encryption at Rest**: Managed through **AWS KMS** (AES-256), encrypting DB instance storage, automated backups, read replicas, and snapshots.
- **Encryption in Transit**: Enforced using SSL/TLS connections for all client-to-database communications.
- **IAM Database Authentication**: Authenticate database users using IAM users and roles without database passwords.

---

## 5. Backups and Recovery

1. **Automated Backups**:
   - Continuous backup of transaction logs and full daily storage snapshots.
   - Configurable retention period between **1 and 35 days**.
   - Enables **Point-in-Time Recovery (PITR)** down to any specific second within the retention window.
2. **Manual DB Snapshots**:
   - User-initiated snapshots of the entire DB instance.
   - Retained indefinitely until manually deleted, even if the source DB instance is deleted.

---

## 6. Multi-AZ Deployments (High Availability)

**Multi-AZ** provides enterprise-grade high availability and automated failover for production databases.

```text
               +───────────────────────────────────────────────────────────────+
               |                           Amazon RDS                          |
               |                                                               |
               |   Availability Zone A                 Availability Zone B     |
               |   +──────────────────────────+        +─────────────────────+ |
               |   |   Primary DB Instance    |        | Standby DB Instance | |
               |   |   (Read / Write)         |        | (Inactive / Warm)   | |
               |   +────────────┬─────────────+        +──────────▲──────────+ |
               |                │                                 │            |
               |                └────── Synchronous Replication ──┘            |
               +───────────────────────────────────────────────────────────────+
                                                │
                                    Automatic Failover (< 60s)
                                      DNS Endpoint updated
```

### How It Works:
- Synchronously replicates data to a standby instance in a different Availability Zone within the same Region.
- In the event of planned maintenance, OS patching, or hardware failure on the primary, RDS automatically triggers failover to the standby in **under 60 seconds**.
- The database connection endpoint DNS string remains unchanged; RDS simply points the DNS record to the standby instance.
- **Note**: Standby instances in standard Multi-AZ cannot serve read traffic (for active read offloading, use Read Replicas or Multi-AZ DB clusters).

---

## 7. Read Replicas (Scalability)

A **Read Replica** is an asynchronous copy of the primary DB instance used to offload read-heavy workloads.

```text
                                [ Primary DB Instance ]
                                (Master - Handles WRITES)
                                            │
                                            │ Asynchronous Replication
                         ┌──────────────────┴──────────────────┐
                         ▼                                     ▼
               [ Read Replica 1 ]                    [ Read Replica 2 ]
               (Handles Read Traffic)                (Handles BI / Reporting)
```

### Characteristics:
- Uses database engine native **asynchronous replication**.
- Up to **5 read replicas** per RDS DB instance (up to **15** in Amazon Aurora).
- Each read replica has its own dedicated DNS connection string.
- Can be located in the **same AZ**, a **different AZ**, or even a **different AWS Region** (Cross-Region Read Replica for global low latency and disaster recovery).
- Can be promoted to an independent standalone read/write database if needed.

---

## 8. RDS Use Cases

- **Enterprise Applications (ERP, CRM)**: Systems requiring strict transactional guarantees, complex entity relationships, and enterprise compliance.
- **E-Commerce Transaction Engines**: Order management, payment processing, inventory tracking requiring immediate consistency and ACID compliance.
- **Complex Reporting & BI**: SQL queries requiring heavy aggregation (`GROUP BY`), multi-table relational `JOIN` operations, and historical reporting.

---

# Part 3: DynamoDB vs. RDS Feature Comparison

| Feature | Amazon DynamoDB | Amazon RDS |
|---|---|---|
| **Data Model** | NoSQL (Key-Value / Document) | Relational (SQL Tables, Rows, Columns) |
| **Schema** | Dynamic / Schemaless (flexible attributes) | Fixed schema (ALTER TABLE required) |
| **Scaling** | **Horizontal** (Auto-partitioning to limitless scale) | **Vertical** (scale compute/storage) + Read Replicas |
| **Latency** | Consistent **Single-digit milliseconds** | 5–20 milliseconds (variable under load) |
| **Transactions** | ACID supported via `TransactWriteItems` | Full native ACID across complex multi-table queries |
| **Complex Joins** | Not supported (denormalized data model) | Fully supported via standard SQL `JOIN` syntax |
| **High Availability** | Built-in Multi-AZ replication by default | Configured via **Multi-AZ synchronous standby** |
| **Pricing Model** | On-Demand (per request) or Provisioned (RCU/WCU) | Instance hours + allocated EBS storage volume |
| **Maintenance** | Zero maintenance / Serverless | Managed maintenance windows (engine patches) |
| **Connection Limits** | HTTP/HTTPS API (No connection pool bottlenecks) | Connection limits based on database RAM and max_connections |
