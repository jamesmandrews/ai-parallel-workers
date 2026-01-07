# AI Workers - Parallel Claude Code Workflow Boilerplate

A boilerplate for running 5 parallel Claude Code instances as specialized AI agents, based on Boris Cherny's workflow pattern from Anthropic.

> "I run 5 Claudes in parallel in my terminal. I number my tabs 1-5, and use system notifications to know when a Claude needs input."
> — Boris Cherny, Creator of Claude Code

## What This Is

This boilerplate provides a ready-to-use structure for starting new projects with a 5-terminal Claude Code workflow. Each terminal has a specialized role, enabling one developer to operate with the productivity of an entire engineering team.

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed (`claude` command available)
- [tmux](https://github.com/tmux/tmux) installed (`brew install tmux` on macOS)

### Launch the Workflow

```bash
./scripts/launch-workflow.sh
```

This opens a tmux session with 5 Claude Code instances, each pre-configured with its role.

## The 5 Terminals

```
┌─────────────────┬─────────────────┐
│  1. Architect   │   2. Builder    │
│  Design & Spec  │   UI & Views    │
├─────────────────┼─────────────────┤
│  3. Services    │   4. Testing    │
│  Logic & State  │   QA & Verify   │
├─────────────────┴─────────────────┤
│           5. DevOps               │
│      Build, Deploy, Monitor       │
└───────────────────────────────────┘
```

| # | Terminal | Focus |
|---|----------|-------|
| 1 | **Architect** | System design, specifications, task coordination |
| 2 | **Builder** | UI components, views, styling |
| 3 | **Services** | Business logic, state management, APIs |
| 4 | **Testing** | Tests, verification loops, bug reports |
| 5 | **DevOps** | Build system, CI/CD, deployment |

## Project Structure

```
.
├── .claude/
│   └── workflows/           # Role definitions for each terminal
│       ├── terminal-1-architect.md
│       ├── terminal-2-builder.md
│       ├── terminal-3-services.md
│       ├── terminal-4-testing.md
│       ├── terminal-5-devops.md
│       └── README.md        # Detailed workflow documentation
├── docs/
│   ├── specs/               # Feature specifications
│   ├── tasks/               # Task assignments per terminal
│   ├── bugs/                # Bug reports from testing
│   └── completed/           # Archived completed work
├── scripts/
│   └── launch-workflow.sh   # tmux launcher
└── README.md                # This file
```

## Important: You Are the Orchestrator

The 5 terminals don't work autonomously - **you drive each one**. You context-switch between parallel conversations, giving instructions and checking progress. The power comes from running multiple focused work streams simultaneously.

**New to this workflow?** Start with the [Getting Started Guide](docs/GETTING-STARTED.md) for a step-by-step walkthrough.

## How It Works

### File-Based Coordination

Terminals communicate through the `docs/` directory:

1. **Architect** writes specs to `docs/specs/feature-name.md`
2. **Architect** creates task files in `docs/tasks/` for each terminal
3. **Builder/Services** pick up their tasks and implement
4. **Testing** verifies and creates bug reports in `docs/bugs/`
5. **DevOps** monitors builds and deploys

### Verification Loops

Terminal 4 (Testing) continuously:
- Monitors implementations from other terminals
- Runs tests against specifications
- Reports bugs that other terminals fix
- Creates a feedback loop ensuring quality

## Adapting for Your Project

This boilerplate is **framework-agnostic**. To adapt it:

1. **Add your project files** - Initialize your framework (React, Angular, etc.)
2. **Customize workflow files** - Update `.claude/workflows/` with framework-specific guidance
3. **Launch and work** - Start the workflow and begin building

### Example: React Project

```bash
# Initialize React
npm create vite@latest . -- --template react-ts

# Launch the workflow
./scripts/launch-workflow.sh

# In Terminal 1 (Architect):
"Create a spec for user authentication with login, signup, and password reset"
```

## tmux Basics

| Command | Action |
|---------|--------|
| `Ctrl+b` then arrows | Navigate between terminals |
| `Ctrl+b` then `z` | Zoom/unzoom current terminal |
| `Ctrl+b` then `d` | Detach (leave running in background) |
| `tmux attach -t claude-workflow` | Reattach to session |

## Documentation

- [Getting Started Guide](docs/GETTING-STARTED.md) - Step-by-step walkthrough with examples
- [Workflow Details](.claude/workflows/README.md) - Complete workflow documentation
- [Terminal 1 - Architect](.claude/workflows/terminal-1-architect.md)
- [Terminal 2 - Builder](.claude/workflows/terminal-2-builder.md)
- [Terminal 3 - Services](.claude/workflows/terminal-3-services.md)
- [Terminal 4 - Testing](.claude/workflows/terminal-4-testing.md)
- [Terminal 5 - DevOps](.claude/workflows/terminal-5-devops.md)

## Tips for Effective Use

1. **Start with Terminal 1** - Give the Architect your feature requirements first
2. **You orchestrate** - Context-switch between terminals, giving each instructions
3. **Use the file system** - Tell terminals to check `docs/tasks/` for assignments
4. **Rotate your attention** - Check each terminal periodically for questions
5. **Trust the verification loop** - Testing terminal catches integration issues

## License

MIT
