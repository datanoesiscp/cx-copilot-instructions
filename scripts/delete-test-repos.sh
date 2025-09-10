#!/bin/bash

# Script to delete all repositories that start with 'test'
# Uses GitHub CLI (gh) to list and delete repositories
# Usage: ./delete-test-repos.sh [ORGANIZATION_NAME]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Repository Cleanup Script${NC}"
echo "This script will delete all repositories that start with 'test'"
echo ""

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Check if user has the required delete_repo scope
if ! gh auth status 2>&1 | grep -q "delete_repo"; then
    echo -e "${RED}Error: Missing required 'delete_repo' scope${NC}"
    echo "Please run: gh auth refresh -h github.com -s delete_repo"
    exit 1
fi

# Determine the owner (organization or user)
if [ -n "$1" ]; then
    OWNER="$1"
    echo -e "Target owner (from argument): ${GREEN}$OWNER${NC}"
else
    # Try to get the owner from the current repo, fallback to current user
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Get the remote origin URL and extract owner
        REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
            OWNER="${BASH_REMATCH[1]}"
            echo -e "Target owner (from current repo): ${GREEN}$OWNER${NC}"
        else
            OWNER=$(gh api user --jq '.login')
            echo -e "Target owner (current user, no repo detected): ${GREEN}$OWNER${NC}"
        fi
    else
        OWNER=$(gh api user --jq '.login')
        echo -e "Target owner (current user, not in git repo): ${GREEN}$OWNER${NC}"
    fi
fi
echo ""

# List all repositories that start with 'test'
echo "Finding repositories that start with 'test'..."
if [ -n "$OWNER" ]; then
    TEST_REPOS=$(gh repo list "$OWNER" --limit 1000 --json name --jq '.[] | select(.name | startswith("test")) | .name')
else
    TEST_REPOS=$(gh repo list --limit 1000 --json name --jq '.[] | select(.name | startswith("test")) | .name')
fi
if [ -z "$TEST_REPOS" ]; then
    echo -e "${GREEN}No repositories found that start with 'test'${NC}"
    exit 0
fi

echo -e "${YELLOW}Found the following repositories:${NC}"
echo "$TEST_REPOS" | sed 's/^/  - /'
echo ""

# Count repositories
REPO_COUNT=$(echo "$TEST_REPOS" | wc -l)
echo -e "Total repositories to delete: ${RED}$REPO_COUNT${NC}"
echo ""

# Confirmation prompt
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "Are you sure you want to delete all $REPO_COUNT repositories? (type 'DELETE' to confirm): "
read -r CONFIRMATION

if [ "$CONFIRMATION" != "DELETE" ]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

echo ""
echo "Starting deletion process..."

# Delete each repository
DELETED_COUNT=0
FAILED_COUNT=0

while IFS= read -r repo; do
    if [ -n "$repo" ]; then
        echo -n "Deleting $OWNER/$repo... "
        ERROR_OUTPUT=$(gh repo delete "$OWNER/$repo" --yes 2>&1)
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Deleted${NC}"
            ((DELETED_COUNT++))
        else
            echo -e "${RED}✗ Failed${NC}"
            echo -e "  ${RED}Error: $ERROR_OUTPUT${NC}"
            ((FAILED_COUNT++))
        fi
    fi
done <<< "$TEST_REPOS"

echo ""
echo "Deletion completed!"
echo -e "Successfully deleted: ${GREEN}$DELETED_COUNT${NC} repositories"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "Failed to delete: ${RED}$FAILED_COUNT${NC} repositories"
fi
