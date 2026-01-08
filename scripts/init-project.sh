#!/bin/bash
#
# Initialize a fresh project from the AI Workers boilerplate
#
# This script:
# - Removes the boilerplate's git history
# - Initializes a new git repository
# - Creates an initial commit
# - Optionally sets up a remote
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the project root (parent of scripts directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT" || exit 1

echo -e "${BLUE}AI Workers - Project Initializer${NC}"
echo ""

# Check if .git exists
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}No git repository found. Initializing fresh...${NC}"
else
    echo -e "${YELLOW}This will remove the existing git history and start fresh.${NC}"
    echo ""
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted.${NC}"
        exit 1
    fi

    # Remove existing git repository
    echo -e "${GREEN}Removing existing git history...${NC}"
    rm -rf .git
fi

# Initialize new repository
echo -e "${GREEN}Initializing new git repository...${NC}"
git init

# Ask for project name
echo ""
read -p "Enter your project name (leave blank to keep 'ai-workers'): " PROJECT_NAME

if [ -n "$PROJECT_NAME" ]; then
    # Update README title
    if [ -f "README.md" ]; then
        sed -i '' "s/# AI Workers - Parallel Claude Code Workflow Boilerplate/# $PROJECT_NAME/" README.md 2>/dev/null || \
        sed -i "s/# AI Workers - Parallel Claude Code Workflow Boilerplate/# $PROJECT_NAME/" README.md
        echo -e "${GREEN}Updated README.md with project name${NC}"
    fi
fi

# Ask for remote
echo ""
read -p "Enter git remote URL (leave blank to skip): " REMOTE_URL

if [ -n "$REMOTE_URL" ]; then
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}Added remote: $REMOTE_URL${NC}"
fi

# Stage all files
echo -e "${GREEN}Staging files...${NC}"
git add -A

# Create initial commit
echo -e "${GREEN}Creating initial commit...${NC}"
git commit -m "Initial commit: Project setup from AI Workers boilerplate"

echo ""
echo -e "${GREEN}Done! Your project is ready.${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Launch the workflow:  ./scripts/launch-workflow.sh"
echo "  2. Customize workflows:  Edit files in .claude/workflows/"
echo "  3. Add your code:        Initialize your framework of choice"
if [ -n "$REMOTE_URL" ]; then
    echo "  4. Push to remote:       git push -u origin main"
fi
echo ""
