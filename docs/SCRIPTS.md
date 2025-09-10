# Scripts Reference

This document provides detailed information about all scripts included in the SDD template.

## 📁 Script Locations

All scripts are located in the `scripts/` directory and should be executed from there:

```bash
cd scripts
./script-name.sh [arguments]
```

## 🔧 Scripts Overview

### 1. setup-org-properties.sh

**Purpose**: Create or update organization custom properties for SDD workflow.

**Usage**:
```bash
./setup-org-properties.sh [ORGANIZATION]
```

**Arguments**:
- `ORGANIZATION` (optional): GitHub organization name. If not provided, auto-detects from current repository.

**What it does**:
1. Checks for existing custom properties in the organization
2. Creates or updates three properties using upsert logic:
   - `role`: single_select (spec|feature) - optional
   - `spec`: string - optional  
   - `instructions`: string - optional
3. Verifies successful creation/update

**Requirements**:
- GitHub CLI authenticated with `admin:org` scope
- Organization admin permissions

**Example**:
```bash
# Auto-detect organization from current repo
./setup-org-properties.sh

# Specify organization explicitly  
./setup-org-properties.sh MyOrganization
```

**Output Example**:
```
GitHub Organization Custom Properties Setup
Organization: MyOrg

Step 1: Checking existing properties...
❌ Property 'role' does not exist
❌ Property 'spec' does not exist  
❌ Property 'instructions' does not exist

Step 2: Creating/updating 'role' property...
Creating new role property with values: spec, feature (non-required)
✅ Successfully created 'role' property

Step 3: Creating/updating 'spec' property...
Creating new spec property (string type, optional)
✅ Successfully created 'spec' property

Step 4: Creating/updating 'instructions' property...
Creating new instructions property (string type, optional)
✅ Successfully created 'instructions' property

✅ Custom properties setup completed!
```

---

### 2. setup-github-auth.sh

**Purpose**: Configure GitHub CLI authentication with all required scopes for SDD operations.

**Usage**:
```bash
./setup-github-auth.sh
```

**What it does**:
1. Checks if GitHub CLI is installed
2. Lists required scopes for SDD operations
3. Prompts for confirmation before authentication
4. Initiates device flow authentication with comprehensive scopes
5. Verifies successful authentication

**Required Scopes**:
- `repo`: Repository access
- `delete_repo`: Repository deletion (for cleanup)
- `admin:org`: Organization administration
- `read:org`: Organization reading  
- `workflow`: GitHub Actions workflows
- `gist`: Gist access

**Example**:
```bash
./setup-github-auth.sh
```

**Output Example**:
```
GitHub CLI Authentication Setup

Required scopes for SDD operations:
• repo - Repository access and management
• delete_repo - Repository deletion (for cleanup scripts)
• admin:org - Organization administration (for custom properties)
• read:org - Organization reading
• workflow - GitHub Actions workflows
• gist - Gist access

Do you want to proceed with authentication? (y/N): y

Starting GitHub CLI authentication...
✅ Authentication completed successfully!

Current authentication status:
github.com
  ✓ Logged in to github.com as username (oauth_token)
  ✓ Git operations for github.com configured to use https protocol.
```

---

### 3. delete-test-repos.sh

**Purpose**: Clean up repositories that start with 'test' to maintain organization hygiene.

**Usage**:
```bash
./delete-test-repos.sh [OWNER]
```

**Arguments**:
- `OWNER` (optional): Repository owner (organization or user). Auto-detects from current repository if not provided.

**What it does**:
1. Auto-detects repository owner from current Git repository
2. Lists all repositories starting with 'test'
3. Shows repository details (name, private/public, last updated)
4. Asks for confirmation before each deletion
5. Provides progress feedback during deletion

**Safety Features**:
- Interactive confirmation for each repository
- Shows repository information before deletion
- Graceful error handling for permission issues
- Option to skip repositories during batch operations

**Example**:
```bash
# Auto-detect owner
./delete-test-repos.sh

# Specify owner explicitly
./delete-test-repos.sh MyOrganization
```

**Output Example**:
```
Repository Cleanup Tool
Owner: MyOrg

Found 3 repositories starting with 'test':

Repository: test-feature-auth
  Private: false
  Updated: 2024-01-15T10:30:00Z
  Delete this repository? (y/N): y
  ✅ Successfully deleted test-feature-auth

Repository: test-spec-validation  
  Private: true
  Updated: 2024-01-14T15:45:00Z
  Delete this repository? (y/N): n
  ⏭️ Skipped test-spec-validation

✅ Cleanup completed! Processed 3 repositories.
```

---

### 4. github-app-device-flow.sh

**Purpose**: Implement GitHub App device flow authentication to obtain user access tokens.

**Usage**:
```bash
./github-app-device-flow.sh APP_ID CLIENT_ID
```

