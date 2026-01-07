# 5-Terminal Claude Code Workflow

A parallel AI development workflow inspired by Boris Cherny's approach at Anthropic: "I run 5 Claudes in parallel in my terminal."

## Overview

This workflow enables a single developer to operate with the output of an entire engineering team by running 5 specialized Claude Code instances in parallel, each with a distinct role and responsibility.

```
┌─────────────────┬─────────────────┐
│   Terminal 1    │   Terminal 2    │
│   ARCHITECT     │    BUILDER      │
│   (Design)      │   (UI/Views)    │
├─────────────────┼─────────────────┤
│   Terminal 3    │   Terminal 4    │
│   SERVICES      │    TESTING      │
│   (Logic/API)   │   (QA/Verify)   │
├─────────────────┴─────────────────┤
│           Terminal 5              │
│            DEVOPS                 │
│     (Build/Deploy/Monitor)        │
└───────────────────────────────────┘
```

## Quick Start

```bash
# From project root
./scripts/launch-workflow.sh
```

This launches a tmux session with 5 panes, each running Claude Code with its assigned role.

## The 5 Terminals

| Terminal | Role | Responsibility |
|----------|------|----------------|
| **1 - Architect** | Lead Designer | System design, specs, task breakdown, coordination |
| **2 - Builder** | UI Developer | Components, views, styling, user interactions |
| **3 - Services** | Backend Dev | Business logic, state management, API integration |
| **4 - Testing** | QA Engineer | Unit/integration/e2e tests, verification loops |
| **5 - DevOps** | Ops Engineer | Build system, CI/CD, deployment, monitoring |

## How It Works

### 1. File-Based Coordination

Terminals communicate through the filesystem:

```
docs/
├── specs/              # Feature specifications (written by Architect)
│   └── user-auth.md
├── tasks/              # Task assignments per terminal
│   ├── user-auth-builder.md
│   ├── user-auth-services.md
│   ├── user-auth-testing.md
│   └── user-auth-devops.md
├── bugs/               # Bug reports (written by Testing)
│   └── BUG-001.md
└── completed/          # Archived completed work
```

### 2. Verification Loops

Terminal 4 (Testing) continuously verifies implementations:
- Reads specifications from `docs/specs/`
- Monitors code changes from Builder and Services
- Runs tests and reports failures
- Creates bug reports that other terminals pick up

### 3. Dependency Flow

```
Architect ──specs──> Builder ──components──> Testing
    │                   │                       │
    │                   ▼                       │
    └──contracts──> Services ──logic──────────►│
                        │                       │
                        ▼                       ▼
                    DevOps <────build status────┘
```

## Workflow Patterns

### Starting a New Feature

1. **Architect** (Terminal 1):
   - Creates `docs/specs/FEATURE.md` with design
   - Breaks down into tasks in `docs/tasks/`

2. **Services** (Terminal 3):
   - Picks up `docs/tasks/FEATURE-services.md`
   - Implements data layer and business logic
   - Exports services for Builder

3. **Builder** (Terminal 2):
   - Picks up `docs/tasks/FEATURE-builder.md`
   - Implements UI components
   - Integrates with Services

4. **Testing** (Terminal 4):
   - Picks up `docs/tasks/FEATURE-testing.md`
   - Writes and runs tests
   - Reports bugs to `docs/bugs/`

5. **DevOps** (Terminal 5):
   - Monitors build health
   - Updates CI/CD if needed
   - Deploys to staging

### Task File Format

```markdown
# Task: User Authentication - Builder

## Status: IN-PROGRESS | COMPLETE | BLOCKED | NEEDS-INPUT

## Assigned To: Terminal 2 (Builder)

## Description
Implement the login form and user profile components.

## Requirements
- [ ] LoginForm component with email/password
- [ ] UserProfile component displaying user data
- [ ] Protected route wrapper

## Dependencies
- UserService from Terminal 3 (READY)
- AuthGuard from Terminal 3 (PENDING)

## Notes
[Any relevant context or decisions]
```

### Bug Report Format

```markdown
# BUG-001: Login form doesn't show validation errors

## Severity: Medium
## Found In: LoginForm component
## Assigned To: Terminal 2 (Builder)

## Description
Validation errors from the API are not displayed to users.

## Steps to Reproduce
1. Enter invalid email
2. Click submit
3. No error message appears

## Expected: Error message "Invalid email format"
## Actual: Form appears to do nothing

## Test File: tests/unit/LoginForm.test.ts:45
```

## tmux Reference

Once the workflow is running:

| Command | Action |
|---------|--------|
| `Ctrl+b` then arrow | Switch between panes |
| `Ctrl+b` then `z` | Zoom current pane (toggle) |
| `Ctrl+b` then `d` | Detach from session |
| `Ctrl+b` then `[` | Scroll mode (q to exit) |
| `tmux attach -t claude-workflow` | Reattach to session |
| `tmux kill-session -t claude-workflow` | End the session |

## Best Practices

### For the Human Operator

1. **Start with Architect** - Give Terminal 1 the feature overview first
2. **Monitor notifications** - Claude Code can notify when input needed
3. **Rotate attention** - Check each terminal periodically
4. **Let them coordinate** - Terminals communicate via files; let them work

### For Effective Parallelism

1. **Independent tasks work best** - Different features can run fully parallel
2. **Dependencies need sequencing** - Services before Builder for shared state
3. **Testing catches integration issues** - Let Terminal 4 verify continuously

### For Coordination

1. **Specs are the source of truth** - All terminals reference specs
2. **Task files track status** - Update status when starting/finishing
3. **Bugs get immediate attention** - Prioritize bug fixes over new work

## Customization

### Adding a 6th Terminal

1. Create `.claude/workflows/terminal-6-[role].md`
2. Update `scripts/launch-workflow.sh` to add a 6th pane
3. Define the role's responsibilities and file ownership

### Project-Specific Adaptation

Edit the workflow files to match your:
- Framework (React, Vue, Angular, etc.)
- Testing framework (Jest, Vitest, Playwright, etc.)
- Build system (Vite, Webpack, etc.)
- Deployment target (Vercel, AWS, etc.)

## Troubleshooting

### tmux session already exists
```bash
tmux kill-session -t claude-workflow
./scripts/launch-workflow.sh
```

### Claude Code not starting
Ensure Claude Code is installed and `claude` is in your PATH.

### Terminals losing context
Each Claude session is independent. Reference files and docs rather than expecting shared memory between terminals.

## Philosophy

This workflow embodies several key principles:

1. **Specialization** - Each terminal has clear ownership and expertise
2. **Parallelism** - Independent work streams run simultaneously
3. **Verification** - Continuous testing catches issues early
4. **Communication** - File-based coordination creates an audit trail
5. **Human oversight** - The developer orchestrates and makes decisions

The goal is not to replace the developer but to multiply their effectiveness by running parallel work streams that would otherwise require sequential attention.
