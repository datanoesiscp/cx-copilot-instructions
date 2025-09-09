# Repository Property Setup Instructions

## Overview
This repository was created from the SDD template and requires custom properties to be configured for proper categorization and linking.

## Required Properties

### 1. `role` Property
**Purpose**: Identifies the repository type
**Required Values**: 
- `spec` - For specification repositories that define requirements/interfaces
- `feature` - For implementation repositories that fulfill a specification

**How to determine**:
- If this repo contains specifications, documentation, or requirements → use `spec`
- If this repo implements features based on another spec repository → use `feature`
- **Default recommendation**: Use `spec` for new repositories unless clearly implementing another spec

### 2. `spec` Property  
**Purpose**: Links feature repositories to their corresponding specification repository
**Required Values**:
- `null` or empty - If `role=spec` (specification repos don't reference other specs)
- `"owner/repo-name"` - If `role=feature` (full GitHub repository slug of the spec being implemented)

**Examples**:
- Spec repo: `role=spec`, `spec=null`
- Feature repo: `role=feature`, `spec="Avanavo/payment-api-spec"`

## Step-by-Step Instructions

### Method 1: Using GitHub CLI (Recommended)
```bash
# For a specification repository:
gh api --method PATCH /repos/OWNER/REPO/properties/values \
  -f properties='[{"property_name":"role","value":"spec"},{"property_name":"spec","value":null}]'

# For a feature repository implementing "Avanavo/example-spec":
gh api --method PATCH /repos/OWNER/REPO/properties/values \
  -f properties='[{"property_name":"role","value":"feature"},{"property_name":"spec","value":"Avanavo/example-spec"}]'
```

### Method 2: Using curl with GitHub API
```bash
# Replace YOUR_TOKEN with a valid GitHub token
# Replace OWNER/REPO with the actual repository

curl -L \
  -X PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/properties/values \
  -d '{
    "properties": [
      {"property_name": "role", "value": "spec"},
      {"property_name": "spec", "value": null}
    ]
  }'
```

### Method 3: Using GitHub REST API directly
**Endpoint**: `PATCH /repos/{owner}/{repo}/properties/values`

**Request Body Format** (JSON):
```json
{
  "properties": [
    {"property_name": "role", "value": "spec"},
    {"property_name": "spec", "value": null}
  ]
}
```

**Important Notes**:
- Use `null` (not `""` or `"null"`) for empty values
- The `properties` field must be an array of objects
- Each object must have `property_name` and `value` fields
- Property names are case-sensitive

## Common Mistakes to Avoid

❌ **Wrong format**: `{"properties": {"role": "spec", "spec": ""}}`
✅ **Correct format**: `{"properties": [{"property_name": "role", "value": "spec"}, {"property_name": "spec", "value": null}]}`

❌ **Using string "null"**: `{"property_name": "spec", "value": "null"}`
✅ **Using actual null**: `{"property_name": "spec", "value": null}`

❌ **Missing property_name**: `{"role": "spec"}`
✅ **Correct structure**: `{"property_name": "role", "value": "spec"}`

## Verification

After setting properties, verify with:
```bash
gh api /repos/OWNER/REPO/properties/values
```

Expected output:
```json
[
  {"property_name": "role", "value": "spec"},
  {"property_name": "spec", "value": null}
]
```

## Completion

Once properties are set successfully:
1. **Comment on this issue** with the values you set
2. **Close this issue**

If you encounter any errors, paste the full error message in a comment for debugging assistance.
