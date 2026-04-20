# Complete ACR + GitHub Codespaces Workflow Diagram

## 🎯 Full System Workflow (Complete View)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     DEVELOPER → PRODUCTION COMPLETE FLOW                        │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────────┐
                              │   DEVELOPER MACHINE  │
                              │  (Local Development) │
                              └──────────┬──────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
            ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
            │   Edit Code  │    │  Git Commit  │    │  Push to Git │
            │   in VS Code │    │   + Message  │    │              │
            └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
                   │                   │                   │
                   └───────────────────┼───────────────────┘
                                       │
                                       ▼
                        ┌────────────────────────────────┐
                        │   GitHub Repository            │
                        │ (Code + Commit History)        │
                        │                                │
                        │  Branch: main/develop          │
                        │  Commit: abc1234 (latest)      │
                        └────────────┬───────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                                 │
                    ▼                                 ▼
        ┌─────────────────────────┐      ┌─────────────────────────┐
        │  GITHUB ACTIONS (CI/CD)  │      │ GITHUB CODESPACES       │
        │  Workflow Triggered      │      │ (Developer Environment) │
        │                          │      │                         │
        │  build-acr.yml           │      │ Auto-launch on demand   │
        │  - Push event detected   │      │                         │
        │  - Workflow starts       │      │ Uses .devcontainer/:    │
        └────────────┬─────────────┘      │ - devcontainer.json     │
                     │                    │ - post-create.sh        │
                     ▼                    └────────────┬─────────────┘
        ┌─────────────────────────┐                   │
        │  DOCKERFILE ANALYSIS    │                   ▼
        │                          │      ┌──────────────────────────┐
        │ - API/Dockerfile         │      │ PULL ACR IMAGES          │
        │ - Blazor/Dockerfile      │      │ (from devcontainer.json) │
        │ - Read & Validate        │      │                          │
        │                          │      │ cimpregistry.azurecr.io  │
        │ Syntax Check: ✅         │      │  ├─ cimp-api:v1.2.3      │
        │                          │      │  ├─ cimp-blazor:v1.2.3   │
        └────────────┬─────────────┘      │  └─ cimp-postgres:15.2   │
                     │                    └────────────┬──────────────┘
        ┌────────────┴──────────────┐                  │
        │                           │                  ▼
        ▼                           ▼      ┌──────────────────────────┐
   ┌─────────────┐          ┌────────────┐│ DOCKER CONTAINERS START  │
   │ BUILD DOCKER│          │ PUSH TO ACR││ docker-compose up        │
   │ IMAGES      │◄─────────│            ││                          │
   │             │          │            ││ Services Running:        │
   │ Multi-stage │          │ ACR Login  ││ - API (port 5000)        │
   │ build:      │          │  (Creds)   ││ - Blazor (port 3000)     │
   │             │          │            ││ - PostgreSQL (port 5432) │
   │ ├─ API      │          │ Push:      ││ - Redis (port 6379)      │
   │ ├─ Blazor   │          │  v1.2.3    ││                          │
   │ ├─ Postgres │          └────────────┘│ Health checks: ✅        │
   │ ├─ Redis    │                        └──────────┬─────────────┘
   │ └─ Others   │                                   │
   │             │                    ┌──────────────┘
   │ Cached      │                    │
   │ Layers      │                    ▼
   │ Reused      │      ┌─────────────────────────────────┐
   │ Faster ✨   │      │ DEVELOPER READY TO CODE         │
   │             │      │                                 │
   │ Time:       │      │ ✓ Fresh Codespace (2-3 min)    │
   │ ~3-5 min    │      │ ✓ All services running         │
   │             │      │ ✓ Same versions as production  │
   │ Final Size: │      │ ✓ Ready to develop             │
   │ API: 150MB  │      │ ✓ Same as staging & prod       │
   │ Blazor: 80MB│      │                                 │
   │ Postgres: 90MB      └──────────┬────────────────────┘
   └───────────┬─────┘              │
               │                    │ (REPEAT CYCLE)
               │          ┌─────────┴──────────┐
               │          │                    │
               │          ▼                    ▼
               │    ┌──────────────┐    ┌──────────────┐
               │    │  Make Code   │    │  Debug Code  │
               │    │  Changes     │    │  if Needed   │
               │    └──────────────┘    └──────────────┘
               │                             │
               │                             ▼
               │                    ┌──────────────────┐
               │                    │ Test Locally in  │
               │                    │ Codespace        │
               │                    │                  │
               │                    │ ✓ Unit tests     │
               │                    │ ✓ API tests      │
               │                    │ ✓ Integration    │
               │                    └──────────────────┘
               │
               └──► Ready to commit & push
                    │
                    ▼
        ┌────────────────────────────────┐
        │  GITHUB ACTIONS BUILDS AGAIN    │
        │  (Automated on every push)      │
        │                                 │
        │  Stage 1: Build                 │
        │  Stage 2: Test                  │
        │  Stage 3: Scan (Trivy)          │
        │  Stage 4: Push to ACR           │
        │  Stage 5: Tag as Latest         │
        └────────────┬───────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │   IMAGE SECURITY SCANNING      │
        │   (Built into ACR)             │
        │                                 │
        │   Trivy Vulnerability Scan      │
        │   ├─ High severity: ❌ Block    │
        │   ├─ Medium severity: ⚠️ Warn  │
        │   ├─ Low severity: ℹ️ Log      │
        │   └─ Clean: ✅ Approve         │
        │                                 │
        │   Results saved to ACR Logs     │
        └────────────┬───────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼ (Prod Ready)         ▼ (Issues Found)
    ┌──────────────┐      ┌──────────────┐
    │ APPROVED ✅  │      │ QUARANTINE   │
    │              │      │ (Fix Issues) │
    │ Image tagged │      │              │
    │ as:          │      │ Developer    │
    │ - v1.2.3     │      │ notified     │
    │ - latest     │      │ of vulns     │
    │ - stable     │      └──────────────┘
    └──────┬───────┘
           │
           ▼
    ┌──────────────────────────────┐
    │  PRODUCTION DEPLOYMENT        │
    │  (Via separate workflow)       │
    │                               │
    │  Kubernetes / Container Apps  │
    │  Docker Compose               │
    │  Manual deployment            │
    │                               │
    │  Pull same images from ACR    │
    │  Start containers             │
    │  Health checks                │
    │  Load balancer config         │
    └──────┬───────────────────────┘
           │
           ▼
    ┌──────────────────────────────┐
    │  PRODUCTION RUNNING ✅        │
    │                               │
    │  Services Live:               │
    │  ├─ API (cimpregistry.azurecr│
    │  │  .io/cimp-api:v1.2.3)      │
    │  ├─ Blazor (cimpregistry.    │
    │  │  azurecr.io/cimp-blazor:  │
    │  │  v1.2.3)                   │
    │  ├─ Database (v15.2)          │
    │  └─ Cache (Redis)             │
    │                               │
    │  Version locked & consistent  │
    │  Same as dev & staging        │
    │  100% reproducible            │
    │  Full audit trail in ACR      │
    │  No surprises! 🎉             │
    └──────────────────────────────┘
