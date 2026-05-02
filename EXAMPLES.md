# Examples

Practical examples for using Joplin MCP v1.8.5 with OpenCode and other MCP clients.

## Table of Contents

1. [Creating a WiKi_LLM Notebook](#creating-a-wiki_llm-notebook)
2. [Managing Project Documentation](#managing-project-documentation)
3. [Organising Meeting Notes](#organising-meeting-notes)
4. [Tag-Based Workflow](#tag-based-workflow)
5. [Daily Journal System](#daily-journal-system)
6. [Knowledge Base Management](#knowledge-base-management)

---

## Creating a WiKi_LLM Notebook

This example demonstrates creating a structured knowledge base for LLM (Large Language Model) documentation.

### Step 1: Create the Main Notebook

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "WiKi_LLM"
  }
}
```

**Result:**
```
Created notebook 'WiKi_LLM' (ID: abc123def456)
```

### Step 2: Create Sub-Notebooks

Create organised sub-notebooks for different categories:

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Models",
    "parent_id": "abc123def456"
  }
}
```

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "APIs",
    "parent_id": "abc123def456"
  }
}
```

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Tutorials",
    "parent_id": "abc123def456"
  }
}
```

### Step 3: Add Content to Models Notebook

```json
{
  "name": "create_note",
  "arguments": {
    "title": "GPT-4 Overview",
    "body": "# GPT-4\n\n## Overview\nGPT-4 is a large multimodal model developed by OpenAI.\n\n## Key Features\n- 128K context window\n- Multimodal (text and images)\n- Advanced reasoning\n\n## API Pricing\n- Input: $0.03 per 1K tokens\n- Output: $0.06 per 1K tokens\n\n## Use Cases\n1. Content generation\n2. Code assistance\n3. Data analysis\n4. Creative writing",
    "notebook_id": "models-notebook-id",
    "tags": ["openai", "gpt4", "overview"]
  }
}
```

### Step 4: Create API Documentation

```json
{
  "name": "create_note",
  "arguments": {
    "title": "OpenAI API Quick Reference",
    "body": "# OpenAI API Reference\n\n## Authentication\n```python\nimport openai\nopenai.api_key = \"your-api-key\"\n```\n\n## Chat Completion\n```python\nresponse = openai.ChatCompletion.create(\n    model=\"gpt-4\",\n    messages=[\n        {\"role\": \"system\", \"content\": \"You are a helpful assistant.\"},\n        {\"role\": \"user\", \"content\": \"Hello!\"}\n    ]\n)\n```\n\n## Error Handling\nCommon errors and solutions...",
    "notebook_id": "apis-notebook-id",
    "tags": ["openai", "api", "reference"]
  }
}
```

---

## Managing Project Documentation

### Scenario: Documenting a Software Project

**Step 1: Create Project Notebook**

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Project Alpha"
  }
}
```

**Step 2: Create README Note**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "README",
    "body": "# Project Alpha\n\n## Description\nA comprehensive documentation system for...\n\n## Installation\n```bash\ngit clone https://github.com/example/project-alpha\ncd project-alpha\nmake install\n```\n\n## Usage\n...",
    "notebook_id": "project-alpha-id",
    "tags": ["readme", "project-alpha"]
  }
}
```

**Step 3: Add Architecture Documentation**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Architecture Decision Records",
    "body": "# ADR-001: Database Selection\n\n## Status\nAccepted\n\n## Context\nWe need to choose a database for...\n\n## Decision\nWe will use PostgreSQL...\n\n## Consequences\n- Positive: ACID compliance, JSON support\n- Negative: Additional operational complexity",
    "notebook_id": "project-alpha-id",
    "tags": ["adr", "architecture", "database"]
  }
}
```

**Step 4: Update When Requirements Change**

```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "readme-note-id",
    "body": "# Project Alpha\n\n## Description\nUpdated description with new features...\n\n## New Features\n- Feature 1\n- Feature 2\n- Feature 3"
  }
}
```

---

## Organising Meeting Notes

### Workflow: Weekly Team Meetings

**Step 1: Create Meeting Notes Notebook**

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Team Meetings 2025"
  }
}
```

**Step 2: Create Weekly Meeting Note**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Week 15 - Sprint Planning",
    "body": "# Sprint Planning - Week 15\n\n**Date:** 14 April 2025\n**Attendees:** Alice, Bob, Charlie\n\n## Agenda\n1. Review last sprint\n2. Plan next sprint\n3. Discuss blockers\n\n## Decisions\n- [ ] Task 1 assigned to Alice\n- [ ] Task 2 assigned to Bob\n- [ ] Task 3 assigned to Charlie\n\n## Action Items\n- Alice: Prepare API documentation\n- Bob: Fix authentication bug\n- Charlie: Update deployment scripts",
    "notebook_id": "team-meetings-id",
    "tags": ["meeting", "sprint", "2025", "week15"]
  }
}
```