**Arguments**:
- `APP_ID`: GitHub App ID (found in app settings)
- `CLIENT_ID`: GitHub App Client ID (found in app settings)

**What it does**:
1. Initiates device flow with GitHub App
2. Displays user code and verification URL
3. Polls for authorization completion
4. Retrieves and displays access token
5. Uses only standard shell tools (no jq dependency)

**Requirements**:
- GitHub App created and configured
- App installed in target organization
- Standard shell tools: `curl`, `grep`, `cut`

**Example**:
```bash
./github-app-device-flow.sh 123456 Iv1.a1b2c3d4e5f6g7h8
```

**Output Example**:
```
Starting GitHub App Device Flow Authentication

Please visit: https://github.com/login/device
Enter user code: ABCD-1234

Waiting for authorization...
⏳ Polling for authorization (attempt 1/120)...
⏳ Polling for authorization (attempt 2/120)...
✅ Authorization successful!

Access Token: ghu_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

You can now use this token to authenticate API requests.
```

## 🔧 Script Dependencies

### System Requirements
- **Bash**: All scripts require Bash shell
- **Git**: Required for repository operations and auto-detection
- **curl**: Used for API calls in device flow script

### External Tools
- **GitHub CLI (gh)**: Required for most operations
  - Installation: https://cli.github.com/
  - Minimum version: 2.0.0+

### Environment Variables
Scripts may use these environment variables:
- `GH_TOKEN`: GitHub token for API authentication
- `GITHUB_TOKEN`: Alternative token variable name

## 🛠️ Customization

### Modifying Scripts

All scripts are designed to be customizable. Common modifications:

#### 1. Adding New Custom Properties

Edit `setup-org-properties.sh` to add new properties:

```bash
# Add after existing properties
# Create new_property if it doesn't exist
if [ "$NEW_PROPERTY_EXISTS" = false ]; then
    echo -e "${YELLOW}Step X: Creating 'new_property' property...${NC}"
    
    NEW_PROPERTY_PAYLOAD='{
        "value_type": "string",
        "description": "Description of new property",
        "required": false
    }'
    
    if ! create_property "new_property" "$NEW_PROPERTY_PAYLOAD"; then
        exit 1
    fi
fi
```

#### 2. Changing Repository Patterns

Edit `delete-test-repos.sh` to change repository matching pattern:

```bash
# Change from repositories starting with 'test' to 'temp'
REPOS=$(gh repo list "$OWNER" --limit 1000 --json name,isPrivate,updatedAt \
    --jq '.[] | select(.name | startswith("temp")) | {name: .name, private: .isPrivate, updated: .updatedAt}')
```

#### 3. Adding Authentication Scopes

Edit `setup-github-auth.sh` to add more scopes:

```bash
# Add new scopes to the SCOPES array
SCOPES=(
    "repo"
    "delete_repo" 
    "admin:org"
    "read:org"
    "workflow"
    "gist"
    "user"              # Add user scope
    "notifications"     # Add notifications scope
)
```

### Testing Scripts

Always test script modifications in a safe environment:

```bash
# Test with dry-run or echo commands
# Example: Add --dry-run flag support
if [ "$1" = "--dry-run" ]; then
    echo "DRY RUN: Would delete repository $REPO_NAME"
else
    gh repo delete "$OWNER/$REPO_NAME" --confirm
fi
```

## 🔍 Troubleshooting Scripts

### Common Script Issues

#### 1. Permission Denied
```bash
# Fix script permissions
chmod +x scripts/*.sh
```

#### 2. Command Not Found (gh)
```bash
# Install GitHub CLI
# macOS: brew install gh
# Ubuntu: sudo apt install gh
# Or visit: https://cli.github.com/
```

#### 3. Authentication Errors
```bash
# Check current authentication
gh auth status

# Re-authenticate if needed
gh auth login

# Or use setup script
./setup-github-auth.sh
```

#### 4. API Rate Limiting
Scripts handle rate limiting, but for manual debugging:
```bash
# Check rate limit status
gh api /rate_limit
```

### Debug Mode

Enable debug mode for any script:
```bash
# Run with debug output
bash -x ./script-name.sh

# Or add to script temporarily
#!/bin/bash
set -x  # Enable debug mode
```

## 📝 Contributing to Scripts

When modifying or contributing scripts:

1. **Follow bash best practices**:
   - Use `set -e` for error handling
   - Quote variables: `"$VARIABLE"`
   - Use arrays for lists: `ITEMS=("item1" "item2")`

2. **Add error handling**:
   ```bash
   if ! command_that_might_fail; then
       echo "Error: Command failed"
       exit 1
   fi
   ```

3. **Include usage information**:
   ```bash
   usage() {
       echo "Usage: $0 [options]"
       echo "Description of what the script does"
       exit 1
   }
   ```

4. **Test thoroughly**:
   - Test with various input scenarios
   - Test error conditions
   - Verify cleanup on script exit