```

---

## 🛠️ All Tools & Services Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TOOLS & SERVICES LAYER                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 1: LOCAL DEVELOPMENT (YOUR MACHINE)                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  VS Code                          Git                      GitHub CLI        │
│  ├─ C# Extension                  ├─ Commit                ├─ PR creation    │
│  ├─ .NET Extension                ├─ Branch                ├─ Issue tracking │
│  ├─ Docker Extension              ├─ Push                  └─ Repo mgmt      │
│  ├─ Blazor Debug                  └─ Merge                                   │
│  └─ Terminal                                                                 │
│                                                                               │
│  Docker Desktop                                                              │
│  ├─ Local image building                                                     │
│  ├─ Container testing                                                        │
│  └─ docker-compose up (optional)                                             │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 2: CLOUD DEVELOPMENT (GITHUB CODESPACES)                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  GitHub Codespaces                                                           │
│  ├─ Full VS Code in cloud                                                    │
│  ├─ .devcontainer/                                                           │
│  │  ├─ devcontainer.json (configuration)                                     │
│  │  ├─ post-create.sh (setup script)                                         │
│  │  └─ Features:                                                             │
│  │     ├─ .NET SDK                                                           │
│  │     ├─ Docker CLI                                                         │
│  │     ├─ Azure CLI                                                          │
│  │     ├─ Git                                                                │
│  │     └─ Node.js (for some tools)                                           │
│  │                                                                            │
│  ├─ Docker (built-in)                                                        │
│  │  ├─ Pull images from ACR                                                  │
│  │  └─ Run containers                                                        │
│  │                                                                            │
│  └─ Full development experience                                              │
│     ├─ SSH access                                                            │
│     ├─ Port forwarding (3000, 5000, 5432)                                    │
│     ├─ Full file system                                                      │
│     └─ Terminal access                                                       │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 3: SOURCE CONTROL (GITHUB)                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  GitHub Repository                                                           │
│  ├─ Source code storage                                                      │
│  ├─ Commit history & versioning                                              │
│  ├─ Branch management (main, develop, feature/*)                             │
│  ├─ Pull requests & code review                                              │
│  ├─ Issues & project management                                              │
│  ├─ Webhooks & notifications                                                 │
│  ├─ GitHub Secrets (secure credentials storage)                              │
│  │  ├─ ACR_LOGIN_SERVER                                                      │
│  │  ├─ ACR_USERNAME                                                          │
│  │  ├─ ACR_PASSWORD                                                          │
│  │  └─ ACR_REGISTRY_NAME                                                     │
│  │                                                                            │
│  └─ .github/workflows/                                                       │
│     ├─ build-acr.yml (Build & push to ACR)                                   │
│     ├─ test.yml (Run unit tests)                                             │
│     ├─ scan.yml (Security scanning)                                          │
│     └─ deploy.yml (Production deployment)                                    │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 4: CI/CD PIPELINE (GITHUB ACTIONS)                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  GitHub Actions (Automated)                                                  │
│  ├─ Trigger: On push to main/develop                                         │
│  ├─ Runner: ubuntu-latest (Microsoft hosted)                                 │
│  │                                                                            │
│  ├─ Step 1: Checkout Code                                                    │
│  │  └─ git clone ${{ github.repository }}                                    │
│  │                                                                            │
│  ├─ Step 2: Setup Environment                                                │
│  │  ├─ Install .NET SDK                                                      │
│  │  ├─ Install Docker                                                        │
│  │  ├─ Install Azure CLI                                                     │
│  │  └─ Install Trivy (scanner)                                               │
│  │                                                                            │
│  ├─ Step 3: Build Docker Images                                              │
│  │  ├─ docker build -t cimp-api:${{ github.sha }} ./CIMPPortal.Api           │
│  │  ├─ docker build -t cimp-blazor:${{ github.sha }} ./CIMPPortal.Blazor     │
│  │  ├─ docker build -t cimp-postgres:15 ./database/                          │
│  │  └─ Caching enabled for faster rebuilds                                   │
│  │                                                                            │
│  ├─ Step 4: Run Tests                                                        │
│  │  ├─ Unit tests: dotnet test                                               │
│  │  ├─ API tests: Postman/REST Assured                                       │
│  │  ├─ Integration tests: TestContainers                                      │
│  │  └─ Coverage: SonarCloud (optional)                                        │
│  │                                                                            │
│  ├─ Step 5: Security Scan                                                    │
│  │  ├─ Trivy scan (vulnerability detection)                                  │
│  │  │  └─ trivy image cimp-api:${{ github.sha }}                             │
│  │  ├─ Check for secrets (gitguardian)                                       │
│  │  ├─ SAST scan (CodeQL)                                                    │
│  │  └─ Report results                                                        │
│  │                                                                            │
│  ├─ Step 6: Login to ACR                                                     │
│  │  └─ az acr login --name cimpregistry                                      │
│  │     --username ${{ secrets.ACR_USERNAME }}                                │
│  │     --password ${{ secrets.ACR_PASSWORD }}                                │
│  │                                                                            │
│  ├─ Step 7: Tag Images                                                       │
│  │  ├─ docker tag cimp-api:$sha cimpregistry.azurecr.io/cimp-api:v1.2.3     │
│  │  ├─ docker tag cimp-api:$sha cimpregistry.azurecr.io/cimp-api:latest     │
│  │  └─ Similar for blazor, postgres                                          │
│  │                                                                            │
│  ├─ Step 8: Push to ACR                                                      │
│  │  ├─ docker push cimpregistry.azurecr.io/cimp-api:v1.2.3                  │
│  │  ├─ docker push cimpregistry.azurecr.io/cimp-blazor:v1.2.3                │
│  │  └─ docker push cimpregistry.azurecr.io/cimp-postgres:15                  │
│  │                                                                            │
│  ├─ Step 9: Update Metadata                                                  │
│  │  ├─ Set image labels                                                      │
│  │  ├─ Set image description                                                 │
│  │  ├─ Store build info                                                      │
│  │  └─ Update versions.lock.yml                                              │
│  │                                                                            │
│  └─ Step 10: Notify                                                          │
│     ├─ Slack notification                                                    │
│     ├─ Email digest                                                          │
│     └─ GitHub commit status                                                  │
│                                                                               │
│  Total Time: ~5-10 minutes per build                                         │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 5: IMAGE REGISTRY (AZURE CONTAINER REGISTRY)                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Azure Container Registry (Premium SKU)                                      │
│  └─ cimpregistry.azurecr.io                                                  │
│                                                                               │
│  ├─ Image Storage                                                            │
│  │  ├─ cimp-api:v1.2.3 (150MB)                                               │
│  │  ├─ cimp-api:v1.2.2 (150MB)                                               │
│  │  ├─ cimp-api:latest → points to v1.2.3                                    │
│  │  ├─ cimp-blazor:v1.2.3 (80MB)                                             │
│  │  ├─ cimp-postgres:15.2 (90MB)                                             │
│  │  ├─ cimp-redis:7.0 (50MB)                                                 │
│  │  └─ ... (other images)                                                    │
│  │                                                                            │
│  ├─ Repository Management                                                    │
│  │  ├─ List all images                                                       │
│  │  ├─ View layer info                                                       │
│  │  ├─ Manage tags                                                           │
│  │  └─ Delete old images                                                     │
│  │                                                                            │
│  ├─ Security Features                                                        │
│  │  ├─ Private endpoint (no public access)                                   │
│  │  ├─ RBAC (Role-Based Access Control)                                      │
│  │  │  ├─ Reader role: Developers (pull only)                                │
│  │  │  ├─ Contributor: CI/CD (push)                                          │
│  │  │  └─ Admin: Ops team                                                    │
│  │  ├─ Image signing (notation)                                              │
│  │  ├─ Encryption at rest (Microsoft managed keys)                           │
│  │  └─ Audit logging (all operations logged)                                 │
│  │                                                                            │
│  ├─ Image Scanning (Built-in)                                                │
│  │  ├─ Trivy vulnerability scanner                                           │
│  │  ├─ Critical/High/Medium/Low severity                                     │
│  │  ├─ Automatic scans on push                                               │
│  │  ├─ Results saved forever                                                 │
│  │  └─ Alerts for new vulnerabilities                                        │
│  │                                                                            │
│  ├─ Performance Features                                                     │
│  │  ├─ Geo-replication (multiple regions)                                    │
│  │  ├─ Image pull cache                                                      │
│  │  ├─ Fast local pulls (same region)                                        │
│  │  └─ CDN integration (fast worldwide)                                       │
│  │                                                                            │
│  └─ Compliance & Audit                                                       │
│     ├─ All pushes logged with timestamp & user                               │
│     ├─ Image provenance tracked                                              │
│     ├─ Can query "who pushed what when"                                      │
│     └─ Full compliance trail for audits                                      │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 6: DEPLOYMENT TARGETS (ALL ENVIRONMENTS PULL SAME IMAGES)               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  DEVELOPMENT (Local Codespace)              STAGING (Cloud)                  │
│  ├─ Pull: cimp-api:v1.2.3                   ├─ Pull: cimp-api:v1.2.3         │
│  ├─ Pull: cimp-blazor:v1.2.3                ├─ Pull: cimp-blazor:v1.2.3       │
│  ├─ Pull: cimp-postgres:15.2                ├─ Pull: cimp-postgres:15.2       │
│  ├─ Run: docker-compose up                  ├─ Run: Kubernetes                │
│  ├─ Same behavior ✓                         ├─ Same behavior ✓                │
│  └─ No surprises ✓                          └─ No surprises ✓                 │
│                                                                               │
│  PRODUCTION (Cloud)                         QA (Automated Testing)            │
│  ├─ Pull: cimp-api:v1.2.3                   ├─ Pull: cimp-api:v1.2.3          │
│  ├─ Pull: cimp-blazor:v1.2.3                ├─ Pull: cimp-blazor:v1.2.3        │
│  ├─ Pull: cimp-postgres:15.2                ├─ Pull: cimp-postgres:15.2        │
│  ├─ Run: Azure Container Instances          ├─ Run: Automated tests           │
│  ├─ Same behavior ✓                         ├─ Same behavior ✓                │
│  └─ No surprises ✓                          └─ No surprises ✓                 │
│                                                                               │
│  KEY INSIGHT: All 4 environments use IDENTICAL images!                        │
│  ✓ Same version (v1.2.3)                                                    │
│  ✓ Same code compiled at exact same time                                     │
│  ✓ Same dependencies locked                                                  │
│  ✓ Same behavior guaranteed                                                  │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ TIER 7: MONITORING & OBSERVABILITY                                           │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Container Insights (Azure Monitor)                                          │
│  ├─ Monitor container logs                                                   │
│  ├─ Track resource usage (CPU, memory)                                       │
│  ├─ Application insights (APM)                                               │
│  └─ Alerts & notifications                                                   │
│                                                                               │
│  GitHub Actions Logs                                                         │
│  ├─ Build logs (complete history)                                            │
│  ├─ Test results                                                             │
│  ├─ Security scan reports                                                    │
│  └─ Deployment status                                                        │
│                                                                               │
│  ACR Logs                                                                     │
│  ├─ Image push/pull audit trail                                              │
│  ├─ Vulnerability scan results                                               │
│  ├─ User access logs                                                         │
│  └─ Compliance records                                                       │
│                                                                               │
│  Prometheus / Grafana (Optional)                                             │
│  ├─ Custom metrics                                                           │
│  ├─ Container dashboards                                                     │
│  ├─ Performance trending                                                     │
│  └─ Custom alerts                                                            │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW                                       │
└─────────────────────────────────────────────────────────────────────────────┘

SOURCE CODE CHANGES:
────────────────────
  Developer makes code changes in VS Code
              ↓
  Commit changes: git commit -m "Feature: Add new API endpoint"
              ↓
  Push to GitHub: git push origin main
              ↓
  GitHub receives webhook notification (push event)


CI/CD PIPELINE TRIGGERS:
─────────────────────────
  GitHub Actions detects push event
              ↓
  Reads: .github/workflows/build-acr.yml
              ↓
  Reads: Dockerfile (multiple)
              ↓
  Reads: GitHub Secrets (ACR credentials)
              ↓
  Reads: .devcontainer/devcontainer.json
              ↓
  Reads: package.json, project.csproj (dependencies)


BUILD EXECUTION:
────────────────
  Multi-stage Docker build for each image:
  
  Stage 1 (Base):
    FROM mcr.microsoft.com/dotnet/sdk:7.0 AS base
              ↓
    Install system dependencies
              ↓
    Copy csproj files
              ↓
  Stage 2 (Restore):
    Copy csproj into container
              ↓
    dotnet restore (downloads NuGet packages)
              ↓
    Uses package locks for version consistency
              ↓
  Stage 3 (Build):
    dotnet build (compiles code)
              ↓
    Runs unit tests
              ↓
    Generates binaries
              ↓
  Stage 4 (Runtime):
    FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
              ↓
    Copy binaries from build stage
              ↓
    Copy configuration files
              ↓
    Set environment variables
              ↓
    Final image size: ~150MB (optimized)


SECURITY SCANNING:
──────────────────
  Scan Docker images for vulnerabilities:
    ├─ trivy image cimp-api:build-xyz
    ├─ Check dependencies for CVEs
    ├─ Generate SBOM (Software Bill of Materials)
    └─ Report severity levels
          ↓
    If HIGH/CRITICAL found:
          ↓
    ❌ Block push to ACR
    ✉️ Notify developer
    📋 Create GitHub Issue
    🔧 Requires manual review & fix
          ↓
    If LOW/MEDIUM found:
          ↓
    ⚠️ Log warning
    ✅ Continue to push
          ↓
    If NONE found:
          ↓
    ✅ Approved
    → Continue to ACR push


AUTHENTICATION & PUSH:
──────────────────────
  GitHub Actions reads secrets:
    - ACR_LOGIN_SERVER (cimpregistry.azurecr.io)
    - ACR_USERNAME (service principal)
    - ACR_PASSWORD (encrypted token)
              ↓
  Authenticate to ACR:
    az acr login --name cimpregistry \
    --username $ACR_USERNAME \
    --password $ACR_PASSWORD
              ↓
  Tag images with versions:
    docker tag cimp-api:abc123 \
      cimpregistry.azurecr.io/cimp-api:v1.2.3
              ↓
  Push to ACR:
    docker push cimpregistry.azurecr.io/cimp-api:v1.2.3
              ↓
  Image stored in ACR with metadata


POST-PUSH SCANNING (ACR):
─────────────────────────
  ACR automatically scans pushed image:
    ├─ Trivy scanning (built-in)
    ├─ Check against CVE databases
    ├─ Generate report
    └─ Store results
          ↓
  ACR updates image metadata:
    ├─ Scan date/time
    ├─ Vulnerabilities found
    ├─ Severity distribution
    ├─ Remediation advice
    └─ Expiration alerts


PRODUCTION DEPLOYMENT:
──────────────────────
  Deployment workflow triggered (manual or automatic):
    ├─ Query ACR for image: v1.2.3
    ├─ Verify image exists
    ├─ Check scan results (should be clean)
              ↓
    Deploy to production:
    ├─ Azure Container Instances
    ├─ Kubernetes
    ├─ App Service
    └─ Docker Compose
              ↓
    Pull exact same image:
    docker pull cimpregistry.azurecr.io/cimp-api:v1.2.3
              ↓
    Start container with health checks:
    ├─ HTTP endpoint checks
    ├─ Database connectivity checks
    ├─ Dependency validation
    └─ Readiness probes


RUNTIME CONSISTENCY:
────────────────────
  All environments running:
    ├─ cimp-api:v1.2.3 (compiled at time T)
    ├─ cimp-blazor:v1.2.3 (compiled at time T)
    ├─ cimp-postgres:15.2 (specific version)
    └─ cimp-redis:7.0 (specific version)
              ↓
  Result:
    ✓ Development behaves exactly like production
    ✓ Staging behaves exactly like production
    ✓ No "works on my machine" problems
    ✓ Deployments are predictable
    ✓ Rollback is simple (just point to previous tag)
```

