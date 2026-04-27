# Organization-Wide Package Management Tool with Developer Portal

## System Overview

This system integrates a developer portal with an organization-wide package management tool (`@mytool`) to provide centralized governance while enabling self-service package management across the organization.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Developer Portal (React/Vue)                     │
│  ┌──────────────┬──────────────┬──────────────┬──────────────────────┐  │
│  │   Login      │  Repository  │  Workspace   │  Request/Logs View   │  │
│  │              │   Browser    │  Manager     │                      │  │
│  └──────────────┴──────────────┴──────────────┴──────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────────────┘
                          │
                 ┌────────▼────────┐
                 │  Portal Backend  │ (Node.js/Python APIs)
                 │    (REST APIs)   │
                 └────────┬─────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
    ┌─────────┐   ┌────────────┐   ┌──────────────────┐
    │  Azure   │   │  GitHub    │   │  @mytool CLI     │
    │   ACR    │   │ Actions    │   │ (Package Manager)│
    │          │   │            │   │                  │
    │ • Images │   │ • Workflows│   │ • Runtime        │
    │ • Packages   │ • Pipeline │   │   Adapters       │
    │ • Versions   │ • Tests    │   │ • Validation     │
    └────┬─────┘   └────┬───────┘   └────────┬─────────┘
         │              │                     │
         │    ┌─────────┼─────────┐           │
         │    ▼         ▼         ▼           │
         │  ┌─────────────────────────┐       │
         │  │   Kafka Message Bus      │       │
         │  │  (Event Streaming)       │       │
         │  │ • Request Events         │◄──────┘
         │  │ • Approval Events        │
         │  │ • Build Status Events    │
         │  │ • Notifications          │
         │  └────────────┬─────────────┘
         │               │
         │               ▼
         │    ┌──────────────────────┐
         │    │ Notification Service │
         │    │ (Email, Slack, Teams)│
         │    └──────────────────────┘
         │
         ▼
    ┌──────────────────────────────────┐
    │  GitHub Codespaces / Anaconda    │
    │  • .devcontainer.json            │
    │  • Environment Setup             │
    │  • Pull Packages from ACR        │
    │  • Trigger Tests                 │
    │  • Submit PRs                    │
    └──────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                          Data Storage Layer                               │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐              │
│  │  CosmosDB/     │  │  PostgreSQL    │  │  Git Repos     │              │
│  │  MongoDB       │  │  (Metadata)    │  │  (Config as    │              │
│  │                │  │                │  │   Code)        │              │
│  │ • Users        │  │ • Requests     │  │                │              │
│  │ • Teams        │  │ • Approvals    │  │ • Version      │              │
│  │ • Roles        │  │ • Audit Log    │  │   Catalogs     │              │
│  │ • Workspaces   │  │ • Workflows    │  │ • Policies     │              │
│  └────────────────┘  └────────────────┘  └────────────────┘              │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### 1. Developer Portal (Frontend)
**Technology:** React/Vue.js + TypeScript
**Key Features:**
- User authentication (Azure AD / OAuth)
- Repository browser with package search and filtering
- Workspace management (create, list, resume)
- Request tracking with status and logs
- Real-time notification center
- User and team management interface

**Pages:**
```
/login                          - OAuth/OIDC login
/dashboard                      - Main portal home
/repository                     - Browse packages, search, versions
/repository/{packageId}         - Package details & approval status
/workspaces                     - List user's workspaces
/workspaces/create              - Create new workspace (Codespaces/Anaconda)
/requests                       - Track submitted requests
/requests/{requestId}           - View request details and logs
/approvals                      - [Admin] Review pending approvals
/users                          - [Admin] User management
/notifications                  - Notification preferences
```

---

### 2. Portal Backend API
**Technology:** Node.js/Python (Express/FastAPI)
**Port:** 8080 (behind Azure API Gateway)

**Key Endpoints:**

