# Spec-Driven Development (SDD) Template

A comprehensive template repository that implements Spec-Driven Development workflows with automated GitHub repository setup, property management, and AI agent integration.

## What is Spec-Driven Development (SDD)?

Spec-Driven Development is a methodology where software development is guided by clear, executable specifications that serve as the single source of truth for project requirements, behaviors, and implementations.

### Core Principles

- **Specification First**: Before any code is written, create detailed specifications that define exactly what needs to be built
- **Executable Documentation**: Specifications are not just documentation - they drive automated testing, validation, and development workflows  
- **AI Agent Integration**: AI coding agents use specifications as their primary instruction set for autonomous development
- **Traceability**: Every feature implementation can be traced back to its originating specification
- **Consistency**: All team members and AI agents work from the same authoritative source of truth

## Why Use SDD?

### Traditional Development Challenges
- Requirements often change or get misunderstood during development
- Documentation becomes outdated and unreliable
- Team members have different interpretations of what to build
- Code reviews focus on implementation details rather than requirement fulfillment
- AI agents receive inconsistent or incomplete instructions

### SDD Solutions
- **Clarity**: Specifications provide unambiguous requirements that humans and AI agents can follow
- **Efficiency**: AI agents can autonomously implement features based on clear specifications
- **Quality**: Automated validation ensures implementations match specifications exactly
- **Maintainability**: Changes flow from specs to implementation, keeping everything synchronized
- **Collaboration**: Teams collaborate on specifications before costly implementation begins

## How SDD Works

### Repository Types

**Specification Repositories (`role: spec`)**
- Contain detailed feature specifications, requirements, and behavioral definitions
- Serve as the authoritative source of truth for what needs to be built
- Include acceptance criteria, test scenarios, and validation rules
- Used by AI agents as instruction sets for autonomous development

**Feature Repositories (`role: feature`)**  
- Implement the features defined in specification repositories
- Reference their parent specification repository via the `spec` property
- Contain actual code, tests, and implementation artifacts
- Automatically validated against their parent specifications

### Workflow Overview

1. **Specification Creation**: Teams create detailed specifications in spec repositories
2. **Feature Repository Generation**: New feature repositories are created from this template
3. **Automatic Configuration**: Repositories are automatically configured with appropriate properties
4. **AI Agent Development**: AI agents read specifications and autonomously implement features
5. **Validation & Integration**: Implementations are automatically validated against specifications

## Template Features

- 🤖 **Automated Setup**: GitHub Actions workflow that automatically configures repository properties
- 🔧 **CLI Tools**: Scripts for GitHub authentication and organization setup  
- 📋 **Custom Properties**: Automated management of SDD-specific repository metadata
- 🔄 **Template Integration**: Smart detection of template repository relationships
- 🛡️ **Security**: Proper authentication handling with comprehensive scopes
- 🎯 **AI Ready**: Designed for seamless AI agent integration and autonomous development

## Quick Start

1. **Use this template** to create a new repository
2. The repository will be automatically configured with SDD properties on first push
3. Start developing according to SDD principles

For detailed setup instructions, see [Setup Guide](docs/SETUP.md).

## Repository Structure

```
sdd-template/
├── .github/
│   ├── workflows/
│   │   └── setup-repository-properties.yml    # Automated property setup
│   └── COPILOT_INSTRUCTIONS.md               # AI agent guidance
├── docs/
│   ├── SETUP.md                              # Comprehensive setup guide
│   ├── SCRIPTS.md                            # Script documentation  
│   └── WORKFLOWS.md                          # Workflow documentation
├── scripts/
│   ├── delete-test-repos.sh                 # Cleanup utility
│   ├── github-app-device-flow.sh            # GitHub App authentication
│   ├── setup-github-auth.sh                 # GitHub CLI authentication
│   └── setup-org-properties.sh              # Organization property setup
├── README.md                                 # This file
└── LICENSE                                   # MIT License
```

## Custom Properties

This template automatically configures three custom repository properties that enable the SDD workflow:

