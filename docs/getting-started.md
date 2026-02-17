# Getting Started

Your machine is set up. Here's how to start building.

## 1. Set up your AI provider

Run this and follow the prompts:

    opencode auth login

You'll need an API key from a provider like Anthropic or OpenAI.
If you don't have one yet, contact IT or sign up at one of these:
- https://console.anthropic.com (Claude)
- https://platform.openai.com (GPT)

## 2. Start OpenCode

    opencode

Describe what you want to build in plain English. OpenCode will write the code for you.

## 3. Tips

- **Plan first**: Say "plan how to build X" before "build it"
- **Resume work**: Run `opencode` again to continue where you left off
- **Updates are automatic**: oh-my-opencode checks for updates when you start a session

## 4. If something goes wrong

Run the verification script:

    ~/repos/dev-bootstrap/scripts/verify.sh
