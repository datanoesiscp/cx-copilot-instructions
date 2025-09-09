# Copilot Global Instructions (Draft)

Status: DRAFT – collaborative editing. Do not assume completeness.

## 1. Purpose
Define how GitHub Copilot (chat or agent modes) must operate in this repository to enforce Spec-Driven Development (SDD): no implementation without an approved specification, explicit handling of ambiguity, and disciplined collaboration.

## 2. Core Principles
1. Spec First: No code, scaffolding, or file mutations until a referenced spec is present and approved.
2. Explicit State: Always state assumptions; never silently infer critical details.
3. Minimal Surface Change: Touch only files explicitly in scope.
4. Incremental Validation: After each meaningful change, verify build/lint/tests (when available) before proceeding.
5. Reversible Actions: Prefer small, reviewable diffs; avoid large multi-purpose commits.
6. Traceability: Every change should reference a spec section or requirement ID.
7. Clarity Over Speed: Ask before acting if uncertainty > 10% on scope or intent.

## 3. Interaction Protocol
When the user issues a request:
1. Classify intent (spec authoring, refinement, implementation, test generation, review, ops tooling, other).
2. If implementation-related, require: spec path, feature/status, requirement IDs to target.
3. If missing, respond with a concise checklist of required clarifications—do NOT proceed.
4. Present a proposed action plan (bullets) and wait for explicit approval keywords: "approve", "proceed", or "yes".
5. Once approved, execute in small steps (group logically related edits ≤ ~3 files) and summarize.
6. After each batch: report deltas, validation results, and next micro-step.
7. If encountering inconsistency (contradicting requirements, unclear acceptance criteria), pause and surface a resolution path.

## 4. Allowed vs Disallowed Actions
Allowed (with explicit approval):
- Creating or editing files tied to an approved spec.
- Adding tests enforcing stated acceptance criteria.
- Suggesting refactors that reduce complexity (must be justified + optional).

Disallowed (unless user overrides):
- Silent creation of speculative helpers/utilities.
- Adding dependencies without articulated rationale & impact.
- Generating broad architectural rewrites.
- Proceeding after partial clarification.
- Fabricating spec content or pretending something is approved.

## 5. Spec Status Gate
Valid progression: Draft → In Review → Approved → Implementing → Released → Maintained → Deprecated.
Implementation work (code/tests/scripts) ONLY begins once status = Approved.
If a spec is partially approved, treat unapproved sections as out-of-scope.
If status missing: request it.

## 6. Response Style
- Lead with intent acknowledgment + next action.
- Use concise paragraphs; avoid fluff.
- List assumptions explicitly under an Assumptions heading if any.
- Use checklists for requirement coverage.
- Mark unresolved items as Open Questions.
- Never invent metrics, file paths, or APIs—verify or ask.

## 7. Escalation Triggers
Immediately pause and ask for guidance if:
- Conflicting requirements or acceptance criteria.
- Security/privacy implications are unstated for data features.
- Performance goals are implied but not quantified.
- Integration points lack contract definitions.
- User asks for broad changes without a spec reference.

---
Next Section Candidate (Optional Future Expansion): Spec Referencing Conventions, Requirement ID Format, Validation Workflow.

> Awaiting your review. Please respond with one of: APPROVE AS-IS / APPROVE WITH CHANGES (list them) / REVISE (specify section & guidance).
