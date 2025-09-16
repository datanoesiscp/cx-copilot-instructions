# Avanavo SDD Framework

A comprehensive **role-based agentic framework** for **Spec-Driven Development (SDD)** that provides GitHub Copilot with structured instructions for disciplined, specification-first development across multiple technology stacks.

## What is Spec-Driven Development (SDD)?

Spec-Driven Development is a methodology where software development is guided by clear, executable specifications that serve as the single source of truth for project requirements, behaviors, and implementations.

### Core Principles

- **Specification First**: Before any code is written, create detailed specifications that define exactly what needs to be built
- **Role-Based Expertise**: AI agents operate within defined roles (Solution Architect, Business Analyst, Developer, QA, DevOps, Technical Writer) to ensure appropriate expertise and boundaries
- **Anti-Assumption Protocols**: Agents never add unrequested features or make silent assumptions - they ask for clarification explicitly
- **Traceability**: Every feature implementation can be traced back to its originating specification with requirement IDs
- **Deterministic Implementation**: When users agree to specific proposals, agents implement exactly what was agreed upon

## Why Use This Framework?

### Traditional AI Agent Challenges
- Agents make assumptions and add unrequested features
- Inconsistent behavior across different types of work
- No clear expertise boundaries or escalation paths
- Implementation differs from what was proposed/agreed upon
- Lack of requirement traceability

### SDD Framework Solutions
- **Clear Role Boundaries**: Each agent operates within defined expertise domains with clear responsibilities
- **Explicit Communication**: Agents state assumptions clearly and ask for clarification when uncertain
- **Anti-Assumption Protocols**: Strict rules preventing agents from adding unrequested functionality
- **Deterministic Behavior**: Agents implement exactly what was proposed and agreed upon
- **Escalation Authority**: Solution Architect role can resolve conflicts and make architectural decisions

## How the Framework Works

### Available Roles

The framework provides **7 industry-standard roles** that GitHub Copilot can assume:

| Role | Expertise | Primary Responsibilities |
|------|-----------|-------------------------|
| **Solution Architect** | System architecture, cross-role coordination | Escalation authority, conflict resolution, architectural decisions |
| **Software Architect** | Technical design, API design | System structure, technology choices, design patterns |
| **Business Analyst** | Requirements analysis | Functional specifications, user stories, acceptance criteria |
| **Software Developer** | Implementation | Code writing, unit testing, requirement traceability |
| **QA Engineer** | Quality assurance, testing | Test planning, validation, quality gates |
| **DevOps Engineer** | Infrastructure, deployment | CI/CD, monitoring, operational requirements |
| **Technical Writer** | Documentation | User guides, API docs, process documentation |

### Role Selection Process

1. **User makes request** → Copilot analyzes the request
2. **Copilot proposes role** → "This appears to be a [ROLE] task. Should I proceed with [ROLE] instructions?"
3. **User confirms** → Copilot loads role-specific instructions and operates within that role's boundaries
4. **Role switching** → Available if request changes scope or different expertise is needed

### Framework Benefits

- 🎯 **Focused Expertise**: Each role provides specialized knowledge and appropriate boundaries
- � **Anti-Assumption Protocols**: Prevents agents from adding unrequested features or making silent assumptions  
- � **Deterministic Implementation**: Ensures agents implement exactly what was proposed and agreed upon
- � **Requirement Traceability**: Every change links back to specific requirements with IDs
- ⚡ **Escalation Authority**: Solution Architect can resolve conflicts and override constraints when necessary
- � **Multi-Technology Support**: Works across DevExpress/.NET, Deno, Express, and other technology stacks

## Installation & Usage

### Package Distribution (Coming Soon)

The framework will be available as packages across multiple ecosystems:

- **npm**: `@avanavo/sdd-framework` (JavaScript/TypeScript projects)
- **NuGet**: `Avanavo.SDD.Framework` (.NET/DevExpress projects)  
- **Deno**: Available via JSR registry (Deno/Supabase functions)

### Current Usage (GitHub Repository)

1. **Copy the framework files** to your repository:
   ```bash
   # Copy the entire .github directory to your project
   cp -r .github/ /path/to/your/project/
   ```

2. **Start a conversation with GitHub Copilot**:
   ```
   "I need to add user authentication to my application"
   ```

3. **Copilot will propose a role**:
   ```
   "This appears to be a Software Developer task. Should I proceed with Software Developer instructions?"
   ```

4. **Confirm and begin**:
   ```
   "Yes, proceed"
   ```

5. **Copilot operates within role boundaries**, following SDD principles and asking for specifications

## Framework Structure

```
avanavo-sdd-template/
├── .github/
│   ├── COPILOT_INSTRUCTIONS.md          # Main role-based framework
│   └── copilot-roles/                   # Role-specific instructions
│       ├── SOLUTION_ARCHITECT.md        # Technical leadership & escalation
│       ├── SOFTWARE_ARCHITECT.md        # System design & API architecture  
│       ├── BUSINESS_ANALYST.md          # Requirements & specifications
│       ├── SOFTWARE_DEVELOPER.md        # Implementation & coding
│       ├── QA_ENGINEER.md               # Testing & quality assurance
│       ├── DEVOPS_ENGINEER.md           # Infrastructure & deployment
│       └── TECHNICAL_WRITER.md          # Documentation & guides
├── README.md                            # This documentation
└── LICENSE                              # MIT License
```