### role
- **Type**: Single select (spec | feature)
- **Description**: Defines the repository's role in the SDD workflow
- **Required**: No
- **Values**:
  - `spec`: Repository contains specifications, requirements, and behavioral definitions
  - `feature`: Repository implements features based on specifications from a parent spec repository

### spec  
- **Type**: String
- **Description**: Links feature repositories to their governing specification repository
- **Required**: No
- **Usage**:
  - **Spec repositories**: Leave null/empty (they ARE the specification)
  - **Feature repositories**: Full repository slug of the parent spec (e.g., `your-org/product-spec`)

### instructions
- **Type**: String  
- **Description**: Points to the template repository containing SDD methodology, documentation, and AI agent instructions
- **Required**: No
- **Usage**: Automatically set to the template repository used to create this repo (this repository serves as the instruction source)
- **Purpose**: AI agents use this to locate their behavioral instructions, development guidelines, and SDD workflow definitions

## Repository Examples

### Specification Repository
- **Name**: `user-authentication-spec`
- **Properties**: `role=spec`, `spec=null`, `instructions=YOUR_ORG/sdd-template`
- **Contains**: User stories, API specifications, security requirements, test scenarios
- **Purpose**: Define exactly how user authentication should work

### Feature Repository  
- **Name**: `user-authentication-service`
- **Properties**: `role=feature`, `spec=YOUR_ORG/user-authentication-spec`, `instructions=YOUR_ORG/sdd-template`
- **Contains**: Implementation code, tests, deployment configurations
- **Purpose**: Implement the authentication service according to its specification

## AI Agent Integration

This template repository serves as the **instruction source** for AI agents working within the SDD workflow. The `instructions` property in every generated repository points back to this template, enabling AI agents to:

### Access SDD Guidelines
- **Location**: `.github/COPILOT_INSTRUCTIONS.md`
- **Purpose**: Defines how AI agents should operate within SDD workflows
- **Scope**: Spec-first development, validation protocols, interaction patterns

### Understand Repository Context
- **Property Reading**: AI agents can read the `role`, `spec`, and `instructions` properties to understand their context
- **Spec Repository Access**: For feature repos, agents can locate and read the governing specification
- **Template Reference**: The `instructions` property provides the source for methodology and guidelines

### Follow SDD Protocols
- **Specification First**: Never implement without an approved specification
- **Traceability**: Every change must reference specification requirements  
- **Validation**: Automated verification that implementations match specifications
- **Incremental Development**: Small, reviewable changes with continuous validation

### Example AI Agent Workflow
1. **Repository Analysis**: Read properties to understand repository role and context
2. **Specification Loading**: If `role=feature`, load specification from `spec` property repository  
3. **Instruction Retrieval**: Access SDD guidelines from the `instructions` repository
4. **Implementation**: Follow spec-driven development protocols for all changes
5. **Validation**: Verify implementations against specifications before completion

## Getting Started

### For Organizations
1. Fork this template to your organization
2. Run the setup scripts to configure your GitHub organization
3. Create specification repositories to define your project requirements
4. Generate feature repositories from this template to implement specifications

### For Developers
1. Create repositories from this template (they'll be auto-configured)
2. If creating a spec repository: Define clear, detailed specifications
3. If creating a feature repository: Implement according to the linked specification
4. Use AI agents with the specifications as their instruction sets

## Documentation

- [**Setup Guide**](docs/SETUP.md) - Complete installation and configuration instructions
- [**Scripts Documentation**](docs/SCRIPTS.md) - Detailed script usage and examples
- [**Workflows Documentation**](docs/WORKFLOWS.md) - GitHub Actions workflow explanations

## Contributing

1. Fork this repository
2. Create feature branches for improvements
3. Submit pull requests with clear descriptions
4. Follow the SDD methodology for all changes

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For questions about implementing SDD in your organization or using this template:
1. Check the documentation in the `docs/` folder
2. Review existing GitHub Issues for similar questions
3. Create a new Issue with the `question` label

---

**Ready to implement Spec-Driven Development?** Start by reading the [Setup Guide](docs/SETUP.md) to configure your environment.
```
