---
name: unity-mcp
description: >
  Connect AI agents to the Unity Editor through MCP for scene, script, package,
  asset, test, and API-aware automation. Use when configuring Unity MCP over
  HTTP or stdio, routing across multiple Unity instances, batching editor
  operations, validating scripts with Roslyn, or using `unity_docs` and
  `unity_reflect` before code generation. Triggers on: unity-mcp, Unity MCP,
  MCP for Unity, unity_docs, unity_reflect, set_active_instance, batch_execute,
  manage_packages, manage_camera, manage_graphics, Roslyn validation.
license: MIT
compatibility: >
  Unity 2021.3 LTS+ with the MCP for Unity package. HTTP on localhost:8080 is the
  default transport. Stdio transport is also supported through `uvx --from
  mcpforunityserver mcp-for-unity --transport stdio`. Python/uv is not required
  for the default in-editor HTTP flow, but stdio setup does require uvx.
allowed-tools: Read Write Bash Grep Glob Task WebFetch
metadata:
  version: "1.2.0"
  author: supercent-io
  keyword: unity-mcp
  tags: unity, unity3d, mcp, game-development, editor-automation, ai-agent
  platforms: Claude Code | Codex CLI | Gemini CLI | OpenCode | VS Code
  source: CoplayDev/unity-mcp
---

# unity-mcp

Use this skill when Unity Editor automation is the execution surface. The point is not just "connect to MCP", but to use the editor as a safe, inspectable target for scripted scene changes, package operations, script validation, tests, and API checks.

## When to use this skill

- Configuring an AI client to talk to a running Unity Editor over MCP
- Automating scene, prefab, script, or package changes from an agent workflow
- Routing commands to the correct Unity instance in a multi-project session
- Validating generated C# with Roslyn-aware script tooling
- Using `unity_docs` and `unity_reflect` before writing or editing scripts
- Running editor-side verification with `run_tests`, `get_test_job`, and `read_console`

## Instructions

### Step 1: Install the Unity package

In Unity Package Manager:

```text
https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
```

Beta builds can target the `#beta` branch instead. OpenUPM is also supported by the upstream project.

### Step 2: Pick transport mode

HTTP is the default and easiest mode:

```json
{
  "mcpServers": {
    "unityMCP": {
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

Stdio is useful for clients or environments that prefer local process transport:

```json
{
  "mcpServers": {
    "unityMCP": {
      "command": "uvx",
      "args": ["--from", "mcpforunityserver", "mcp-for-unity", "--transport", "stdio"]
    }
  }
}
```

Use HTTP unless you specifically need stdio. The in-editor quick start remains:

1. `Window > MCP for Unity`
2. Start Server
3. Configure your client
4. Look for `Connected`

### Step 3: Know the high-value tools

Current upstream tools include:

- scene and object control: `manage_scene`, `manage_gameobject`, `manage_components`, `manage_prefabs`
- script lifecycle: `create_script`, `manage_script`, `script_apply_edits`, `validate_script`, `manage_script_capabilities`
- UI, rendering, and content: `manage_ui`, `manage_material`, `manage_texture`, `manage_shader`, `manage_vfx`, `manage_animation`, `manage_camera`, `manage_graphics`, `manage_packages`
- search and verification: `find_in_file`, `find_gameobjects`, `run_tests`, `get_test_job`, `read_console`, `unity_docs`, `unity_reflect`
- control and batching: `batch_execute`, `manage_tools`, `set_active_instance`, `refresh_unity`

### Step 4: Route to the right Unity instance

When multiple editors are open:

1. inspect the `unity_instances` resource
2. call `set_active_instance` with the reported `Name@hash`
3. run all subsequent tools against that active instance

Do this before writing code or mutating scenes. Otherwise the agent can edit the wrong project.

### Step 5: Prefer verification-aware editing

Before generating or modifying a script:

1. use `unity_docs` for the relevant API page
2. use `unity_reflect` when the live project type system matters
3. create or edit the script
4. run `validate_script`
5. inspect `read_console`
6. run `run_tests` where applicable

This reduces hallucinated API usage and makes `unity-mcp` a real verification surface, not just a write surface.

### Step 6: Use batching for repetitive editor work

`batch_execute` is the throughput tool. Use it for repetitive asset edits, prefab updates, or texture import changes instead of looping one tool call at a time.

### Step 7: Enable Roslyn validation when script correctness matters

The upstream project supports one-click Roslyn installation from the Unity window and menu. Use that path first. Manual DLL installation is the fallback.

## Examples

### Example 1: HTTP quick start

```text
omu "Create a simple player controller scene"
  -> unity-mcp over http://localhost:8080/mcp
  -> manage_scene / create_script / validate_script / run_tests
```

### Example 2: Multi-instance routing

```text
1. read unity_instances
2. set_active_instance MyProject@abc123
3. manage_scene create prototype arena
4. read_console
```

### Example 3: API-safe code generation

```text
1. unity_docs on CharacterController
2. unity_reflect on PlayerController assembly symbols
3. create_script PlayerController.cs
4. validate_script
5. read_console
```

## Best practices

1. Use HTTP first; use stdio only when the client or environment needs it.
2. Always confirm the active Unity instance before mutating project state.
3. Use `unity_docs` and `unity_reflect` before writing complex runtime code.
4. Pair `validate_script` with `read_console`; one without the other is incomplete.
5. Prefer `batch_execute` for repeated operations.
6. Enable Roslyn when strict API validation matters.
7. Keep package management (`manage_packages`) and script generation in the same verification loop.

## References

- https://github.com/CoplayDev/unity-mcp
- See `scripts/setup.sh` for client config bootstrap
