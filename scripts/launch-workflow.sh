#!/bin/bash
#
# 5-Terminal Claude Code Workflow Launcher
# Based on Boris Cherny's parallel Claude workflow pattern
#
# Creates 5 terminal panes, each running Claude Code
# with a specific role/workflow assigned.
#
# Usage:
#   ./launch-workflow.sh          # Uses Zellij (default)
#   ./launch-workflow.sh --zellij # Uses Zellij explicitly
#   ./launch-workflow.sh --tmux   # Uses tmux
#   ./launch-workflow.sh --iterm  # Uses iTerm2 (macOS only)
#

SESSION_NAME="claude-workflow"
WORKFLOW_DIR=".claude/workflows"
MODE="zellij"  # Default mode

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tmux)
            MODE="tmux"
            shift
            ;;
        --iterm|--iterm2)
            MODE="iterm"
            shift
            ;;
        --zellij)
            MODE="zellij"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--zellij|--tmux|--iterm]"
            echo ""
            echo "Options:"
            echo "  --zellij Use Zellij (default)"
            echo "  --tmux   Use tmux"
            echo "  --iterm  Use iTerm2 (macOS only)"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

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

# Mode-specific checks
if [ "$MODE" = "tmux" ]; then
    if ! command -v tmux &> /dev/null; then
        echo -e "${RED}Error: tmux is not installed${NC}"
        echo "Install with: brew install tmux (macOS) or apt install tmux (Linux)"
        echo "Or try: $0 --iterm (for iTerm2 on macOS)"
        exit 1
    fi
elif [ "$MODE" = "iterm" ]; then
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}Error: iTerm2 mode is only available on macOS${NC}"
        exit 1
    fi
    if ! osascript -e 'tell application "System Events" to (name of processes) contains "iTerm2"' &>/dev/null; then
        # Check if iTerm2 is installed (even if not running)
        if [ ! -d "/Applications/iTerm.app" ]; then
            echo -e "${RED}Error: iTerm2 is not installed${NC}"
            echo "Download from: https://iterm2.com/"
            exit 1
        fi
    fi
elif [ "$MODE" = "zellij" ]; then
    if ! command -v zellij &> /dev/null; then
        echo -e "${RED}Error: Zellij is not installed${NC}"
        echo "Install with: brew install zellij (macOS) or cargo install zellij"
        exit 1
    fi
fi

echo -e "${BLUE}Launching 5-Terminal Claude Workflow ($MODE mode)...${NC}"
echo ""

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

# Get the current working directory for iTerm2
WORKING_DIR="$(pwd)"

#######################################
# Launch using tmux
#######################################
launch_tmux() {
    # Kill existing session if it exists
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null

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

    # Send commands to each pane
    for i in {0..4}; do
        echo -e "${GREEN}Setting up ${TERMINALS[$i]}...${NC}"

        # Send a clear and header to each pane
        tmux send-keys -t "$SESSION_NAME:0.$i" "clear && echo '═══════════════════════════════════════════' && echo '  ${TERMINALS[$i]}' && echo '═══════════════════════════════════════════' && echo ''" Enter

        # Small delay to let the echo complete
        sleep 0.2

        # Start Claude Code with the role prompt
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
}