## Core Framework Principles

### 1. Spec-First Development
- ✅ **Verify spec status before coding**
- ✅ **Reference specific requirement IDs in all work**
- ❌ **No implementation without approved specifications**

### 2. Explicit Communication  
- ✅ **State assumptions clearly**
- ✅ **Ask for clarification when uncertainty > 10%**
- ❌ **Never silently infer critical details**

### 3. Anti-Assumption Practices
- ✅ **Stick to what was explicitly requested**
- ✅ **Label additions as suggestions**: "You didn't ask for this, but would you like me to suggest..."
- ❌ **Adding "helpful" features not requested**
- ❌ **Assuming technology preferences beyond what's stated**

### 4. Deterministic Implementation
- ✅ **When user agrees to a proposal, implement EXACTLY what was proposed**
- ✅ **Copy exact text from proposals when implementing**
- ❌ **Never regenerate or "improve" upon agreed content**

### 5. Role Boundaries
- ✅ **Stay within your role's defined responsibilities**
- ✅ **Escalate to Solution Architect for cross-role conflicts**
- ✅ **Respect other roles' expertise domains**

## Example Interactions

### Business Analyst Role
```
User: "I need user authentication functionality"

BA: "I'll help create the functional specification for user authentication. 
     What authentication methods do you require? (email/password, OAuth, 2FA?)
     What are the security requirements?
     Should I create user stories with acceptance criteria?"
```

### Software Developer Role  
```
User: "Implement the login function"

Dev: "I need the approved specification for the login functionality. 
     Could you provide:
     • The specification document path
     • Specific requirement ID to implement
     • Current specification status (should be 'Approved')"
```

### Solution Architect Role (Escalation)
```
Dev: "I'm getting conflicting requirements between the API spec and UI mockups"

SA: "I'll analyze this conflict. Let me review both specifications and 
    make an architectural decision. I'll document the resolution and 
    update the affected specifications accordingly."
```

## Multi-Technology Support

The framework is designed to work seamlessly across different technology stacks:

### DevExpress/.NET Frontend Applications
- Business Analyst creates specifications for UI components and user workflows
- Software Architect designs component architecture and data binding patterns
- Software Developer implements DevExpress controls with requirement traceability

### Deno Functions (Supabase)
- Business Analyst specifies API requirements and business logic
- Software Architect designs function architecture and database interactions  
- Software Developer implements Deno functions with proper error handling

### Express.js APIs
- Business Analyst defines endpoint specifications and data contracts
- Software Architect designs API architecture and middleware patterns
- Software Developer implements routes with validation and documentation

## Advanced Features

### Requirement Traceability
Every code change includes references to specifications:
```javascript
// Implements REQ-AUTH-001: User login validation
// Business Rule BR-PASSWORD-001: Password complexity requirements
function validateUserLogin(email, password) {
    // Implementation with clear requirement links
}
```

### Commit Message Standards
```
feat: implement user password validation (REQ-AUTH-001)

- Add password strength validation per BR-PASSWORD-001
- Minimum 8 chars, mixed case, numbers required  
- Returns clear validation messages for UI
- Unit tests cover all acceptance criteria

Refs: REQ-AUTH-001, BR-PASSWORD-001
```

### Test Case Traceability
```markdown
## Test Case: TC-AUTH-001
**Requirement**: REQ-AUTH-001 - User authentication
**Acceptance Criteria**: AC-AUTH-001.1 - Valid credentials redirect to dashboard

### Test Steps
1. Navigate to login page
2. Enter valid credentials
3. Click login button

### Expected Result
- User redirected to dashboard
- Welcome message displays
- Session established per specification
```

## Getting Started

### 1. Copy Framework to Your Project
```bash
# Copy the .github directory to your repository
cp -r .github/ /path/to/your/project/

# Or download and extract specific files you need
```

### 2. Start Using Role-Based Development
```
You: "I need to add user authentication"
Copilot: "This appears to be a Business Analyst task. Should I proceed with Business Analyst instructions?"
You: "Yes"
Copilot: [Operates as BA] "I'll help create the user authentication specification..."
```

### 3. Switch Roles as Needed
```
You: "Now implement the authentication API"  
Copilot: "This request seems better suited for a Software Developer role. Should I switch to Software Developer for this task?"
You: "Yes, switch to developer"
Copilot: [Loads Developer instructions] "I need the approved specification for authentication..."
```

## Framework Customization

You can customize the framework by modifying:
- **`.github/COPILOT_INSTRUCTIONS.md`** - Main framework configuration
- **`.github/copilot-roles/*.md`** - Individual role instructions  
- **Role triggers** - Keywords that activate specific roles
- **Examples and templates** - Add project-specific examples

## Contributing

1. Fork this repository
2. Create feature branches for framework improvements
3. Test changes with GitHub Copilot interactions
4. Submit pull requests with clear descriptions
5. Follow the SDD methodology - create specifications before implementation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support & Community

- **GitHub Issues**: Report bugs or request features
- **Discussions**: Share experiences and ask questions
- **Documentation**: Review role instructions and examples
- **Examples**: See the framework in action across different technology stacks

---

**Ready to implement disciplined, specification-driven development?** Copy the `.github` directory to your project and start your first role-based conversation with GitHub Copilot!
```
