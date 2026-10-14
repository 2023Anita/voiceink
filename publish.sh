#!/bin/bash
#
# VoiceInk GitHub Publication Script
# This script creates the public GitHub repository and pushes all code
#

set -e

REPO_OWNER="2023Anita"
REPO_NAME="voiceink"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
REPO_URL="https://github.com/${REPO_FULL}"

echo "================================================================"
echo "  VoiceInk GitHub Publication"
echo "  Target: ${REPO_URL}"
echo "================================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Package.swift not found. Please run this script from the VoiceInk root directory."
    exit 1
fi

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo ""
    echo "Install it with:"
    echo "  brew install gh"
    echo ""
    exit 1
fi

# Check authentication
echo "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo ""
    echo "⚠️  You need to authenticate with GitHub first."
    echo ""
    echo "Run:"
    echo "  gh auth login"
    echo ""
    echo "Make sure to log in as: ${REPO_OWNER}"
    echo ""
    exit 1
fi

# Get current GitHub user
CURRENT_USER=$(gh api user --jq .login 2>/dev/null || echo "unknown")
echo "✓ Authenticated as: ${CURRENT_USER}"

if [ "${CURRENT_USER}" != "${REPO_OWNER}" ]; then
    echo ""
    echo "⚠️  WARNING: You are logged in as '${CURRENT_USER}'"
    echo "   Expected: '${REPO_OWNER}'"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted. Please log in as ${REPO_OWNER} and try again."
        exit 1
    fi
fi

# Check if repository already exists
echo ""
echo "Checking if repository exists..."
if gh repo view "${REPO_FULL}" &> /dev/null; then
    echo ""
    echo "⚠️  Repository ${REPO_FULL} already exists!"
    echo ""
    echo "Options:"
    echo "  1. Push to existing repository"
    echo "  2. Use alternative name: ${REPO_NAME}-macos"
    echo "  3. Abort"
    echo ""
    read -p "Choose (1/2/3): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            echo "Proceeding with existing repository..."
            ;;
        2)
            REPO_NAME="${REPO_NAME}-macos"
            REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
            REPO_URL="https://github.com/${REPO_FULL}"
            echo "Using alternative name: ${REPO_FULL}"
            ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
fi

# Create repository if it doesn't exist
if ! gh repo view "${REPO_FULL}" &> /dev/null; then
    echo ""
    echo "Creating public repository: ${REPO_FULL}"
    gh repo create "${REPO_FULL}" \
        --public \
        --description "Open-source macOS menu bar app for AI voice dictation with smart text polishing and seamless injection" \
        --source=. \
        --remote=github \
        --push
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Repository created and code pushed!"
    else
        echo ""
        echo "❌ Failed to create repository. See error above."
        exit 1
    fi
else
    # Repository exists, just push
    echo ""
    echo "Adding remote 'github' (if not exists)..."
    if ! git remote get-url github &> /dev/null; then
        git remote add github "${REPO_URL}.git"
        echo "✓ Remote added"
    else
        echo "✓ Remote already exists"
    fi
    
    echo ""
    echo "Pushing to GitHub..."
    git push github main --force
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Code pushed to existing repository!"
    else
        echo ""
        echo "❌ Failed to push. See error above."
        exit 1
    fi
fi

# Set repository topics
echo ""
echo "Setting repository topics..."
gh repo edit "${REPO_FULL}" --add-topic macos,swift,swiftui,voice-input,ai,whisper,gpt,dictation,speech-to-text,menu-bar-app,productivity,open-source 2>/dev/null || echo "⚠️  Could not set topics (this is optional)"

echo ""
echo "================================================================"
echo "  ✅ SUCCESS!"
echo "================================================================"
echo ""
echo "🎉 VoiceInk is now public on GitHub!"
echo ""
echo "📍 Repository URL:"
echo "   ${REPO_URL}"
echo ""
echo "📋 Clone command:"
echo "   git clone ${REPO_URL}.git"
echo ""
echo "🚀 Next steps:"
echo "   1. Visit ${REPO_URL}"
echo "   2. Check that README and images display correctly"
echo "   3. Test clone and build on a Mac"
echo "   4. (Optional) Create a release: gh release create v1.0.0"
echo ""
echo "📚 See PUBLISH.md for post-publication steps"
echo ""