**Step 3: Update After Meeting**

```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "week15-meeting-id",
    "body": "# Sprint Planning - Week 15\n\n**Date:** 14 April 2025\n**Attendees:** Alice, Bob, Charlie\n\n## Agenda\n1. ✅ Review last sprint\n2. ✅ Plan next sprint\n3. ✅ Discuss blockers\n\n## Decisions Made\n- Sprint velocity: 45 points\n- Focus on API stability\n- Delay feature X to next quarter\n\n## Action Items - COMPLETED\n- ✅ Alice: Prepare API documentation\n- ✅ Bob: Fix authentication bug\n- ⏳ Charlie: Update deployment scripts (in progress)"
  }
}
```

**Step 4: Add Tags for Easy Finding**

```json
{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "week15-meeting-id",
    "tags": ["completed", "sprint-23"]
  }
}
```

---

## Tag-Based Workflow

### Using Tags for Organisation

**Step 1: Create Notes with Tags**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Docker Best Practices",
    "body": "# Docker Best Practices\n\n1. Use multi-stage builds\n2. Minimise layer count\n3. Use .dockerignore\n4. Don't run as root\n5. Scan for vulnerabilities",
    "tags": ["docker", "best-practices", "devops"]
  }
}
```

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Kubernetes Cheat Sheet",
    "body": "# Kubernetes Commands\n\n## Pods\n```bash\nkubectl get pods\nkubectl describe pod <name>\nkubectl logs <pod-name>\n```\n\n## Deployments\n...",
    "tags": ["kubernetes", "cheatsheet", "devops"]
  }
}
```

**Step 2: Search by Tag**

```json
{
  "name": "search_notes",
  "arguments": {
    "query": "devops"
  }
}
```

**Step 3: Add Urgent Tag to Critical Notes**

```json
{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "security-checklist-id",
    "tags": ["urgent", "security", "review"]
  }
}
```

**Step 4: Remove Tag When Done**

```json
{
  "name": "remove_tags_from_note",
  "arguments": {
    "note_id": "security-checklist-id",
    "tags": ["urgent"]
  }
}
```

---

## Daily Journal System

### Personal Knowledge Management

**Step 1: Create Journal Notebook**

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Daily Journal 2025"
  }
}
```

**Step 2: Create Daily Entry Template**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "2025-04-14 - Monday",
    "body": "# Daily Journal - 14 April 2025\n\n## Morning\n- [ ] Review emails\n- [ ] Check calendar\n- [ ] Prioritise tasks\n\n## Work Log\n- 09:00: Started project review\n- 11:30: Team standup\n- 14:00: Client meeting\n- 16:00: Code review\n\n## Learned Today\n- New Python feature: walrus operator\n- Git rebase vs merge strategies\n\n## Tomorrow's Goals\n1. Complete API documentation\n2. Review pull requests\n3. Prepare for sprint demo",
    "notebook_id": "journal-2025-id",
    "tags": ["journal", "2025", "april", "week16"]
  }
}
```

**Step 3: Update Throughout the Day**

```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "2025-04-14-entry-id",
    "body": "# Daily Journal - 14 April 2025\n\n## Morning\n- [x] Review emails\n- [x] Check calendar\n- [x] Prioritise tasks\n\n## Work Log\n- 09:00: Started project review ✅\n- 11:30: Team standup ✅\n- 14:00: Client meeting ✅\n- 16:00: Code review ⏳\n\n## Learned Today\n- New Python feature: walrus operator\n- Git rebase vs merge strategies\n- Kubernetes rolling updates\n\n## Achievements\n- Completed API documentation\n- Fixed 3 bugs\n- Helped teammate with deployment\n\n## Tomorrow's Goals\n1. Review pull requests\n2. Prepare for sprint demo\n3. Plan next sprint"
  }
}
```

---

## Knowledge Base Management

### Building a Technical Knowledge Base

**Step 1: Create Knowledge Base Structure**

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Technical Knowledge Base"
  }
}
```

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "Python",
    "parent_id": "knowledge-base-id"
  }
}
```

```json
{
  "name": "create_notebook",
  "arguments": {
    "name": "JavaScript",
    "parent_id": "knowledge-base-id"
  }
}
```

