# Getting Started: Your First Parallel Workflow

This guide walks you through using the 5-terminal workflow to build a real feature. You'll learn how to orchestrate multiple Claude instances and coordinate their work.

## Key Concept: You Are the Orchestrator

The 5 terminals don't work autonomously - **you drive each one**. The power comes from running parallel conversations:

```
┌─────────────────────────────────────────────────────────────┐
│                         YOU                                  │
│                    (The Orchestrator)                        │
└─────────────────────────────────────────────────────────────┘
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
   ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
   │ T1     │ │ T2     │ │ T3     │ │ T4     │ │ T5     │
   │Architect│ │Builder │ │Services│ │Testing │ │DevOps  │
   └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

Each Claude works independently. You context-switch between them, giving instructions and checking progress.

## Step-by-Step Example: Building User Authentication

### Phase 1: Design (Terminal 1 - Architect)

**Switch to Terminal 1** (`Ctrl+b` then arrow keys)

```
You: Create a specification for user authentication with login,
     signup, and password reset. Break it into tasks for the
     other terminals.
```

The Architect will:
- Create `docs/specs/user-auth.md` with the full design
- Create task files:
  - `docs/tasks/user-auth-builder.md`
  - `docs/tasks/user-auth-services.md`
  - `docs/tasks/user-auth-testing.md`
  - `docs/tasks/user-auth-devops.md`

**Wait for completion**, then move on.

### Phase 2: Parallel Implementation (Terminals 2 & 3)

Now you can work two terminals in parallel:

**Switch to Terminal 3 (Services)**
```
You: Read docs/specs/user-auth.md and your tasks in
     docs/tasks/user-auth-services.md. Implement the
     authentication services.
```

**While Terminal 3 is working, switch to Terminal 2 (Builder)**
```
You: Read docs/specs/user-auth.md and your tasks in
     docs/tasks/user-auth-builder.md. Start implementing
     the UI components. Note: some services may still be
     in progress.
```

**Context-switch between them:**
- Check Terminal 3 - answer questions, approve decisions
- Check Terminal 2 - answer questions, approve decisions
- Repeat until both are done

### Phase 3: Integration

Once Services exports are ready, Builder can integrate:

**Terminal 2 (Builder)**
```
You: The services are ready. Connect your components to
     the UserService and AuthStore.
```

### Phase 4: Verification (Terminal 4 - Testing)

**Switch to Terminal 4**
```
You: Read the spec at docs/specs/user-auth.md. Write tests
     for the authentication feature - unit tests for services,
     component tests for UI, and integration tests for the
     full flow.
```

If tests fail, Testing will create bug reports:

**Terminal 4 creates** `docs/bugs/BUG-001.md`

**You then switch to the appropriate terminal:**
```
Terminal 3 (if service bug):
You: Check docs/bugs/BUG-001.md and fix the issue.

Terminal 2 (if UI bug):
You: Check docs/bugs/BUG-001.md and fix the issue.
```

### Phase 5: Build & Deploy (Terminal 5 - DevOps)

**Switch to Terminal 5**
```
You: Run the build and make sure everything compiles.
     Set up the CI pipeline for the auth feature.
```

## Workflow Patterns

### Pattern A: Sequential (Simpler)

Best for: Learning the workflow, complex dependencies

```
T1 (design) → T3 (services) → T2 (UI) → T4 (test) → T5 (deploy)
```

You complete each phase before moving to the next.

### Pattern B: Parallel Streams (Faster)

Best for: Features with independent parts

```
T1 (design) ─┬→ T3 (services) ─┬→ T4 (test) → T5 (deploy)
             └→ T2 (UI) ───────┘
```

Services and UI work simultaneously, then integrate.

### Pattern C: Continuous (Advanced)

Best for: Experienced users, larger features

```
T1: Designing Feature B
T2: Building Feature A components
T3: Implementing Feature A services
T4: Testing completed Feature A parts
T5: Deploying Feature A to staging
```

All 5 terminals working on different phases of different features.

## Tips for Effective Orchestration

### 1. Use tmux Navigation

| Keys | Action |
|------|--------|
| `Ctrl+b` → arrow | Switch panes |
| `Ctrl+b` → `z` | Zoom current pane (full screen) |
| `Ctrl+b` → `z` | Unzoom (back to grid) |

### 2. Check Progress Efficiently

Zoom into a terminal (`Ctrl+b z`), check status, give next instruction, then unzoom and move on.

### 3. Let Claude Finish

Don't interrupt mid-task. Wait for Claude to complete, then give the next instruction.

### 4. Use the File System

When switching to a terminal, tell it to check the docs:
```
You: Check docs/tasks/ for any new assignments and docs/bugs/
     for any issues you need to fix.
```

### 5. Keep Specs Updated

If requirements change, update the spec in Terminal 1 first, then notify other terminals:
```
Terminal 2: The spec has been updated. Re-read docs/specs/user-auth.md
            and adjust your implementation.
```

## Common Questions

### "What if Terminal 2 needs something from Terminal 3?"

Tell Terminal 2 to note the dependency and either:
- Wait (you'll come back after Terminal 3 is done)
- Work on other parts that don't have the dependency

### "What if I lose track of what each terminal is doing?"

Ask any terminal:
```
You: What are you currently working on? What's your status?
```

Or check the task files in `docs/tasks/` for status updates.

### "Can I run more than 5 terminals?"

Yes! Add more workflow definitions in `.claude/workflows/` and update the launch script. Common additions:
- Terminal 6: Documentation
- Terminal 7: Security Review
- Terminal 8: Performance Optimization

### "What if terminals have conflicting changes?"

This is where Terminal 1 (Architect) comes in:
```
Terminal 1: There's a conflict between the component structure
            from Terminal 2 and the service interface from
            Terminal 3. Review both and decide on the approach.
```

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│                  WORKFLOW QUICK REF                      │
├─────────────────────────────────────────────────────────┤
│ START NEW FEATURE                                        │
│   T1: "Design [feature], create tasks for other terms"  │
│                                                          │
│ CHECK FOR WORK                                           │
│   Any: "Check docs/tasks/ for assignments"              │
│                                                          │
│ REPORT COMPLETION                                        │
│   Any: "Update my task file to COMPLETE"                │
│                                                          │
│ HANDLE BUG                                               │
│   T4: Creates docs/bugs/BUG-XXX.md                      │
│   You: Tell relevant terminal to check and fix          │
│                                                          │
│ SYNC CHANGES                                             │
│   Any: "Re-read the spec, requirements changed"         │
│                                                          │
│ CHECK STATUS                                             │
│   Any: "What's your current status?"                    │
└─────────────────────────────────────────────────────────┘
```

## Next Steps

1. Launch the workflow: `./scripts/launch-workflow.sh`
2. Start in Terminal 1 with a simple feature
3. Practice the Sequential pattern first
4. Graduate to Parallel as you get comfortable

Remember: The workflow multiplies your effectiveness because you can context-switch between parallel work streams. Each Claude does focused work while you orchestrate the overall flow.
