#!/bin/bash

# Script to create custom repository properties for SDD template
# Creates 'role' and 'spec' properties in the specified GitHub organization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [ORGANIZATION]"
    echo ""
    echo "Arguments:"
    echo "  ORGANIZATION  - GitHub organization name (optional, defaults to current repo owner)"
    echo ""
    echo "Environment variables:"
    echo "  GH_TOKEN      - GitHub token with admin:org permissions"
    echo ""
    echo "Example:"
    echo "  $0 MyOrgName"
    echo "  $0           # Uses current repository owner"
    exit 1
}

# Determine organization
if [ $# -ge 1 ]; then
    ORG="$1"
else
    # Try to get organization from current repository
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Get the remote origin URL and extract owner
        REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
            ORG="${BASH_REMATCH[1]}"
            echo "Auto-detected organization from current repository: $ORG"
        else
            echo -e "${RED}Error: Could not detect organization from current repository${NC}"
            echo "Please provide organization name as argument"
            usage
        fi
    else
        echo -e "${RED}Error: Not in a git repository and no organization specified${NC}"
        usage
    fi
fi

echo -e "${BLUE}GitHub Organization Custom Properties Setup${NC}"
echo "Organization: $ORG"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking existing properties...${NC}"

# Get existing properties using correct API endpoint
EXISTING_PROPERTIES=$(gh api "orgs/$ORG/properties/schema" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --jq '.[].property_name' 2>/dev/null || echo "")

if echo "$EXISTING_PROPERTIES" | grep -q "^role$"; then
    echo "✅ Property 'role' already exists"
    ROLE_EXISTS=true
else
    echo "❌ Property 'role' does not exist"
    ROLE_EXISTS=false
fi

if echo "$EXISTING_PROPERTIES" | grep -q "^spec$"; then
    echo "✅ Property 'spec' already exists"
    SPEC_EXISTS=true
else
    echo "❌ Property 'spec' does not exist"
    SPEC_EXISTS=false
fi

if echo "$EXISTING_PROPERTIES" | grep -q "^instructions$"; then
    echo "✅ Property 'instructions' already exists"
    INSTRUCTIONS_EXISTS=true
else
    echo "❌ Property 'instructions' does not exist"
    INSTRUCTIONS_EXISTS=false
fi

echo ""

# Function to create property using the correct API endpoint
create_property() {
    local prop_name="$1"
    local prop_config="$2"
    
    echo "Creating property '$prop_name' using individual endpoint..."
    
    if echo "$prop_config" | gh api --method PUT "orgs/$ORG/properties/schema/$prop_name" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        --input -; then
        echo -e "${GREEN}✅ Successfully created '$prop_name' property${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to create '$prop_name' property${NC}"
        echo "This might be due to insufficient permissions (need admin:org scope or custom_properties_org_definitions_manager)"
        return 1
    fi
}

# Create or update role property (upsert)
echo -e "${YELLOW}Step 2: Creating/updating 'role' property...${NC}"

ROLE_PAYLOAD='{
    "value_type": "single_select",
    "description": "Repository type in SDD workflow (spec or feature)",
    "required": false,
    "allowed_values": ["spec", "feature"]
}'

if [ "$ROLE_EXISTS" = true ]; then
    echo "Updating existing role property (making it non-required)"
else
    echo "Creating new role property with values: spec, feature (non-required)"
fi

if ! create_property "role" "$ROLE_PAYLOAD"; then
    exit 1
fi

echo ""

# Create or update spec property (upsert)
echo -e "${YELLOW}Step 3: Creating/updating 'spec' property...${NC}"

SPEC_PAYLOAD='{
    "value_type": "string",
    "description": "Reference to specification repository (owner/repo format, null for spec repos)",
    "required": false
}'

if [ "$SPEC_EXISTS" = true ]; then
    echo "Updating existing spec property"
else
    echo "Creating new spec property (string type, optional)"
fi

if ! create_property "spec" "$SPEC_PAYLOAD"; then
    exit 1
fi

echo ""

# Create or update instructions property (upsert)
echo -e "${YELLOW}Step 4: Creating/updating 'instructions' property...${NC}"

INSTRUCTIONS_PAYLOAD='{
    "value_type": "string",
    "description": "Source of truth repository for SDD instructions and templates (owner/repo format)",
    "required": false
}'

if [ "$INSTRUCTIONS_EXISTS" = true ]; then
    echo "Updating existing instructions property"
else
    echo "Creating new instructions property (string type, optional)"
fi

if ! create_property "instructions" "$INSTRUCTIONS_PAYLOAD"; then
    exit 1
fi

echo ""

# Verify the properties were created
echo -e "${YELLOW}Step 5: Verifying properties...${NC}"

FINAL_PROPERTIES=$(gh api "orgs/$ORG/properties/schema" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --jq '.[] | {name: .property_name, type: .value_type, required: .required, default: .default_value}' 2>/dev/null || echo "{}")

echo "Current organization properties:"
echo "$FINAL_PROPERTIES"

echo ""
echo -e "${GREEN}✅ Custom properties setup completed!${NC}"
echo ""
echo -e "${BLUE}Properties defined:${NC}"
echo "• role: single_select (spec|feature) - optional, no default"
echo "• spec: string - optional, default: null"
echo "• instructions: string - optional, source of truth repository"
echo ""
echo -e "${BLUE}Usage in repositories:${NC}"
echo "• Spec repositories: role=spec, spec=null, instructions=owner/sdd-template"
echo "• Feature repositories: role=feature, spec=owner/spec-repo, instructions=owner/sdd-template"
echo ""
echo -e "${GREEN}You can now run the repository setup workflow!${NC}"
