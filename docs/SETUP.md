# SDD Template Setup Guide

This guide provides step-by-step instructions for setting up the Spec-Driven Development template in your organization.

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] **GitHub organization** or personal account with admin permissions
- [ ] **GitHub CLI** installed: [Installation Guide](https://cli.github.com/)
- [ ] **Git** installed and configured
- [ ] **Bash shell** (Linux/macOS/WSL on Windows)

## 🚀 Initial Setup (One-time per Organization)

### Step 1: Fork the Repository

1. Fork this repository to your organization/account
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_ORG/sdd-template.git
   cd sdd-template
   ```

### Step 2: Set Up GitHub CLI Authentication

Run the authentication setup script:

```bash
cd scripts
./setup-github-auth.sh
```

This script will:
- Check if GitHub CLI is installed
- Authenticate with comprehensive scopes:
  - `repo` - Repository access
  - `delete_repo` - Repository deletion (for cleanup scripts)
  - `admin:org` - Organization administration
  - `read:org` - Organization reading
  - `workflow` - GitHub Actions workflows
  - `gist` - Gist access
- Verify authentication status

**Manual Alternative:**
```bash
gh auth login --scopes "repo,delete_repo,admin:org,read:org,workflow,gist"
```

### Step 3: Create Organization Custom Properties

Run the organization properties setup:

```bash
./setup-org-properties.sh
```

This will create three custom properties in your organization:
- **role**: `single_select` (spec|feature) - optional
- **spec**: `string` - optional, for specification repository reference
- **instructions**: `string` - optional, for source of truth template

**Verification:**
- Go to GitHub.com → Your Organization → Settings → Repository custom properties
- Verify all three properties are listed

### Step 4: Configure Workflow Authentication

⚠️ **IMPORTANT**: The workflow currently uses a hardcoded token that needs to be replaced.

#### Option A: Use Personal Access Token (Recommended)

1. Create a Personal Access Token:
   - Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with scopes: `repo`, `admin:org`, `workflow`
   - Copy the token

2. Add as repository secret:
   - Go to your forked repository → Settings → Secrets and variables → Actions
   - Create new repository secret named `SETUP_TOKEN`
   - Paste your token

3. Update the workflow file:
   ```yaml
   # In .github/workflows/setup-repository-properties.yml
   # Replace the hardcoded token line with:
   echo "token=${{ secrets.SETUP_TOKEN }}" >> $GITHUB_OUTPUT
   ```

#### Option B: Use GitHub App (Advanced)

1. Create a GitHub App:
   - Go to Organization Settings → Developer settings → GitHub Apps
   - Create new GitHub App with permissions:
     - Repository permissions: Contents (Read), Metadata (Read), Custom properties (Write)
     - Organization permissions: Custom properties (Read)

2. Install the app to your organization

3. Use the device flow script:
   ```bash
   ./github-app-device-flow.sh YOUR_APP_ID YOUR_CLIENT_ID
   ```

### Step 5: Test the Setup

1. Create a test repository from your template:
   ```bash
   gh repo create YOUR_ORG/test-sdd-setup --template YOUR_ORG/sdd-template
   cd test-sdd-setup
   echo "# Test" > README.md
   git add README.md
   git commit -m "Initial commit"
   git push
   ```

2. Check if properties were set automatically:
   ```bash
   gh api "/repos/YOUR_ORG/test-sdd-setup/properties/values"
   ```

3. Clean up test repository:
   ```bash
   cd ../sdd-template/scripts
   ./delete-test-repos.sh
   ```

## 🔧 Configuration Options

### Workflow Triggers

The setup workflow supports two trigger modes:

1. **Automatic**: Runs on first push to main branch
2. **Manual**: Can be triggered via GitHub Actions UI

To modify triggers, edit `.github/workflows/setup-repository-properties.yml`:

```yaml
on:
  push:
    branches: [main]          # Automatic on push
  workflow_dispatch:          # Manual trigger
    inputs:
      force_run:
        description: 'Force run even if properties exist'
        required: false
        default: false
        type: boolean
```

### Custom Property Definitions

To modify property definitions, edit `scripts/setup-org-properties.sh`:

```bash
# Example: Make role property required
ROLE_PAYLOAD='{
    "value_type": "single_select",
    "description": "Repository type in SDD workflow (spec or feature)",
    "required": true,                    # Changed to true
    "default_value": "spec",             # Add default when required
    "allowed_values": ["spec", "feature"]
}'
```

## 🛠️ Maintenance

### Updating Properties

To update existing properties, simply run:
```bash
cd scripts
./setup-org-properties.sh
```

The script uses upsert logic - it will update existing properties or create new ones.

### Cleaning Up Test Repositories

Regularly clean up test repositories:
```bash
cd scripts
./delete-test-repos.sh
```

This script will:
- List all repositories starting with 'test'
- Ask for confirmation before deletion
- Show progress during cleanup

### Updating Scripts

When updating scripts, ensure they remain executable:
```bash
chmod +x scripts/*.sh
```

## 🔍 Troubleshooting

### Common Issues

#### 1. "Permission denied" errors
**Cause**: Missing organization admin permissions or insufficient token scopes.

**Solution**: 
- Verify you have admin permissions in the organization
- Re-run `./setup-github-auth.sh` with all required scopes
- Check token scopes: `gh auth status`

#### 2. "Property already exists" errors
**Cause**: Custom properties already exist (this is normal).

**Solution**: The script handles this automatically with upsert logic.

#### 3. Workflow fails with 403 errors
**Cause**: Workflow token lacks required permissions.

**Solution**: 
- Update workflow token as described in Step 4
- Ensure token has `admin:org` scope for custom properties

#### 4. Template repository not detected
**Cause**: Repository wasn't created from template or API access issues.

**Solution**: 
- Verify repository was created using "Use this template"
- Check GitHub API access: `gh api /repos/OWNER/REPO`
- Manual property setting may be required

### Debug Commands

```bash
# Check GitHub CLI authentication
gh auth status

# Verify organization access
gh api /orgs/YOUR_ORG

# List organization properties
gh api /orgs/YOUR_ORG/properties/schema

# Check repository properties
gh api /repos/YOUR_ORG/YOUR_REPO/properties/values

# Test template detection
gh api /repos/YOUR_ORG/YOUR_REPO --jq '.template_repository.full_name // "no_template"'
```

## 📞 Getting Help

If you encounter issues not covered here:

1. Check the [Scripts Reference](SCRIPTS.md) for detailed script documentation
2. Review the [Workflows Guide](WORKFLOWS.md) for workflow-specific issues
3. Open an issue in the repository with:
   - Your organization/repository setup
   - Error messages or logs
   - Steps to reproduce the issue
