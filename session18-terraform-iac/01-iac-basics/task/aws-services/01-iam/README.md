# 01. AWS IAM (Identity and Access Management) - Governance

## Overview

AWS Identity and Access Management (IAM) is a foundational web service that helps you securely control access to Amazon Web Services (AWS) resources. IAM provides the core authentication (AuthN) and authorization (AuthZ) layer for all AWS API calls and interactions.

```text
               +-------------------------------------------------------+
               |                  Request Entity                       |
               |  (Root User / IAM User / IAM Role / Federated User)   |
               +-------------------------------------------------------+
                                           |
                                           |  1. Authenticate (AuthN)
                                           v
               +-------------------------------------------------------+
               |                   AWS IAM Service                     |
               |       Verifies credentials, tokens, or signatures      |
               +-------------------------------------------------------+
                                           |
                                           |  2. Authorize (AuthZ)
                                           |     Evaluate Policies:
                                           |     Explicit Deny? -> DENY
                                           |     Explicit Allow? -> ALLOW
                                           |     Default -> DENY
                                           v
               +-------------------------------------------------------+
               |                 AWS Target Resource                   |
               |         (S3, EC2, DynamoDB, RDS, VPC, etc.)           |
               +-------------------------------------------------------+
```

---

## 1. What is IAM?

- **Definition**: AWS IAM is a global service that allows administrators to define who (identities) can access what (resources) and under what conditions (actions and context).
- **Global Nature**: IAM resources (users, groups, roles, policies) are not tied to a specific AWS Region; they apply globally across all AWS Regions.
- **Cost**: IAM is a free, built-in feature of your AWS account. You are only charged when other AWS resources are accessed.
- **Core Responsibilities**:
  - **Authentication**: Confirming the identity of an entity via username/password, access keys, or temporary security tokens.
  - **Authorization**: Evaluating permissions to grant or deny access to requested actions on specific AWS resources.

---

## 2. IAM Users

An **IAM User** is an identity created within your AWS account that represents a human operator or an external application needing persistent interaction with AWS resources.

### Characteristics:
- Consists of a friendly name (e.g., `developer-alice`), credentials, and permissions.
- **Root User vs. IAM User**:
  - **Root User**: The email identity used when creating the AWS account. Has unconditional, complete administrator access to all resources and billing. It cannot be restricted by IAM policies. Should be locked down immediately with Multi-Factor Authentication (MFA) and never used for day-to-day administrative tasks.
  - **IAM User**: Defined within the account with specific, granular permissions. Can be disabled, updated, or deleted without affecting the root account.
- **Credentials Types**:
  - **AWS Management Console Access**: Username + Password + MFA.
  - **Programmatic Access (AWS CLI, SDK, API)**: Access Key ID (e.g., `AKIA...`) and Secret Access Key.

```text
+--------------------------------------------------------------------------+
| Root Account (root@company.com)                                           |
|   - Full control, cannot be limited by IAM policies                      |
|   - Used ONLY for initial setup, billing, and account recovery           |
+--------------------------------------------------------------------------+
       |
       +---> IAM User: alice (Console Access + MFA + Dev Policies)
       +---> IAM User: bob   (CLI Access Keys + CI/CD Deploy Policies)
```

---

## 3. IAM Groups

An **IAM Group** is a collection of IAM users. Groups allow administrators to specify permissions for multiple users at once, simplifying permission management at scale.

### Key Points:
- A group is **not an identity**; it cannot be identified as a `Principal` in an IAM policy.
- Users inherit all policies attached to the group.
- A user can belong to multiple groups (up to 300 groups).
- Groups cannot contain other groups (no nested groups).
- **Advantage**: Instead of updating individual policies across dozens of users, you modify the group policy once, immediately propagating changes to all member users.