---

## 🔄 Environment Progression

```
DEVELOPMENT CYCLE:
──────────────────

Day 1:
  Morning: Developer starts Codespace
    Codespace pulls: cimp-api:v1.2.3
                    cimp-blazor:v1.2.3
                    cimp-postgres:15.2
    Result: Fresh environment, 2-3 minutes ✅
              ↓
  Work: Developer codes new feature
    - Modifies: CIMPPortal.Api/Handlers/PushHandler.cs
    - Modifies: CIMPPortal.Blazor/Pages/PushPage.razor
    - Local testing in Codespace containers
              ↓
  Afternoon: Ready to commit
    git add .
    git commit -m "feat: Add email notifications to push handler"
    git push origin feature/push-notifications
              ↓


Day 2:
  GitHub Actions triggered:
    - Build new images with code changes
    - Run all tests
    - Scan for security issues
    - Push to ACR as v1.2.4-beta.1
              ↓
  Code Review:
    - PR created & reviewed
    - Tests passed ✅
    - Security scan passed ✅
    - Approved for merge
              ↓
  Merge to main:
    - GitHub Actions builds again
    - Creates images v1.2.4
    - Tags as "latest" for staging
              ↓


Day 3:
  Staging Validation:
    - Staging environment pulls v1.2.4
    - QA team tests feature
    - Performance benchmarks run
    - Everything looks good ✅
              ↓
  Production Release:
    - Manual approval (or automatic schedule)
    - Production pulls exact same v1.2.4 image
    - Blue-green deployment (zero downtime)
    - Health checks pass ✅
    - Feature live! 🎉
              ↓
  Monitoring:
    - Azure Monitor tracks
    - Application Insights logs
    - Alerts for any issues
    - Everything runs smoothly ✓


If issues discovered in production:
    - Rollback: Production points to v1.2.3
    - Immediate fix: cimp-api:v1.2.5
    - Redeploy: Same image as working version
    - Zero version inconsistency ✓
```

