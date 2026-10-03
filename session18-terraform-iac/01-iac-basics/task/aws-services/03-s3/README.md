# 03. AWS S3 (Simple Storage Service) - Storage

## Overview

Amazon Simple Storage Service (Amazon S3) is an industry-leading object storage service offering industry-standard scalability, data availability, security, and performance. S3 is designed to deliver **99.999999999% (11 9's) of durability** and store virtually unlimited amounts of data for a wide range of use cases.

```text
               +-------------------------------------------------------------+
               |                  Amazon S3 Architecture                     |
               +-------------------------------------------------------------+
               |                                                             |
               |  Bucket: my-company-prod-data (Globally Unique Name)         |
               |  Region: us-east-1                                          |
               |                                                             |
               |  ┌───────────────────────────────────────────────────────┐  |
               |  │ Object: images/banner.png                             │  |
               |  │  - Key: "images/banner.png"                           │  |
               |  │  - Value (Data bytes): Up to 5 TB                     │  |
               |  │  - Version ID: 3/L4kqtJlcpXRf8                        │  |
               |  │  - Metadata: { "Content-Type": "image/png" }          │  |
               |  │  - Encryption: SSE-KMS / SSE-S3                       │  |
               |  │  - Storage Class: S3 Standard                         │  |
               |  └───────────────────────────────────────────────────────┘  |
               |                                                             |
               |  Lifecycle Policies: Standard ──► S3-IA ──► S3 Glacier     |
               |  Security: S3 Block Public Access + Bucket Policy (JSON)     |
               +-------------------------------------------------------------+
```

---

## 1. What is S3?

- **Definition**: Amazon S3 is an **Object Storage Service**, not a block or file storage system. Data is stored as individual objects within containers called buckets, rather than as blocks on a physical drive (EBS) or hierarchical filesystem directories (EFS).
- **Scale**: Virtually unlimited storage capacity. You never need to pre-provision disk size.
- **Durability vs. Availability**:
  - **Durability**: **99.999999999% (11 9's)**. S3 automatically replicates data across a minimum of three physically distinct Availability Zones (AZs) within an AWS Region.
  - **Availability**: **99.99%** for S3 Standard (designed to be operational and accessible when requested).
- **Access Protocol**: Pure HTTP/HTTPS REST API, accessible anywhere over the web using standard endpoints.

---

## 2. S3 Buckets

A **Bucket** is a top-level container for storing objects in Amazon S3.

### Bucket Rules and Namespace:
- **Global Namespace**: Bucket names are shared across all AWS accounts globally. Once a name is taken anywhere in AWS, no other account can use it until it is deleted.
- **Naming Conventions**:
  - Must be between 3 and 63 characters long.
  - Consists only of lowercase letters, numbers, and hyphens (`-`).
  - Cannot begin or end with a hyphen; cannot contain uppercase letters or underscores.
  - Cannot be formatted as an IP address (e.g., `192.168.5.4`).
- **Region-Specific**: While bucket names are globally unique, each bucket resides in a specific AWS Region selected upon creation. All objects inside that bucket physically live in that Region.
- **URL Format**:
  - Virtual-hosted style: `https://<bucket-name>.s3.<region>.amazonaws.com/<key-name>`
  - Example: `https://my-data-bucket.s3.us-east-1.amazonaws.com/logs/app.log`

---

## 3. S3 Objects

An **Object** is the fundamental entity stored in Amazon S3. An object consists of the following components:

- **Key**: The name assigned to the object, representing the full path (e.g., `uploads/2026/report.pdf`). Note: S3 has a flat namespace; folder paths (`/`) are simply part of the key name string.
- **Value**: The actual content/payload of the file.
  - Minimum size: 0 bytes.
  - Maximum size for a single object: **5 Terabytes (TB)**.
  - Maximum size uploaded in a single HTTP PUT operation: **5 Gigabytes (GB)**. Anything larger than 100 MB should use **Multipart Upload**.
- **Version ID**: A unique string identifying the specific version of the object when Versioning is enabled.
- **Metadata**: Key-value pairs containing information about the object:
  - System metadata: `Content-Type`, `Content-Length`, `Last-Modified`, `ETag`.
  - User-defined metadata: Custom attributes tagged onto the object.
- **Access Control Information**: Permissions dictating who can access the object.

---

## 4. S3 Storage Classes

AWS provides multiple storage classes tailored for different access frequencies and cost structures:

| Storage Class | Use Case | Durability | Min Storage Duration | Retrieval Fee | Access Latency |
|---|---|---|---|---|---|
| **S3 Standard** | Active, frequently accessed data (web assets, big data) | 99.999999999% (Multi-AZ) | None | None | Milliseconds |
| **S3 Intelligent-Tiering** | Unknown or unpredictable access patterns; auto-moves data across tiers | 99.999999999% (Multi-AZ) | None | None | Milliseconds |
| **S3 Standard-IA (Infrequent Access)** | Long-term data accessed less than once a month (disaster recovery) | 99.999999999% (Multi-AZ) | 30 days | Per GB fee | Milliseconds |
| **S3 One Zone-IA** | Non-critical, recreatable infrequently accessed data stored in 1 AZ | 99.999999999% (Single AZ) | 30 days | Per GB fee | Milliseconds |
| **S3 Glacier Instant Retrieval** | Archive data requiring immediate millisecond access | 99.999999999% (Multi-AZ) | 90 days | Per GB fee | Milliseconds |
| **S3 Glacier Flexible Retrieval** | Backup archive accessed 1–2 times a year | 99.999999999% (Multi-AZ) | 90 days | Per GB fee | Minutes to hours |
| **S3 Glacier Deep Archive** | Long-term digital preservation / regulatory compliance (7–10 years) | 99.999999999% (Multi-AZ) | 180 days | Lowest cost tier | 12 to 48 hours |

---

## 5. S3 Versioning

**Versioning** is a bucket-level feature that keeps multiple variants of an object in the same bucket.

```text
               PUT file.txt (Content: "Version 1") ──► Version ID: 111111 (Current)
               PUT file.txt (Content: "Version 2") ──► Version ID: 222222 (Current)
                                                   └── Version ID: 111111 (Previous)

               DELETE file.txt
               └── Inserts a "Delete Marker" as Current (Version ID: 333333)
               └── Version ID: 222222 and 111111 remain intact!
               └── To restore, simply delete the Delete Marker.
```

### Benefits:
- **Accidental Deletion Protection**: Deleting an object without specifying a version ID creates a **Delete Marker**. The object can be restored simply by deleting the Delete Marker.
- **Accidental Overwrite Protection**: Overwriting a file preserves the previous versions.
- **MFA Delete**: Requires Multi-Factor Authentication to permanently delete an object version or alter the bucket versioning state.
- **Note on Bucket States**: Once enabled on a bucket, versioning cannot be disabled—it can only be **suspended**.

---

## 6. S3 Lifecycle Policies

A **Lifecycle Policy** is an automated rule set defined at the bucket level that manages objects throughout their lifetime to optimize storage costs.

### Actions Supported:
1. **Transition Actions**: Automatically transition objects between storage classes based on age.
   - *Example*: Move objects from **S3 Standard** to **S3 Standard-IA** after 30 days, to **S3 Glacier Flexible Retrieval** after 90 days, and to **S3 Glacier Deep Archive** after 180 days.
2. **Expiration Actions**: Permanently delete objects after a specified number of days.
   - *Example*: Permanently delete logs after 365 days.
3. **Noncurrent Version Expiration**: Expire older, non-current versions of versioned objects after a configured retention period (e.g., retain older versions for only 14 days).
4. **Abort Incomplete Multipart Uploads**: Clean up failed, abandoned multipart upload fragments to prevent hidden storage costs.

---

## 7. S3 Encryption

Amazon S3 supports encryption both in transit and at rest.

### In Transit:
- All communications are encrypted using **TLS/HTTPS**.
- Can be strictly enforced via bucket policy using the `"aws:SecureTransport": "true"` condition.

### At Rest:
All new objects uploaded to S3 are encrypted by default at rest.

1. **SSE-S3 (Server-Side Encryption with S3 Managed Keys)**:
   - AWS handles encryption and key management automatically using AES-256.
   - Enabled by default on every new S3 bucket with zero management overhead.
2. **SSE-KMS (Server-Side Encryption with AWS Key Management Service)**:
   - Keys are created and managed in AWS KMS.
   - Provides an audit trail in AWS CloudTrail tracking who used the key to access data.
   - Enables key rotation and separation of duties between S3 storage admins and KMS key admins.
3. **SSE-C (Server-Side Encryption with Customer-Provided Keys)**:
   - The client provides their own encryption key in the HTTPS request header; AWS encrypts the object and immediately discards the key from memory.
4. **Client-Side Encryption**:
   - The client application encrypts the data locally before sending it across the network to Amazon S3.

---

## 8. S3 Bucket Policies

A **Bucket Policy** is an IAM resource-based policy written in JSON attached directly to an S3 bucket.

### Common Capabilities:
- Granting public read access (e.g., for static website hosting).
- Enforcing HTTPS encryption in transit.
- Granting cross-account access to another AWS account.
- Restricting bucket access to a specific Virtual Private Cloud (VPC) via a **VPC Endpoint**.

### Example Bucket Policy (Enforce HTTPS Traffic Only):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-secure-bucket",
        "arn:aws:s3:::my-secure-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

### S3 Block Public Access:
- A centralized security safeguard enabled at the account or bucket level that overrides any bucket policy or ACL granting public access. Prevents accidental exposure of confidential data to the internet.

---

## 9. Common Use Cases

1. **Static Website Hosting**:
   - Host HTML, CSS, JavaScript, and client-side web applications directly from S3 at low cost, paired with **Amazon CloudFront** for global CDN caching and SSL termination.
2. **Backup and Disaster Recovery (DR)**:
   - Storing database dumps, system snapshots, and critical logs across 3+ Availability Zones with 11 9's durability, transitioning to Glacier Deep Archive for compliance.
3. **Data Lakes & Big Data Analytics**:
   - S3 serves as the primary data lake repository for AWS analytical tools like **Amazon Athena** (interactive SQL queries), **AWS Glue** (ETL cataloging), and **Amazon EMR** (Spark/Hadoop).
4. **Media and Application Asset Storage**:
   - Serving user avatars, uploaded video files, PDF invoices, and software distribution binaries directly to end users securely via pre-signed URLs.
