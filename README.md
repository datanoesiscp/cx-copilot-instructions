# Avanavo SDD Template

A comprehensive template repository for **Spec-Driven Development** with automated GitHub Copilot instruction management and repository linking.

## Overview

This template provides:
- 🤖 **Copilot Instructions**: Modular instruction files for consistent AI-assisted development
- 📋 **Specification Templates**: Structured templates for writing comprehensive specs
- 🔗 **Repository Linking**: Automated tracking between spec repositories and their implementations  
- 🚀 **Auto-Setup**: GitHub Actions that configure new repositories automatically

## Quick Start

### 1. Create Repository from Template
1. Click "Use this template" → "Create a new repository"
2. Name your repository (suggest: `project-name-spec` for spec repos, `project-name-feature` for implementations)
3. After creation, the first push will trigger auto-setup

### 2. GitHub App Setup (One-time)
To enable cross-repository automation, you need to set up the Standards Sync GitHub App:

#### Create GitHub App
1. Go to GitHub Settings → Developer settings → GitHub Apps → New
2. **App Name**: `Standards Sync` (or your preferred name)
3. **Homepage URL**: `https://github.com/Avanavo/avanavo-sdd-template`
4. **Webhook URL**: `https://example.com/webhook` (placeholder)
5. **Webhook Secret**: Generate a random string
6. **Permissions**:
   - Repository permissions: `Metadata: Read`, `Issues: Write`
   - Organization permissions: None
   - User permissions: None
7. **Subscribe to events**: None needed
8. Create the app and generate a private key

#### Configure Repository Secrets
Add these secrets to your template repository (and any repos that need to create issues):
- `APP_ID`: Your GitHub App ID
- `APP_PRIVATE_KEY`: The private key (entire PEM content)

#### Install the App
1. Go to your GitHub App settings
2. Click "Install App" 
3. Install on your organization or selected repositories

### 3. Repository Properties
Each repository gets custom properties that define its role:

- **role**: `spec` (specification repository) or `feature` (implementation repository)
- **spec**: If role=feature, the full slug of the spec repository (e.g., `Avanavo/my-spec-repo`)

These are set automatically via Copilot agent when you create a new repository.

## Repository Types

### Spec Repository (`role: spec`)
- Contains authoritative specifications and requirements
- May include implementation alongside specs (combined approach)
- Receives standards updates from this template
- **Example**: `my-product-spec`

### Feature Repository (`role: feature`)  
- Implements functionality defined in a spec repository
- Links to its source spec via the `spec` property
- Receives both standards updates and spec change notifications
- **Example**: `my-product-api` (implements `Avanavo/my-product-spec`)

## File Structure

```
.github/
├── workflows/
│   └── setup-repository-properties.yml    # Auto-setup for new repos
├── COPILOT_INSTRUCTIONS.md                # Core Copilot behavioral rules
└── ISSUE_TEMPLATE/                        # Issue templates
docs/
├── SDD_SPEC_TEMPLATE.md                   # Specification template  
└── standards/                             # Instruction modules (future)
specs/                                     # Specification documents
└── README.md                              # Repository documentation
```

## How It Works

### New Repository Setup
1. **Create** repository from this template
2. **First Push** triggers setup workflow
3. **Workflow** checks if repository properties exist
4. **If missing**: Creates issue assigned to `@github-copilot[bot]`
5. **Copilot Agent** reads issue, sets appropriate properties, closes issue

### Standards Propagation (Future)
1. **Template Changes**: When instruction modules are updated in this template
2. **Discovery**: Workflow finds all linked repositories via custom properties  
3. **Issue Creation**: Creates issues in target repos describing needed updates
4. **Agent Implementation**: Copilot agents implement the changes via PRs
5. **Human Gate**: You review and merge standards update PRs as desired

## Copilot Instructions

The `.github/COPILOT_INSTRUCTIONS.md` file contains behavioral rules for GitHub Copilot when working in repositories based on this template. Key principles:

- **Spec-First**: No implementation without approved specifications
- **Explicit State**: Always state assumptions, never infer critical details  
- **Incremental**: Small, reviewable changes with validation steps
- **Traceability**: Link all changes back to specification requirements

## Contributing

### Adding New Instruction Modules
1. Create module file in appropriate directory
2. Follow managed block pattern for updateable sections
3. Test with sample repositories before template changes
4. Update this README with new module documentation

### Modifying Templates  
1. Update spec templates based on lessons learned
2. Ensure backward compatibility where possible
3. Document breaking changes in release notes

## Troubleshooting

### Setup Issue Not Created
- Check that `APP_ID` and `APP_PRIVATE_KEY` secrets are set correctly
- Verify GitHub App is installed on the repository
- Ensure workflow had permissions to create issues

### Properties Not Set
- Check issue created by setup workflow
- Look for Copilot agent comments on the issue
- Manually assign issue to `@github-copilot[bot]` if needed

### Standards Updates Not Received
- Verify repository has correct `role` property set
- Check that GitHub App has access to the repository
- Look for issues created by template propagation workflow

## License

MIT License - see LICENSE file for details.

---

**Template Version**: 1.0.0  
**Last Updated**: September 2025