---

## 📈 Complete Version Management

```
ACR REGISTRY TIMELINE:
─────────────────────

Week 1:
  v1.0.0
  ├─ Initial release
  ├─ Base API endpoints
  ├─ Basic Blazor UI
  └─ PostgreSQL schema v1
              ↓

Week 2:
  v1.1.0
  ├─ New: User management APIs
  ├─ New: Role-based access control
  ├─ Fix: Database performance
  └─ All images tagged v1.1.0 in ACR
              ↓

Week 3:
  v1.2.0
  ├─ New: Push handler improvements
  ├─ New: Real-time notifications
  ├─ Fix: Memory leak in Blazor
  ├─ Fix: SQL injection vulnerability
  └─ v1.2.0 images in ACR
              ↓

Week 4:
  v1.2.1 (hotfix)
  ├─ Fix: Critical security issue found in production
  ├─ Only patch: cimp-api changed
  ├─ cimp-blazor: v1.2.0 (reused)
  ├─ cimp-postgres: v1.2.0 (reused)
  └─ ACR stores only changed image, references others
              ↓

At any point in time, you can:
  ✓ Instantly deploy any previous version
  ✓ Know exactly what was in each version
  ✓ Compare versions (diff)
  ✓ Rollback in seconds (just change tag in deployment)
  ✓ Run multiple versions simultaneously (for testing)
  ✓ Audit who deployed what when
```