```
Authentication:
  POST   /api/auth/login              - Initiate OAuth flow
  POST   /api/auth/callback           - OAuth callback
  POST   /api/auth/logout             - Logout user
  GET    /api/auth/me                 - Get current user

Repository & Packages:
  GET    /api/repositories            - List all repositories
  GET    /api/packages                - List all packages (with filters)
  GET    /api/packages/:packageId     - Get package details
  GET    /api/packages/:packageId/versions  - List versions
  GET    /api/packages/:packageId/versions/:version  - Version details

Workspaces:
  GET    /api/workspaces             - List user's workspaces
  POST   /api/workspaces             - Create new workspace
  GET    /api/workspaces/:workspaceId - Get workspace details
  PATCH  /api/workspaces/:workspaceId - Update workspace
  DELETE /api/workspaces/:workspaceId - Delete workspace

Requests:
  GET    /api/requests               - List user's requests
  POST   /api/requests               - Submit new package request
  GET    /api/requests/:requestId    - Get request details
  GET    /api/requests/:requestId/logs - Stream logs
  PATCH  /api/requests/:requestId/status - Update request status

Approvals (Admin):
  GET    /api/approvals              - List pending approvals
  POST   /api/approvals/:approvalId/approve   - Approve package
  POST   /api/approvals/:approvalId/reject    - Reject package
  POST   /api/approvals/:approvalId/comment   - Add comment

Users (Admin):
  GET    /api/users                  - List all users
  POST   /api/users                  - Add user
  PATCH  /api/users/:userId          - Update user role
  DELETE /api/users/:userId          - Remove user

Notifications:
  GET    /api/notifications          - Get user's notifications
  PATCH  /api/notifications/:notifId/read - Mark as read
  GET    /api/notifications/preferences - Get notification preferences
  PATCH  /api/notifications/preferences - Update preferences
```

---

### 3. @mytool CLI Package Manager
**Technology:** Python/Go CLI

**Usage:**
```bash
# Install approved package
mytool install python pandas@1.5.0
mytool install nodejs express@4.18.0
mytool install java com.google:guava:31.1-jre

# Verify package approval status
mytool verify python requests

# List approved versions
mytool list python

# Show package details
mytool info nodejs react

# Request new package (creates approval request)
mytool request python scikit-learn@1.0.0
```

**Runtime Adapters:**
```
Adapter Layer:
├── PythonAdapter (pip/poetry)
├── NodeJsAdapter (npm/yarn/pnpm)
├── JavaAdapter (maven/gradle)
├── GoAdapter (go modules)
└── RubyAdapter (bundler)

Each adapter:
├── normalize_version_spec()
├── validate_against_catalog()
├── get_installation_command()
├── detect_installed_version()
└── verify_package_integrity()
```

---

### 4. GitHub Actions Workflow Pipeline
**Location:** `.github/workflows/package-request.yml`

**Trigger:** When package request submitted from portal
**Steps:**
1. Receive request event from Kafka
2. Validate package specification
3. Run security scanning (SAST, dependency check)
4. Run vulnerability scanning (Snyk, Trivy)
5. Generate Software Bill of Materials (SBOM)
6. Create approval request in database
7. Emit event to Kafka (workflow_started)
8. Notify approvers

**Artifact:** Store scan results in ACR as metadata

---

### 5. GitHub Codespaces Integration
**Configuration File:** `.devcontainer.json`

```json
{
  "name": "Package Development Environment",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/azure/azure-dev/cli:1": {}
  },
  "postCreateCommand": "bash .devcontainer/setup.sh",
  "remoteEnv": {
    "AZURE_REGISTRY": "${localEnv:AZURE_REGISTRY}",
    "ACR_USERNAME": "${localEnv:ACR_USERNAME}",
    "ACR_PASSWORD": "${localEnv:ACR_PASSWORD}"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-azuretools.vscode-docker",
        "GitHub.copilot"
      ],
      "settings": {
        "python.linting.enabled": true
      }
    }
  }
}
```

**Setup Script:** `.devcontainer/setup.sh`
```bash
#!/bin/bash

# Install @mytool
pip install mytool

# Authenticate with Azure Container Registry
az acr login --name $AZURE_REGISTRY

# Pull approved packages from ACR
mytool sync --workspace-id $WORKSPACE_ID

# Setup Git hooks
git config core.hooksPath .githooks
chmod +x .githooks/*

# Install development dependencies
pip install -r requirements-dev.txt
```

---

### 6. Kafka Message Bus
**Topics:**

