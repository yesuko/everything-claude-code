#!/bin/bash
# Sync ECC + Apps-N-Mobile Master Brain to global Claude config

CLAUDE_DIR="$HOME/.claude"
SOURCE_DIR="/opt/yesuko/train_skill/trainer_1"

echo "🧠 Syncing Master Brain to $CLAUDE_DIR..."

# Create directories
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/rules"

# 1. Sync Agents
echo " - Syncing Agents..."
cp "$SOURCE_DIR/agents/"*.md "$CLAUDE_DIR/agents/"

# 2. Sync Commands
echo " - Syncing Commands..."
cp "$SOURCE_DIR/commands/"*.md "$CLAUDE_DIR/commands/"

# 3. Sync Skills (Core + User)
echo " - Syncing Skills..."
# Copy system skills
cp -r "$SOURCE_DIR/.agents/skills/"* "$CLAUDE_DIR/skills/"
# Copy project and community skills (Apps-N-Mobile consolidated here)
cp -r "$SOURCE_DIR/skills/"* "$CLAUDE_DIR/skills/"

# 4. Sync Rules (Always-follow Guidelines)
echo " - Syncing Rules..."
cp -r "$SOURCE_DIR/rules/common/"* "$CLAUDE_DIR/rules/"
# Sync popular languages
cp -r "$SOURCE_DIR/rules/typescript/"* "$CLAUDE_DIR/rules/"
cp -r "$SOURCE_DIR/rules/python/"* "$CLAUDE_DIR/rules/"

# 5. Sync Hooks and Scripts
echo " - Syncing Hooks and Scripts..."
cp "$SOURCE_DIR/hooks/hooks.json" "$CLAUDE_DIR/"
cp -r "$SOURCE_DIR/scripts/" "$CLAUDE_DIR/"

echo ""
echo "✅ Sync Complete! Your global Claude Brain is now powered by ECC + Apps-N-Mobile."
echo "💡 To use these in any project, simply type '/' to see the new commands."