---

## 🎯 Key Decision Points

```
WORKFLOW DECISION TREE:
──────────────────────

Code changes pushed to GitHub
            ↓
        ┌───┴────────────────────┐
        │ GitHub Actions          │
        │ Automated Build         │
        └───┬────────────────────┘
            ↓
    ┌───────────────┐
    │  Tests FAIL?  │
    └───┬─────────┬─┘
        │         │
       NO        YES
        │         │
        ↓         ↓
    Continue   ❌ STOP
        │      Notify Dev
        ↓      Logs: Full output
        │      Action: Fix code
    ┌───────────────┐
    │Scan FAIL?     │
    │ (Security)    │
    └───┬─────────┬─┘
        │         │
       NO        YES
        │         │
        ↓         ↓
    Continue   ⚠️ QUARANTINE
        │      Review findings
        ↓      Action: Fix vulns
    ┌───────────────┐
    │  ACR PUSH     │
    │  (Success)    │
    └───┬───────────┘
        ↓
    ┌───────────────────────────────┐
    │ Image in ACR with tags:        │
    │ - v1.2.3 (semantic version)    │
    │ - latest (always newest)       │
    │ - stable (production ready)    │
    │ - sha256:abc123... (immutable) │
    └───┬───────────────────────────┘
        ↓
    Manual Approval Gate (Optional)
        ↓
    ┌──────────────────────────────────────┐
    │ DEPLOY DECISION:                      │
    │                                       │
    │ Option 1: Auto-deploy to staging     │
    │ Option 2: Manual deploy when ready   │
    │ Option 3: Scheduled deployment       │
    └──┬──────────────────┬────────┬───────┘
       │                  │        │
    Auto            Manual     Scheduled
       │                  │        │
       ↓                  ↓        ↓
    Staging           Staging    Staging
       │                  │        │
       ↓                  ↓        ↓
    ┌──────────────────────────────────┐
    │ STAGING VALIDATION:               │
    │ - Pull exact image from ACR       │
    │ - Run integration tests           │
    │ - Performance benchmarks          │
    │ - QA approval                     │
    └──┬──────────────┬──────────────────┘
       │              │
    Approved      Issues Found
       │              │
       ↓              ↓
    Continue      ↻ Back to Dev
       │              (Fix & rebuild)
       ↓
    ┌──────────────────────────────────┐
    │ PRODUCTION DEPLOY:                │
    │ - Pull EXACT same image from ACR │
    │ - Zero variance from staging      │
    │ - Blue-green deployment           │
    │ - Health checks                   │
    │ - Rollback plan ready             │
    └────┬──────────────────────────────┘
         ↓
    LIVE IN PRODUCTION ✅
         ↓
    ┌──────────────────────────────────┐
    │ MONITORING:                       │
    │ - Azure Monitor                   │
    │ - Application Insights            │
    │ - Alerts & notifications          │
    │ - Error tracking                  │
    │ - Performance metrics             │
    └──────────────────────────────────┘
```