```
package-requests (Compacted Topic)
├── Event: RequestSubmitted
│   ├── requestId: UUID
│   ├── package: string
│   ├── version: string
│   ├── runtime: string
│   ├── requester: string
│   ├── timestamp: ISO8601
│   └── payload: object

├── Event: SecurityScanCompleted
│   ├── requestId: UUID
│   ├── status: PASSED|FAILED
│   ├── vulnerabilities: array
│   └── report_url: string

├── Event: ApprovalRequested
│   ├── requestId: UUID
│   ├── approvers: array
│   └── deadline: ISO8601

└── Event: ApprovalCompleted
    ├── requestId: UUID
    ├── approved: boolean
    ├── approver: string
    └── comments: string

request-status (Changelog Topic)
├── Event: RequestStatusChanged
    ├── requestId: UUID
    ├── oldStatus: SUBMITTED|SCANNING|PENDING_APPROVAL|APPROVED|REJECTED
    ├── newStatus: SUBMITTED|SCANNING|PENDING_APPROVAL|APPROVED|REJECTED
    └── reason: string

notifications
├── Event: UserNotification
    ├── userId: UUID
    ├── type: REQUEST_APPROVED|REQUEST_REJECTED|REVIEW_REQUESTED|BUILD_FAILED
    ├── channel: EMAIL|SLACK|TEAMS
    └── payload: object

workspace-events
├── Event: WorkspaceCreated
├── Event: WorkspaceUpdated
├── Event: EnvironmentReady
└── Event: PackagesProvisioned
```

---

### 7. Notification Service
**Technology:** Python/Node.js service consuming Kafka

**Channels:**
- Email (SendGrid / Azure SendGrid)
- Slack (Slack API)
- Microsoft Teams (Teams Webhooks)
- In-app notifications (WebSocket)

**Notification Templates:**
```
Approval Requested:
  "Package {package}@{version} requesting approval. 
   Review: {portal_url}/approvals/{requestId}"

Approved:
  "✅ {package}@{version} approved! 
   Available in ACR. Use: mytool install {package}@{version}"

Rejected:
  "❌ {package}@{version} rejected. 
   Reason: {reason}. Update and resubmit."

Build Failed:
  "🔴 Request {requestId} failed validation: {reason}
   View logs: {portal_url}/requests/{requestId}"
```

---

### 8. Anaconda Integration
**Configuration:** `.anaconda-env.yml`

```yaml
name: mytool-workspace
channels:
  - https://<acr>.azurecr.io/conda
  - conda-forge
  - defaults
dependencies:
  - python=3.11
  - pip=23.0
  - pytool::pandas=1.5.0
  - pytool::numpy=1.24.0
  - pip:
    - scikit-learn==1.2.0
```

**Workflow:**
1. User selects "Anaconda" workspace type from portal
2. Portal API creates workspace entry in DB
3. Anaconda environment provisioned with approved packages
4. Developer opens Anaconda workspace
5. Developer makes changes, commits to branch
6. GitHub Actions triggered (via branch filter)
7. Tests run, PR created
8. Approvers review in portal
9. On approval, package added to approved catalog
10. Updated metadata pushed to ACR

---

## Data Models

### User/Team Management
```python
# User
{
  id: UUID,
  email: string,
  name: string,
  azureId: string,
  teams: [TeamId],
  roles: [DEVELOPER|APPROVER|ADMIN|SECURITY_LEAD],
  createdAt: ISO8601,
  lastLogin: ISO8601
}

# Team
{
  id: UUID,
  name: string,
  members: [UserId],
  approvalAuthority: [Package Domain],
  createdBy: UserId,
  createdAt: ISO8601
}
```

### Package & Version Management
```python
# Package
{
  id: UUID,
  name: string,
  runtime: PYTHON|NODEJS|JAVA|GO|RUBY,
  packageManager: pip|npm|maven|go|bundler,
  description: string,
  repository: string,
  createdAt: ISO8601,
  updatedAt: ISO8601,
  versions: [Version]
}

# Version
{
  id: UUID,
  packageId: UUID,
  versionNumber: string,
  status: PENDING|APPROVED|DEPRECATED|QUARANTINED,
  approvalDate: ISO8601,
  approvedBy: UserId,
  acrReference: string,  # e.g., myacr.azurecr.io/python/pandas:1.5.0
  checksums: {
    sha256: string,
    md5: string
  },
  licenses: [LicenseType],
  vulnerabilities: [CVE],
  sbom: URL,
  dependencies: [PackageVersion],
  deprecationDate: ISO8601,
  retirementDate: ISO8601
}
```

