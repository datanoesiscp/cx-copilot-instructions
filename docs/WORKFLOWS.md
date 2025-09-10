# Workflows Documentation

This document explains the GitHub Actions workflows included in the SDD template and how to customize them.

## 📁 Workflow Location

Workflows are located in `.github/workflows/` directory:

```
.github/
└── workflows/
    └── setup-repository-properties.yml
```

## 🔄 setup-repository-properties.yml

### Purpose

Automatically configures custom repository properties when a new repository is created from the SDD template.

### Triggers

The workflow supports two trigger types:

#### 1. Automatic Trigger
```yaml
on:
  push:
    branches: [main]
```
- Runs on push to the main branch
- Only executes on the first push (`github.run_number == 1`)
- Ideal for repositories created from templates

#### 2. Manual Trigger
```yaml
on:
  workflow_dispatch:
    inputs:
      force_run:
        description: 'Force run even if properties exist'
        required: false
        default: false
        type: boolean
```
- Can be triggered manually from GitHub Actions UI
- Includes optional `force_run` parameter to override existing properties
- Useful for testing or re-configuring repositories

### Workflow Steps

#### Step 1: Checkout Repository
```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```
Checks out the repository code for the workflow to access.

#### Step 2: Setup Authentication
```yaml
- name: Setup Authentication
  id: setup_auth
  run: |
    echo "Using user access token"
    echo "token=${{ secrets.SETUP_TOKEN }}" >> $GITHUB_OUTPUT
    echo "auth_type=user_token" >> $GITHUB_OUTPUT
```

**⚠️ Configuration Required**: Replace `secrets.SETUP_TOKEN` with your token.

**Setup Instructions**:
1. Create Personal Access Token with scopes: `repo`, `admin:org`, `workflow`
2. Add as repository secret named `SETUP_TOKEN`
3. Or use hardcoded token for testing (not recommended for production)

#### Step 3: Debug Authentication
```yaml
- name: Debug Authentication and Permissions
  run: |
    echo "Repository owner: ${{ github.repository_owner }}"
    echo "Authentication type: ${{ steps.setup_auth.outputs.auth_type }}"
    gh api /user --jq '{login: .login, type: .type}'
    gh api "/repos/${{ github.repository }}" --jq '{name: .name, permissions: .permissions}'
```

Provides debugging information for troubleshooting authentication issues.

#### Step 4: Check Existing Properties
```yaml
- name: Check if properties already exist
  id: check_properties
  run: |
    if gh api "/repos/${{ github.repository }}/properties/values" --jq '.[].property_name' | grep -q "role"; then
      echo "has_properties=true" >> $GITHUB_OUTPUT
    else
      echo "has_properties=false" >> $GITHUB_OUTPUT
    fi
```

Checks if custom properties are already set to avoid unnecessary overwrites.

#### Step 5: Set Repository Properties
```yaml
- name: Set repository properties automatically
  if: steps.check_properties.outputs.has_properties == 'false' || github.event.inputs.force_run == 'true'
```

**Conditional Execution**: Only runs when:
- Properties don't exist, OR
- Manual trigger with `force_run=true`

**Property Configuration**:

1. **Template Detection**:
   ```bash
   TEMPLATE_REPO=$(gh api "/repos/${{ github.repository }}" --jq '.template_repository.full_name // empty')
   ```
   - Automatically detects the source template repository
   - Used to set the `instructions` property

2. **Property Values**:
   - `role`: "spec" (default for new repositories)
   - `spec`: null (no parent specification)
   - `instructions`: Auto-detected template repository or unset

3. **API Call**:
   ```bash
   JSON_PAYLOAD='{"properties":[{"property_name":"role","value":"spec"},{"property_name":"spec","value":null},{"property_name":"instructions","value":"TEMPLATE_REPO"}]}'
   echo "$JSON_PAYLOAD" | gh api --method PATCH "/repos/${{ github.repository }}/properties/values" --input -
   ```

### Environment Variables

The workflow uses these environment variables:

- `GH_TOKEN`: GitHub token for API authentication
- `github.repository`: Full repository name (owner/repo)
- `github.repository_owner`: Repository owner
- `github.run_number`: Sequential run number
- `github.event_name`: Trigger event type

### Property Logic

#### For Repositories Created from Template
```yaml
role: "spec"
spec: null
instructions: "SourceOrg/source-template-name"  # Auto-detected
```

#### For Repositories Without Template Detection
```yaml
role: "spec" 
spec: null
# instructions property is not set
```

## 🔧 Customization

### Changing Default Property Values

Edit the property setting section:

```yaml
# Modify default values
REPO_ROLE="feature"        # Change default from "spec" to "feature"
REPO_SPEC="MyOrg/my-spec"  # Set a default spec repository
```

### Adding New Properties

1. First, create the property in organization settings using `setup-org-properties.sh`

2. Add to the workflow JSON payload:
```yaml
JSON_PAYLOAD='{"properties":[
  {"property_name":"role","value":"'$REPO_ROLE'"},
  {"property_name":"spec","value":'$REPO_SPEC'},
  {"property_name":"instructions","value":"'$REPO_INSTRUCTIONS'"},
  {"property_name":"new_property","value":"'$NEW_VALUE'"}
]}'
```