---

## 📋 Complete File Dependencies

```
ALL FILES WORK TOGETHER:
───────────────────────

Repository Root
│
├─ .devcontainer/
│  ├─ devcontainer.json  ◄─── Defines Codespace configuration
│  │                           - Which Docker images to use
│  │                           - Which features to install
│  │                           - Port forwarding setup
│  │                           - Post-create script call
│  │
│  └─ post-create.sh  ◄─────── Auto-setup script runs after Codespace starts
│                               - Pulls images from ACR
│                               - Runs docker-compose up
│                               - Initializes database
│                               - Seeds test data
│
├─ .github/
│  └─ workflows/
│     ├─ build-acr.yml  ◄───── Builds images & pushes to ACR
│     │                         - Triggers on push to main/develop
│     │                         - Reads Dockerfiles
│     │                         - Reads GitHub Secrets
│     │                         - Pushes to ACR
│     │
│     ├─ test.yml  ◄──────────── Runs automated tests
│     │                          - Unit tests: dotnet test
│     │                          - Integration tests
│     │                          - API tests: curl/Postman
│     │
│     ├─ scan.yml  ◄──────────── Security scanning
│     │                          - Trivy vulnerability scan
│     │                          - Secret scanning (gitguardian)
│     │                          - SAST analysis (CodeQL)
│     │
│     └─ deploy.yml  ◄────────── Production deployment
│                                - Pulls image from ACR
│                                - Deploys to Azure
│                                - Runs health checks
│                                - Notifies on success
│
├─ CIMPPortal.Api/
│  └─ Dockerfile  ◄──────────── Builds API image
│     │                         - Multi-stage build
│     │                         - .NET 7 SDK base
│     │                         - Restores NuGet packages
│     │                         - Builds binaries
│     │                         - Runs as aspnet runtime
│     │                         - Final image: cimpregistry.azurecr.io/cimp-api:v1.2.3
│     │
│     ├─ CIMPPortal.Api.csproj  ◄─── Defines dependencies
│     │  └─ package locks (.csproj references)
│     │
│     └─ src/
│        └─ Program.cs, Controllers, etc.  ◄─── Source code
│
├─ CIMPPortal.Blazor/
│  └─ Dockerfile  ◄──────────── Builds Blazor UI image
│     │                         - Multi-stage build
│     │                         - Node.js for frontend build tools
│     │                         - .NET runtime for serving
│     │                         - Final image: cimpregistry.azurecr.io/cimp-blazor:v1.2.3
│     │
│     ├─ CIMPPortal.Blazor.csproj  ◄─── C# dependencies
│     │
│     └─ Pages/, Components/, wwwroot/  ◄─── Razor components & assets
│
├─ docker-compose.yml  ◄───────── Local orchestration
│  │                              - References ACR images
│  │                              - Defines services: API, Blazor, DB, Cache
│  │                              - Port mappings
│  │                              - Volume mounts
│  │                              - Environment variables
│  │                              - Health checks
│  │                              - Dependency order
│  │
│  └─ Used by:
│     ├─ devcontainer post-create.sh (runs on Codespace start)
│     ├─ Local development (docker-compose up)
│     └─ CI/CD for integration tests
│
├─ .env.example  ◄────────────── Environment variables template
│  │                             - ACR login server
│  │                             - Database credentials
│  │                             - API keys
│  │                             - Feature flags
│  │
│  └─ Used by:
│     ├─ docker-compose.yml (env_file)
│     ├─ GitHub Actions workflows (ACR_*)
│     └─ Local .env file (created by developers)
│
├─ versions.lock.yml  ◄────────── Version pinning
│  │                              - API version: v1.2.3
│  │                              - Blazor version: v1.2.3
│  │                              - PostgreSQL: 15.2
│  │                              - Redis: 7.0
│  │                              - .NET SDK: 7.0.5
│  │                              - NuGet packages: locked
│  │
│  └─ Ensures consistency:
│     ├─ All developers use same versions
│     ├─ CI/CD uses same versions
│     ├─ Staging uses same versions
│     └─ Production uses same versions
│
└─ GitHub Secrets (stored securely)  ◄─── Authentication credentials
   ├─ ACR_LOGIN_SERVER  ────► cimpregistry.azurecr.io
   ├─ ACR_USERNAME  ────────► service-principal-name
   ├─ ACR_PASSWORD  ────────► encrypted-token
   ├─ ACR_REGISTRY_NAME  ──► cimpregistry
   └─ Used by: build-acr.yml (GitHub Actions)
              to authenticate to ACR and push images


HOW THEY CONNECT:
──────────────────

1. Developer pushes code
         ↓
2. GitHub webhook triggers build-acr.yml
         ↓
3. Workflow reads GitHub Secrets (credentials)
         ↓
4. Workflow reads Dockerfiles (build instructions)
         ↓
5. Dockerfiles reference .csproj files (dependencies)
         ↓
6. Images built and tagged (v1.2.3)
         ↓
7. Workflow pushes to ACR using credentials
         ↓
8. devcontainer.json tells Codespace to pull images from ACR
         ↓
9. post-create.sh starts services using docker-compose.yml
         ↓
10. docker-compose.yml references ACR images
         ↓
11. Development environment ready to code! ✅

The entire workflow is connected through:
- File references (Dockerfiles → .csproj → source code)
- Configuration links (devcontainer.json → post-create.sh → docker-compose.yml)
- Credentials (GitHub Secrets → ACR authentication)
- Version pinning (versions.lock.yml → all components)
```