### Request Management
```python
# Request
{
  id: UUID,
  requesterId: UserId,
  package: {
    name: string,
    runtime: string,
    version: string
  },
  status: SUBMITTED|SCANNING|PENDING_APPROVAL|APPROVED|REJECTED,
  submittedAt: ISO8601,
  workspaceId: UUID,
  gitHubPrUrl: string,
  scanResults: {
    sast: SastResult,
    dependency: DependencyResult,
    vulnerability: VulnerabilityResult,
    sbom: string
  },
  approvals: [Approval],
  comments: [Comment],
  completedAt: ISO8601
}

# Approval
{
  id: UUID,
  requestId: UUID,
  approverId: UserId,
  status: PENDING|APPROVED|REJECTED,
  authority: Team|Security|Admin,
  comment: string,
  completedAt: ISO8601
}
```

### Workspace Management
```python
# Workspace
{
  id: UUID,
  userId: UserId,
  type: CODESPACES|ANACONDA,
  name: string,
  status: CREATING|READY|SUSPENDED|DELETED,
  repository: string,
  branch: string,
  acr_credentials: {
    username: string,
    passwordEncrypted: string
  },
  environmentVariables: object,
  createdAt: ISO8601,
  lastActivated: ISO8601,
  expiresAt: ISO8601
}
```

---

## Workflow: Complete Request Lifecycle

### Step 1: Developer Submits Request
```
User in Portal → Repository Tab
              → Click "Request Access" on package
              → Select Version
              → Specify Workspace (Codespaces/Anaconda)
              → Submit
              → Portal API creates Request record
              → Emits "RequestSubmitted" to Kafka
```

### Step 2: Security Scanning
```
GitHub Actions Workflow triggered
  ↓
Validate package spec (does it exist in public registries?)
  ↓
Run SAST scan (code quality, secrets)
  ↓
Run Dependency check (known vulnerabilities)
  ↓
Generate SBOM
  ↓
Update Request status → "SCANNING"
  ↓
Emit "SecurityScanCompleted" to Kafka
```

### Step 3: Manual Approval
```
If scan passes:
  ├── Emit "ApprovalRequested" to Kafka
  ├── Notify assigned approvers (Slack/Email)
  └── Portal shows request in /approvals queue

Approver reviews:
  ├── Views scan results
  ├── Checks vendor reputation
  ├── Reviews license compatibility
  ├── Approves or rejects
  └── Adds comment

Status → "APPROVED" or "REJECTED"
Emit "ApprovalCompleted" to Kafka
```

### Step 4: Package Provisioning (if approved)
```
Notification Service triggered by "ApprovalCompleted"
  ↓
Add package version to approved catalog (Git)
  ↓
Push version metadata to ACR labels/tags
  ↓
Deploy new version to staging environment for testing
  ↓
If tests pass:
  ├── Promote to production ACR
  ├── Update version status → "APPROVED"
  ├── Emit "PackageAvailable" to Kafka
  └── Notify requester: "Your package is now available"

Notification Service sends:
  ├── Email to requester
  ├── Slack message
  └── In-app notification
```

### Step 5: Developer Uses Package
```
Developer opens Codespaces/Anaconda
  ↓
.devcontainer.json triggers setup.sh
  ↓
mytool sync downloads approved packages from ACR
  ↓
Package installed in development environment
  ↓
Developer can use: import pandas, require('express'), etc.
```

### Step 6: Commit & PR
```
Developer makes changes
  ↓
Commits to feature branch
  ↓
Pushes to GitHub
  ↓
GitHub Actions triggered (pre-commit hook integration)
  ↓
Validates all imports/dependencies in project
  ├── Check: all packages in requirements.txt in approved catalog?
  ├── Check: package versions match approved versions?
  └── Check: no security policies violated?
  ↓
If valid: PR created automatically
If invalid: Workflow fails, Slack notification sent
```

