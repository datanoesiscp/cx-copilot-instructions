#!/bin/bash

# GitHub CLI Authentication Script with Required Scopes
# Authenticates with all scopes needed for SDD template operations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}GitHub CLI Authentication with SDD Template Scopes${NC}"
echo ""
echo -e "${YELLOW}This script will authenticate GitHub CLI with all required scopes:${NC}"
echo "• repo           - Full repository access (read/write repositories)"
echo "• delete_repo    - Delete repositories" 
echo "• admin:org      - Organization administration (create custom properties)"
echo "• read:org       - Read organization data"
echo "• workflow       - Manage GitHub Actions workflows"
echo "• gist          - Create and manage gists"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

echo -e "${YELLOW}Current authentication status:${NC}"
gh auth status 2>/dev/null || echo "Not currently authenticated"
echo ""

# Confirm before proceeding
echo -e "${YELLOW}This will refresh your GitHub authentication with the required scopes.${NC}"
echo -e "${RED}Warning: This may replace your current authentication token.${NC}"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Authentication cancelled"
    exit 0
fi

echo ""
echo -e "${YELLOW}Initiating GitHub authentication...${NC}"

# Authenticate with all required scopes
SCOPES="repo,delete_repo,admin:org,read:org,workflow,gist"

if gh auth refresh --hostname github.com -s "$SCOPES"; then
    echo ""
    echo -e "${GREEN}✅ Authentication successful!${NC}"
    echo ""
    echo -e "${YELLOW}Verifying scopes...${NC}"
    gh auth status
    echo ""
    echo -e "${GREEN}You can now run:${NC}"
    echo "• ./setup-org-properties.sh     # Create organization custom properties"
    echo "• ./delete-test-repos.sh        # Clean up test repositories"
    echo "• GitHub Actions workflows      # With proper permissions"
    echo ""
    echo -e "${BLUE}All SDD template operations should now work correctly!${NC}"
else
    echo ""
    echo -e "${RED}❌ Authentication failed${NC}"
    echo "Please check your network connection and try again"
    exit 1
fi