---

## 🚀 Quick Reference: What Each Tool Does

```
TOOL                          WHAT IT DOES                        WHEN IT RUNS
─────────────────────────────────────────────────────────────────────────────

VS Code                       Edit code, git operations          During development
Git / GitHub CLI              Version control, push/pull         Developer commits
GitHub                        Repository, webhooks, triggers     Always available
GitHub Actions                Run CI/CD pipeline                 On push event
Docker Desktop (local)        Build images locally               Developer testing
Docker (in cloud)             Run containers                     Everywhere
Dockerfile (API)              Instructions to build API image    In GitHub Actions
Dockerfile (Blazor)           Instructions to build UI image     In GitHub Actions
dotnet CLI                    Build C# projects                  In build process
Azure CLI                      Authenticate to ACR               In GitHub Actions
Trivy                         Scan images for vulnerabilities    After build, Before push
ACR (Registry)                Store & serve images               Production
Codespaces                    Cloud development environment      On demand
devcontainer.json             Configure Codespace                When Codespace starts
post-create.sh                Setup Codespace automatically      When Codespace starts
docker-compose.yml            Orchestrate containers             Dev & CI/CD
Kubernetes / Container Apps   Deploy to cloud                    Production deployment
Azure Monitor                 Track running containers           Continuous monitoring
```

---

This is your **complete, production-grade workflow**! Every tool plays a role in ensuring version consistency across all environments. 🎯