### Conditional Property Setting

Set different properties based on repository name or other conditions:

```yaml
# Set role based on repository name pattern
if [[ "${{ github.repository }}" == *"-spec" ]]; then
  REPO_ROLE="spec"
elif [[ "${{ github.repository }}" == *"-feature" ]]; then
  REPO_ROLE="feature"
else
  REPO_ROLE="spec"  # default
fi
```

### Advanced Template Detection

Handle multiple template repositories:

```yaml
# Detect template and set different instructions
TEMPLATE_REPO=$(gh api "/repos/${{ github.repository }}" --jq '.template_repository.full_name // empty')

case "$TEMPLATE_REPO" in
  "*/sdd-template")
    REPO_INSTRUCTIONS="$TEMPLATE_REPO"
    ;;
  "*/feature-template")
    REPO_INSTRUCTIONS="$TEMPLATE_REPO"
    REPO_ROLE="feature"
    ;;
  *)
    REPO_INSTRUCTIONS=""
    ;;
esac
```

## 🔍 Troubleshooting Workflows

### Common Issues

#### 1. Authentication Failures (403 Errors)

**Symptoms**:
```
gh: HTTP 403: Resource not accessible by integration
```

**Solutions**:
- Verify token has `admin:org` scope for custom properties
- Check token permissions: `gh auth status`
- Ensure token is added as repository secret
- Verify organization membership and permissions

#### 2. Property Not Found Errors

**Symptoms**:
```
Custom property 'role' is not defined for this organization
```

**Solutions**:
- Run `scripts/setup-org-properties.sh` to create properties
- Verify properties exist in organization settings
- Check property names match exactly (case-sensitive)

#### 3. Template Detection Issues

**Symptoms**:
```
Could not detect template repository - instructions property will be left unset
```

**Cause**: Repository wasn't created from template or API access issues.

**Solutions**:
- Verify repository was created using "Use this template" button
- Check repository settings for template information
- Manual property setting may be required

#### 4. Workflow Not Triggering

**Symptoms**: Workflow doesn't run on first push.

**Solutions**:
- Check workflow syntax: `gh workflow list`
- Verify trigger conditions in workflow file
- Check repository permissions for Actions
- Look for workflow errors in Actions tab

### Debugging Workflows

#### 1. Enable Debug Logging

Add to workflow environment:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

#### 2. Add Debug Steps

```yaml
- name: Debug Repository Information
  run: |
    echo "Repository: ${{ github.repository }}"
    echo "Owner: ${{ github.repository_owner }}"
    echo "Run Number: ${{ github.run_number }}"
    echo "Event: ${{ github.event_name }}"
    gh api "/repos/${{ github.repository }}" --jq '.'
```

#### 3. Test API Calls

```yaml
- name: Test API Access
  run: |
    echo "Testing user access..."
    gh api /user
    echo "Testing repo access..."  
    gh api "/repos/${{ github.repository }}"
    echo "Testing org properties access..."
    gh api "/orgs/${{ github.repository_owner }}/properties/schema"
```

## 🚀 Advanced Workflows

### Multi-Environment Setup

Create different workflows for different environments:

```yaml
# .github/workflows/setup-dev-properties.yml
name: Setup Development Properties
on:
  push:
    branches: [develop]
  
# .github/workflows/setup-prod-properties.yml  
name: Setup Production Properties
on:
  push:
    branches: [main]
```

### Conditional Execution Based on Files

Only run when specific files change:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'docs/**'
      - '!README.md'
```

### Integration with Other Workflows

Chain workflows together:

```yaml
# Trigger after property setup
name: Post-Setup Actions
on:
  workflow_run:
    workflows: ["Setup Repository Properties"]
    types: [completed]
```

### Matrix Builds for Multiple Configurations

```yaml
strategy:
  matrix:
    role: [spec, feature]
    environment: [dev, prod]
steps:
  - name: Set properties for ${{ matrix.role }} in ${{ matrix.environment }}
    run: |
      # Set properties based on matrix values
```

## 📋 Workflow Best Practices

### 1. Security
- Use repository secrets for tokens
- Limit token permissions to minimum required
- Regular token rotation
- Avoid logging sensitive information

### 2. Reliability
- Add proper error handling
- Use conditional execution to avoid unnecessary runs
- Include retry logic for API calls
- Validate inputs and outputs

### 3. Maintainability
- Use clear step names and descriptions
- Add comments for complex logic  
- Version pin action dependencies
- Document customizations

### 4. Performance
- Cache dependencies when possible
- Minimize API calls
- Use efficient GitHub API queries
- Parallel execution where appropriate

## 📝 Contributing Workflow Changes

When modifying workflows:

1. **Test in a fork first**
2. **Use semantic commit messages**
3. **Document breaking changes**
4. **Update this documentation**
5. **Test with both trigger types**
6. **Verify with different repository configurations**
