#!/bin/bash

# GitHub App Device Flow Authentication Script
# Implements the device flow to get a user access token for a GitHub App

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <APP_ID> [CLIENT_ID]"
    echo ""
    echo "Arguments:"
    echo "  APP_ID     - GitHub App ID (required)"
    echo "  CLIENT_ID  - GitHub App Client ID (optional, will be fetched if not provided)"
    echo ""
    echo "Environment variables:"
    echo "  GH_TOKEN   - GitHub token to fetch app details (if CLIENT_ID not provided)"
    echo ""
    echo "Example:"
    echo "  $0 123456"
    echo "  $0 123456 Iv1.1234567890abcdef"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

APP_ID="$1"
CLIENT_ID="${2:-}"

echo -e "${BLUE}GitHub App Device Flow Authentication${NC}"
echo "App ID: $APP_ID"
echo ""

# Get CLIENT_ID if not provided
if [ -z "$CLIENT_ID" ]; then
    echo "Fetching GitHub App details..."
    
    if [ -z "$GH_TOKEN" ]; then
        echo -e "${RED}Error: CLIENT_ID not provided and GH_TOKEN not set${NC}"
        echo "Either provide CLIENT_ID as second argument or set GH_TOKEN to fetch app details"
        exit 1
    fi
    
    # Fetch app details using GitHub API
    APP_RESPONSE=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/app")
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to fetch app details${NC}"
        exit 1
    fi
    
    CLIENT_ID=$(echo "$APP_RESPONSE" | grep -o '"client_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$CLIENT_ID" ]; then
        echo -e "${RED}Error: Could not extract client_id from app details${NC}"
        echo "App response: $APP_RESPONSE"
        exit 1
    fi
    
    echo "Retrieved Client ID: $CLIENT_ID"
fi

echo ""
echo -e "${YELLOW}Step 1: Initiating device flow...${NC}"

# Step 1: Request device and user codes
DEVICE_RESPONSE=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"client_id\":\"$CLIENT_ID\",\"scope\":\"repo\"}" \
    "https://github.com/login/device/code")

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to initiate device flow${NC}"
    exit 1
fi

# Extract values from response using grep and cut
DEVICE_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"device_code":"[^"]*"' | cut -d'"' -f4)
USER_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"user_code":"[^"]*"' | cut -d'"' -f4)
VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | grep -o '"verification_uri":"[^"]*"' | cut -d'"' -f4)
EXPIRES_IN=$(echo "$DEVICE_RESPONSE" | grep -o '"expires_in":[0-9]*' | cut -d':' -f2)
INTERVAL=$(echo "$DEVICE_RESPONSE" | grep -o '"interval":[0-9]*' | cut -d':' -f2)

if [ -z "$DEVICE_CODE" ]; then
    echo -e "${RED}Error: Failed to get device code${NC}"
    echo "Response: $DEVICE_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Device flow initiated successfully${NC}"
echo ""
echo -e "${YELLOW}Step 2: User authorization required${NC}"
echo -e "${BLUE}Please visit: $VERIFICATION_URI${NC}"
echo -e "${BLUE}Enter code: $USER_CODE${NC}"
echo ""
echo "Code expires in: $EXPIRES_IN seconds"
echo ""

# Try to open the URL automatically (if possible)
if command -v xdg-open >/dev/null 2>&1; then
    echo "Opening browser automatically..."
    xdg-open "$VERIFICATION_URI" 2>/dev/null || true
elif command -v open >/dev/null 2>&1; then
    echo "Opening browser automatically..."
    open "$VERIFICATION_URI" 2>/dev/null || true
fi

echo -e "${YELLOW}Waiting for authorization...${NC}"
echo "Press Ctrl+C to cancel"
echo ""

# Step 3: Poll for access token
MAX_ATTEMPTS=$((EXPIRES_IN / INTERVAL))
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    
    echo -n "Polling attempt $ATTEMPT/$MAX_ATTEMPTS... "
    
    TOKEN_RESPONSE=$(curl -s -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"client_id\":\"$CLIENT_ID\",\"device_code\":\"$DEVICE_CODE\",\"grant_type\":\"urn:ietf:params:oauth:grant-type:device_code\"}" \
        "https://github.com/login/oauth/access_token")
    
    ERROR_TYPE=$(echo "$TOKEN_RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$ERROR_TYPE" ] && echo "$TOKEN_RESPONSE" | grep -q '"access_token"'; then
        # Success - we got a token
        ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
        TOKEN_TYPE=$(echo "$TOKEN_RESPONSE" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
        SCOPE=$(echo "$TOKEN_RESPONSE" | grep -o '"scope":"[^"]*"' | cut -d'"' -f4)
        
        # Set defaults if not found
        TOKEN_TYPE="${TOKEN_TYPE:-bearer}"
        SCOPE="${SCOPE:-unknown}"
            
            echo -e "${GREEN}Success!${NC}"
            echo ""
            echo -e "${GREEN}✓ User access token obtained${NC}"
            echo ""
            echo "Token Type: $TOKEN_TYPE"
            echo "Scope: $SCOPE"
            echo ""
            echo -e "${YELLOW}Access Token:${NC}"
            echo "$ACCESS_TOKEN"
            echo ""
            echo -e "${BLUE}You can now use this token with:${NC}"
            echo "export GH_TOKEN=\"$ACCESS_TOKEN\""
            echo "gh auth login --with-token <<< \"$ACCESS_TOKEN\""
            echo ""
        echo -e "${GREEN}Authentication completed successfully!${NC}"
        exit 0
    elif [ "$ERROR_TYPE" = "authorization_pending" ]; then
        echo "waiting..."
    elif [ "$ERROR_TYPE" = "slow_down" ]; then
        echo "rate limited, waiting longer..."
        INTERVAL=$((INTERVAL + 5))
    elif [ "$ERROR_TYPE" = "expired_token" ]; then
        echo -e "${RED}expired${NC}"
        echo ""
        echo -e "${RED}Error: The device code has expired${NC}"
        echo "Please run the script again to get a new code"
        exit 1
    elif [ "$ERROR_TYPE" = "access_denied" ]; then
        echo -e "${RED}denied${NC}"
        echo ""
        echo -e "${RED}Error: User denied authorization${NC}"
        exit 1
    else
        echo -e "${RED}error${NC}"
        echo ""
        echo -e "${RED}Error: ${ERROR_TYPE:-unknown}${NC}"
        echo "Response: $TOKEN_RESPONSE"
        exit 1
    fi
    
    sleep "$INTERVAL"
done

echo ""
echo -e "${RED}Error: Timed out waiting for authorization${NC}"
echo "The device code may have expired. Please try again."
exit 1