```text
+-------------------+       +-------------------+       +-------------------+
|  Group: Admins    |       | Group: Developers |       | Group: Auditors   |
|  Policy: AdminAll |       | Policy: S3/EC2Dev |       | Policy: ReadOnly  |
+-------------------+       +-------------------+       +-------------------+
          |                           |                           |
     [User: Alice]               [User: Bob]                 [User: Charlie]
                                 [User: Dave]
```

---

## 4. IAM Roles

An **IAM Role** is an identity with permission policies that determine what the identity can and cannot do in AWS. Unlike an IAM user, a role is **not uniquely associated with a single person or long-term credential**.

### How Roles Work:
- Anyone or any service that assumes a role is provided with **temporary security credentials** (access key ID, secret access key, and session token) issued by the **AWS Security Token Service (STS)**.
- Temporary credentials automatically expire after a configurable duration (from 15 minutes up to 12 hours).

### Core Components of a Role:
1. **Trust Policy (AssumeRolePolicyDocument)**: Defines **who** is allowed to assume the role (e.g., an EC2 instance, AWS Lambda service, another AWS account, or an OIDC provider like GitHub Actions).
2. **Permissions Policy**: Defines **what** actions and resources the assumed identity can access.

### Role Types and Mechanisms:
- **Service Roles / EC2 Instance Profiles**: Attached directly to EC2 instances or Lambda functions so applications can access AWS services (e.g., S3, DynamoDB) without hardcoding secret keys inside code or config files.
- **Cross-Account Roles**: Enables users or workloads from Account A to securely manage resources in Account B without creating separate credentials in Account B.
- **Web Identity / OIDC Federation**: Allows workloads in GitHub Actions, GitLab CI, or Kubernetes pods (via IRSA / EKS Pod Identities) to assume IAM roles securely using OpenID Connect without static credentials.

```text
+----------------------+        STS: AssumeRole         +-------------------------+
| EC2 Instance Profile | ---------------------------->  |  IAM Role: S3-Writer    |
| (No hardcoded keys)  | <----------------------------  |  Trust: ec2.amazonaws   |
+----------------------+     Temporary STS Credentials  |  Policy: s3:PutObject   |
                                                        +-------------------------+
```

---

## 5. IAM Policies

An **IAM Policy** is an explicit JSON document that defines formal permissions. Policies can be identity-based or resource-based.

### Policy Types:
1. **AWS Managed Policies**: Created and maintained by AWS (e.g., `AdministratorAccess`, `AmazonS3ReadOnlyAccess`). Updated automatically as AWS adds new actions.
2. **Customer Managed Policies**: Created and administered by you in your account. Recommended for production to strictly adhere to least privilege.
3. **Inline Policies**: Policies embedded directly into a single IAM user, group, or role. Strictly 1-to-1; deleted when the entity is deleted.
4. **Resource-Based Policies**: Attached directly to a resource (e.g., S3 Bucket Policies, KMS Key Policies, SQS Queue Policies). Specifies who can access the resource and what actions they can perform.

### Policy Evaluation Logic:
```text
Default = DENY
     │
     ▼
Is there an EXPLICIT DENY? ──── Yes ───► Result: DENY (Final)
     │ No
     ▼
Is there an EXPLICIT ALLOW? ─── Yes ───► Result: ALLOW
     │ No
     ▼
Result: DENY (Default Implicit Deny)
```

---

## 6. Permissions & JSON Policy Anatomy

Every policy statement contains specific elements that dictate how AWS evaluates the access request.

### Anatomy of a Policy Document:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ObjectReadForDevBucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::company-dev-assets",
        "arn:aws:s3:::company-dev-assets/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        },
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

### Statement Elements:
- **Version**: Policy language version. Always use `"2012-10-17"`.
- **Sid (Optional)**: Statement Identifier for human-readable context.
- **Effect**: Specifies `"Allow"` or `"Deny"`.
- **Principal (Required in Resource-Based Policies)**: Specifies the account, user, role, or federated identity allowed or denied access.
- **Action**: The specific API operations allowed or denied (e.g., `ec2:RunInstances`, `s3:PutObject`).
- **Resource**: Amazon Resource Name (ARN) identifying the target AWS resources.
- **Condition (Optional)**: Specifies conditions under which the policy is valid (e.g., requiring SSL via `aws:SecureTransport`, matching IP ranges, requiring MFA, or checking tags).