### Step 7: Review & Merge
```
Code Review (GitHub):
  ├── Platform Team reviews code
  ├── Approves/requests changes
  └── Optional: re-runs tests

If approved:
  ├── Merge to main
  ├── Emit "CommitMerged" to Kafka
  └── Notify in portal: "Request approved and merged"

If rejected:
  ├── Notify developer: "Changes requested"
  ├── Developer updates in existing workspace
  └── Repeat from Step 5
```

---

## Deployment Architecture

### Environment Promotion
```
Development (mytool-dev):
  └─ Developers deploy features
    └─ Staging (mytool-staging):
         └─ Internal testing, security scanning
           └─ Production (mytool-prod):
                └─ Live for all organization
```

### Kubernetes Deployment (Recommended)
```yaml
Namespaces:
  - mytool-portal-dev
  - mytool-portal-staging
  - mytool-portal-prod

Services:
  - portal-api (Node.js/Python backend)
  - notification-service (Kafka consumer)
  - @mytool-registry-sync (ACR synchronizer)
  - workspace-provisioner (Codespaces/Anaconda handler)
  - approval-workflow-engine (Decision logic)
```

### Configuration Management
```
Helm Values:
  database:
    host: cosmosdb.azure.com
    authMethod: managed_identity
  
  kafka:
    brokers: kafka-dev.eastus.eventhub.azure.net
    
  acr:
    registry: myorg.azurecr.io
    
  github:
    orgName: myorg
    apiToken: ${GITHUB_API_TOKEN}  # Azure Key Vault
    
  notifications:
    slack_webhook: ${SLACK_WEBHOOK}  # Azure Key Vault
    email_provider: sendgrid
```

---

## Security Considerations

### 1. Authentication & Authorization
- Azure AD integration for SSO
- Token-based API access (OAuth 2.0 / OIDC)
- Role-based access control (RBAC)
- Multi-factor authentication (MFA) required for approvers

### 2. Data Protection
- Encryption at rest (CosmosDB/PostgreSQL encryption)
- Encryption in transit (TLS 1.3)
- ACR credentials stored in Azure Key Vault
- Audit logging for all approval decisions

### 3. Supply Chain Security
- All packages signed and verified
- SBOM generated for each version
- Continuous vulnerability monitoring
- CVE quarantine procedures
- Checksum verification before installation

### 4. Network Security
- API Gateway with rate limiting
- VNet integration for ACR access
- Private endpoints for Kafka
- Firewall rules for Codespaces

---

## Adoption Timeline

### Phase 1 (Weeks 1-4): MVP
- Deploy portal UI (basic package browsing)
- Build CLI tool (@mytool) for Python + Node.js
- Simple ACR integration
- Manual approval process
- Notification via email

### Phase 2 (Weeks 5-8): Automation
- GitHub Actions integration
- Kafka message bus
- Automated security scanning
- Slack/Teams notifications
- Git hooks integration

### Phase 3 (Weeks 9-12): Scale
- IDE extensions (VS Code)
- Anaconda full integration
- RBAC with delegation
- Compliance dashboards
- Performance optimization

### Phase 4 (Ongoing): Enhancement
- Additional runtimes (Java, Go, Ruby)
- Advanced approval workflows
- ML-based anomaly detection
- Cost optimization
- Organizational onboarding

---

## Metrics & Monitoring

### Key Metrics
- Package approval time (SLA tracking)
- Security scanning time (MTTR)
- Developer adoption rate (% of teams using)
- Vulnerability detection rate
- False positive rate in scanning
- Workspace creation time

### Dashboards
- Admin: Approval queue, vulnerabilities, adoption metrics
- Developer: Request status, approved packages, workspace health
- Security: Scan results, vulnerability trends, license compliance

---

## Next Steps

1. **Define exact approval authority structure** — Who approves what?
2. **Select storage backend** — CosmosDB, PostgreSQL, or hybrid?
3. **Configure Azure resources** — ACR, Key Vault, EventHubs, Codespaces
4. **Design RBAC role hierarchy** — Specific teams and their authorities
5. **Establish scanning policies** — Which tools, thresholds, remediation procedures
6. **Create rollout communication plan** — How to drive adoption across teams

