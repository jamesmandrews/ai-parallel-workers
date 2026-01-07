#!/bin/bash
#
# 5-Terminal Claude Code Workflow Launcher
# Based on Boris Cherny's parallel Claude workflow pattern
#
# Creates a tmux session with 5 panes, each running Claude Code
# with a specific role/workflow assigned.
#

SESSION_NAME="claude-workflow"
WORKFLOW_DIR=".claude/workflows"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for tmux
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed${NC}"
    echo "Install with: brew install tmux (macOS) or apt install tmux (Linux)"
    exit 1
fi

# Check for Claude Code
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code CLI is not installed${NC}"
    echo "Visit: https://claude.ai/claude-code for installation"
    exit 1
fi

# Check if workflow files exist
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo -e "${RED}Error: Workflow directory not found at $WORKFLOW_DIR${NC}"
    echo "Run this script from the project root directory"
    exit 1
fi

# Kill existing session if it exists
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

echo -e "${BLUE}Launching 5-Terminal Claude Workflow...${NC}"
echo ""

# Create new tmux session with first window
tmux new-session -d -s "$SESSION_NAME" -n "workflow"

# Create the layout: 2x2 grid on top, full width on bottom
# Split horizontally first (creates top and bottom)
tmux split-window -v -t "$SESSION_NAME:0"

# Split the top pane into 2 (left-right)
tmux split-window -h -t "$SESSION_NAME:0.0"

# Split the top-left into 2 (top-bottom) - this gives us 4 panes on top
tmux split-window -v -t "$SESSION_NAME:0.0"

# Split the top-right into 2 (top-bottom)
tmux split-window -v -t "$SESSION_NAME:0.2"

# Now we have 5 panes. Arrange them nicely.
tmux select-layout -t "$SESSION_NAME:0" tiled

# Define the terminals and their workflows
declare -a TERMINALS=(
    "Terminal 1 - Architect"
    "Terminal 2 - Builder"
    "Terminal 3 - Services"
    "Terminal 4 - Testing"
    "Terminal 5 - DevOps"
)

declare -a WORKFLOW_FILES=(
    "terminal-1-architect.md"
    "terminal-2-builder.md"
    "terminal-3-services.md"
    "terminal-4-testing.md"
    "terminal-5-devops.md"
)

declare -a PROMPTS=(
    "I am Terminal 1 - Architect. Read .claude/workflows/terminal-1-architect.md for my role. I design architecture, write specs, and coordinate."
    "I am Terminal 2 - Builder. Read .claude/workflows/terminal-2-builder.md for my role. I implement UI components and views."
    "I am Terminal 3 - Services. Read .claude/workflows/terminal-3-services.md for my role. I build services, state, and API integrations."
    "I am Terminal 4 - Testing. Read .claude/workflows/terminal-4-testing.md for my role. I write tests and verify implementations."
    "I am Terminal 5 - DevOps. Read .claude/workflows/terminal-5-devops.md for my role. I manage builds, CI/CD, and deployments."
)

# Send commands to each pane
for i in {0..4}; do
    echo -e "${GREEN}Setting up ${TERMINALS[$i]}...${NC}"

    # Send a clear and header to each pane
    tmux send-keys -t "$SESSION_NAME:0.$i" "clear && echo '═══════════════════════════════════════════' && echo '  ${TERMINALS[$i]}' && echo '═══════════════════════════════════════════' && echo ''" Enter

    # Small delay to let the echo complete
    sleep 0.2

    # Start Claude Code with the role prompt
    # Using --print to show the system prompt, then interactive mode
    tmux send-keys -t "$SESSION_NAME:0.$i" "claude --system-prompt \"${PROMPTS[$i]}\"" Enter
done

echo ""
echo -e "${GREEN}Workflow launched successfully!${NC}"
echo ""
echo -e "${YELLOW}tmux Quick Reference:${NC}"
echo "  Switch panes:  Ctrl+b, then arrow keys"
echo "  Zoom pane:     Ctrl+b, then z (toggle)"
echo "  Detach:        Ctrl+b, then d"
echo "  Reattach:      tmux attach -t $SESSION_NAME"
echo "  Kill session:  tmux kill-session -t $SESSION_NAME"
echo ""
echo -e "${BLUE}Attaching to session...${NC}"
echo ""

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