---

## 7. Principle of Least Privilege (PoLP)

The **Principle of Least Privilege** requires granting only the absolute minimum permissions necessary for an identity or service to complete its designated task—nothing more, nothing less.

### Why It Matters:
- **Limits Blast Radius**: If credentials are compromised, the attacker can only access a very narrow set of resources rather than the entire infrastructure.
- **Prevents Human Error**: Prevents accidental modification or destruction of production data by developers or operators.
- **Compliance & Audit**: Meets requirements for PCI-DSS, SOC 2, ISO 27001, and HIPAA.

### Implementation Strategies:
- Avoid wildcard permissions (`"Action": "*"` and `"Resource": "*"`).
- Restrict resources by exact ARNs and tags (ABAC - Attribute-Based Access Control).
- Use **Permission Boundaries** to set the maximum permissions an administrator can grant to roles and users.
- Use **IAM Access Analyzer** to inspect and remove unused permissions over time based on actual CloudTrail access logs.

---

## 8. IAM Best Practices

| Best Practice | Description |
|---|---|
| **Lock Away Root Credentials** | Never create access keys for root. Enable hardware or virtual MFA. Use root only for account closure or specific root-only tasks. |
| **Enforce Multi-Factor Authentication (MFA)** | Mandate MFA on all human IAM user accounts and console logins. |
| **Rely on IAM Roles Instead of Long-Lived Keys** | Use EC2 instance profiles, ECS task execution roles, Lambda execution roles, and OIDC tokens instead of storing static `AKIA...` keys on servers. |
| **Rotate Credentials Regularly** | If long-lived access keys must exist, rotate them at least every 90 days. Deactivate unused keys immediately. |
| **Apply Least Privilege** | Start with zero permissions, grant access incrementally, and scope down resources by ARN and condition keys. |
| **Use Groups for Permission Assignment** | Assign policies to groups and add users to groups, rather than attaching policies directly to individual users. |
| **Audit with CloudTrail & IAM Credential Reports** | Continuously record all API calls with AWS CloudTrail and generate periodic IAM credential reports to locate stale accounts and keys. |
| **Use Service Control Policies (SCPs)** | In AWS Organizations, establish guardrails at the Organizational Unit (OU) level to prevent even account admins from bypassing company security boundaries. |

---

## 9. Common Use Cases

1. **EC2 Instance Accessing S3 Securely**:
   - An application running on an EC2 instance reads assets from an S3 bucket.
   - **Solution**: Create an IAM role with `s3:GetObject` permission, attach it to an EC2 Instance Profile, and assign it to the instance. The AWS SDK automatically retrieves temporary credentials from the Instance Metadata Service (IMDSv2). No credentials are ever stored in code.
2. **GitHub Actions / CI/CD Deployment with OIDC**:
   - Deploying Terraform infrastructure from a GitHub Actions workflow.
   - **Solution**: Configure an IAM OIDC Identity Provider for `token.actions.githubusercontent.com`. GitHub Actions exchanges a short-lived OIDC token for temporary AWS STS credentials via an IAM Role with exact repository branch conditions. No static AWS keys are stored in GitHub Secrets.
3. **Cross-Account Administrative Access**:
   - Central Security/DevOps Account managing resources in Dev, Staging, and Production accounts.
   - **Solution**: Create an IAM role in the Target account with a trust policy referencing the Security account. Engineers authenticate once to the Security account and assume the target role to execute approved tasks.
4. **Developer Tier Segregation**:
   - Junior developers can read and modify development resources (tagged `Environment: dev`), but have strictly read-only access to staging and zero access to production workloads.