#######################################
# Launch using iTerm2
#######################################
launch_iterm() {
    echo -e "${GREEN}Setting up iTerm2 with 5 split panes...${NC}"

    # Build the AppleScript to create split panes in a grid layout:
    # +-------+-------+
    # |   1   |   2   |
    # +-------+-------+
    # |   3   |   4   |
    # +-------+-------+
    # |       5       |
    # +---------------+

    osascript <<EOF
tell application "iTerm"
    activate
    delay 0.3

    -- Create new window
    create window with default profile

    tell current window
        -- Initial session will become T1-Architect (top-left)
        set session1 to current session

        -- Split horizontally: creates bottom section (will be T5-DevOps)
        tell session1
            set session5 to (split horizontally with default profile)
        end tell
        delay 0.2

        -- Split session1 horizontally again: creates middle-left (will be T3-Services)
        tell session1
            set session3 to (split horizontally with default profile)
        end tell
        delay 0.2

        -- Split session1 vertically: creates top-right (T2-Builder)
        tell session1
            set session2 to (split vertically with default profile)
        end tell
        delay 0.2

        -- Split session3 vertically: creates middle-right (T4-Testing)
        tell session3
            set session4 to (split vertically with default profile)
        end tell
        delay 0.2

        -- Configure T1-Architect (top-left)
        tell session1
            set name to "T1-Architect"
            write text "cd '$WORKING_DIR' && clear && echo '═══════════════════════════════════════════' && echo '  Terminal 1 - Architect' && echo '═══════════════════════════════════════════' && echo '' && claude --system-prompt \"${PROMPTS[0]}\""
        end tell

        -- Configure T2-Builder (top-right)
        tell session2
            set name to "T2-Builder"
            write text "cd '$WORKING_DIR' && clear && echo '═══════════════════════════════════════════' && echo '  Terminal 2 - Builder' && echo '═══════════════════════════════════════════' && echo '' && claude --system-prompt \"${PROMPTS[1]}\""
        end tell

        -- Configure T3-Services (middle-left)
        tell session3
            set name to "T3-Services"
            write text "cd '$WORKING_DIR' && clear && echo '═══════════════════════════════════════════' && echo '  Terminal 3 - Services' && echo '═══════════════════════════════════════════' && echo '' && claude --system-prompt \"${PROMPTS[2]}\""
        end tell

        -- Configure T4-Testing (middle-right)
        tell session4
            set name to "T4-Testing"
            write text "cd '$WORKING_DIR' && clear && echo '═══════════════════════════════════════════' && echo '  Terminal 4 - Testing' && echo '═══════════════════════════════════════════' && echo '' && claude --system-prompt \"${PROMPTS[3]}\""
        end tell

        -- Configure T5-DevOps (bottom full-width)
        tell session5
            set name to "T5-DevOps"
            write text "cd '$WORKING_DIR' && clear && echo '═══════════════════════════════════════════' && echo '  Terminal 5 - DevOps' && echo '═══════════════════════════════════════════' && echo '' && claude --system-prompt \"${PROMPTS[4]}\""
        end tell

        -- Select the Architect pane
        select session1
    end tell
end tell

-- Hide the tab bar since we're using panes, not tabs
tell application "System Events"
    tell process "iTerm2"
        if exists menu item "Hide Tab Bar" of menu "View" of menu bar 1 then
            click menu item "Hide Tab Bar" of menu "View" of menu bar 1
        end if
    end tell
end tell

-- Hide per-pane title bars (menu says "Hide" when they're currently visible)
tell application "System Events"
    tell process "iTerm2"
        if exists menu item "Hide Per-Pane Title Bars" of menu "View" of menu bar 1 then
            click menu item "Hide Per-Pane Title Bars" of menu "View" of menu bar 1
        end if
    end tell
end tell
EOF

    echo ""
    echo -e "${GREEN}Workflow launched successfully in iTerm2!${NC}"
    echo ""
    echo -e "${YELLOW}iTerm2 Quick Reference:${NC}"
    echo "  Switch panes:    Cmd+Option+Arrow keys"
    echo "  Next pane:       Cmd+] "
    echo "  Previous pane:   Cmd+["
    echo "  Maximize pane:   Cmd+Shift+Enter (toggle)"
    echo "  Close pane:      Cmd+W"
    echo "  New split vert:  Cmd+D"
    echo "  New split horiz: Cmd+Shift+D"
    echo ""
}

#######################################
# Launch using Zellij
#######################################
launch_zellij() {
    echo -e "${GREEN}Setting up Zellij with 5 panes...${NC}"

    # Create a temporary directory for all temp files
    TEMP_DIR=$(mktemp -d -t claude-workflow)
    LAYOUT_FILE="$TEMP_DIR/layout.kdl"
    SCRIPT_DIR="$TEMP_DIR/scripts"
    mkdir -p "$SCRIPT_DIR"

    for i in {0..4}; do
        cat > "$SCRIPT_DIR/terminal-$((i+1)).sh" << SCRIPT_EOF
#!/bin/bash
cd "$WORKING_DIR"
clear
echo '═══════════════════════════════════════════'
echo '  ${TERMINALS[$i]}'
echo '═══════════════════════════════════════════'
echo ''
exec claude --system-prompt "${PROMPTS[$i]}"
SCRIPT_EOF
        chmod +x "$SCRIPT_DIR/terminal-$((i+1)).sh"
    done

    # Write the layout configuration
    cat > "$LAYOUT_FILE" << LAYOUT_EOF
layout {
    pane split_direction="horizontal" size="100%" {
        pane split_direction="vertical" size="35%" {
            pane size="50%" name="T1-Architect" {
                command "bash"
                args "$SCRIPT_DIR/terminal-1.sh"
            }
            pane size="50%" name="T2-Builder" {
                command "bash"
                args "$SCRIPT_DIR/terminal-2.sh"
            }
        }
        pane split_direction="vertical" size="35%" {
            pane size="50%" name="T3-Services" {
                command "bash"
                args "$SCRIPT_DIR/terminal-3.sh"
            }
            pane size="50%" name="T4-Testing" {
                command "bash"
                args "$SCRIPT_DIR/terminal-4.sh"
            }
        }
        pane size="30%" name="T5-DevOps" {
            command "bash"
            args "$SCRIPT_DIR/terminal-5.sh"
        }
    }
}
LAYOUT_EOF

    echo ""
    echo -e "${GREEN}Zellij layout created. Launching...${NC}"
    echo ""
    echo -e "${YELLOW}Zellij Quick Reference:${NC}"
    echo "  Switch panes:    Alt+Arrow keys or Alt+h/j/k/l"
    echo "  Next pane:       Alt+n"
    echo "  Previous pane:   Alt+p"
    echo "  Fullscreen pane: Ctrl+p, f"
    echo "  Close pane:      Ctrl+p, x"
    echo "  New pane:        Ctrl+p, n"
    echo "  Detach:          Ctrl+o, d"
    echo "  Reattach:        zellij attach $SESSION_NAME"
    echo "  Mode help:       Ctrl+p (pane) / Ctrl+t (tab)"
    echo ""

    # Kill existing session if it exists (suppress all output)
    zellij delete-session "$SESSION_NAME" >/dev/null 2>&1 || true

    # Launch Zellij with the layout
    zellij --layout "$LAYOUT_FILE"

    # Cleanup (runs after zellij exits)
    rm -rf "$TEMP_DIR"
}

#######################################
# Main: Launch based on mode
#######################################
if [ "$MODE" = "tmux" ]; then
    launch_tmux
elif [ "$MODE" = "iterm" ]; then
    launch_iterm
elif [ "$MODE" = "zellij" ]; then
    launch_zellij
fi