**Step 2: Populate with Code Examples**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Python Decorators Explained",
    "body": "# Python Decorators\n\n## Basic Decorator\n```python\ndef my_decorator(func):\n    def wrapper():\n        print(\"Before function call\")\n        func()\n        print(\"After function call\")\n    return wrapper\n\n@my_decorator\ndef say_hello():\n    print(\"Hello!\")\n```\n\n## Decorator with Arguments\n```python\ndef repeat(num):\n    def decorator(func):\n        def wrapper(*args, **kwargs):\n            for _ in range(num):\n                result = func(*args, **kwargs)\n            return result\n        return wrapper\n    return decorator\n\n@repeat(3)\ndef greet(name):\n    print(f\"Hello {name}!\")\n```",
    "notebook_id": "python-notebook-id",
    "tags": ["python", "decorators", "advanced", "examples"]
  }
}
```

**Step 3: Cross-Reference with Links**

```json
{
  "name": "create_note",
  "arguments": {
    "title": "Async Programming Patterns",
    "body": "# Async Programming Patterns\n\n## Related Topics\n- [Python Asyncio](./asyncio-note-id)\n- [JavaScript Promises](./promises-note-id)\n- [Concurrency Models](./concurrency-note-id)\n\n## Common Patterns\n...",
    "notebook_id": "knowledge-base-id",
    "tags": ["async", "patterns", "programming"]
  }
}
```

---

## Tips and Best Practices

### 1. Consistent Naming Conventions

Use consistent naming for easy searching:
- Dates: `YYYY-MM-DD` format
- Meeting notes: `Week XX - Topic`
- Projects: `Project Name - Component`

### 2. Tag Strategy

Create a tagging system:
- **Status:** `todo`, `in-progress`, `completed`, `urgent`
- **Category:** `work`, `personal`, `learning`, `reference`
- **Topic:** `python`, `docker`, `architecture`, `meeting`

### 3. Regular Maintenance

```json
// Archive completed projects
{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "old-project-id",
    "tags": ["archived", "2024"]
  }
}
```

### 4. Backup Important Notes

```json
// Create backup by reading and creating copy
{
  "name": "read_note",
  "arguments": {
    "note_id": "important-note-id"
  }
}

// Then create backup with timestamp
{
  "name": "create_note",
  "arguments": {
    "title": "IMPORTANT - Backup 2025-04-14",
    "body": "[Pasted content from original]",
    "tags": ["backup", "important"]
  }
}
```

---

## Troubleshooting Common Scenarios

### Scenario 1: Accidentally Deleted Note

```json
// Check if you can find it in search
{
  "name": "search_notes",
  "arguments": {
    "query": "keywords from deleted note"
  }
}
```

**Note:** Deleted notes cannot be recovered through the API. Always keep backups of critical information.

### Scenario 2: Moving Notes Between Notebooks

```json
{
  "name": "update_note",
  "arguments": {
    "note_id": "note-to-move-id",
    "notebook_id": "target-notebook-id"
  }
}
```

### Scenario 3: Bulk Tag Operations

```json
// Add tags to multiple notes
{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "note-1-id",
    "tags": ["review", "2025"]
  }
}

{
  "name": "add_tags_to_note",
  "arguments": {
    "note_id": "note-2-id",
    "tags": ["review", "2025"]
  }
}
```

---

## Integration with OpenCode

### Using with OpenCode Agent

When using Joplin MCP with OpenCode, you can reference notes in your conversations:

```
User: "What did we decide about the database in last week's meeting?"

Agent: Let me search for that information...
[Uses search_notes with query "database meeting"]

Agent: According to the meeting notes from Week 14, you decided to use PostgreSQL because of its ACID compliance and JSON support. The decision was documented in ADR-001.
```

### Automated Workflows

Create automated workflows by combining tools:

1. **Daily Standup Report:**
   - Search notes tagged with `yesterday`
   - Create new note with summary
   - Tag with `standup` and today's date

2. **Weekly Review:**
   - List all notes created this week
   - Tag completed items
   - Archive old notes

3. **Project Documentation:**
   - Create notebook for new project
   - Generate template notes (README, ADR, etc.)
   - Set up tag structure

---

## Additional Resources

- [API Reference](./API_REFERENCE.md) - Complete tool documentation
- [Installation Guide](./INSTALL.md) - Setup and configuration
- [Changelog](./CHANGELOG.md) - Version history
- [Joplin API Documentation](https://joplinapp.org/api/references/rest_api/) - Official Joplin API reference

---

**Note:** All examples assume Joplin Desktop is running with Web Clipper enabled and properly configured with your token.
