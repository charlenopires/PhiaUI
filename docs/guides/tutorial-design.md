# Tutorial: PhiaUI Design — Visual Editor + Claude Code

Build Phoenix LiveView pages visually or by describing them to Claude Code. Export production-ready HEEx/LiveView code from your designs.

## What you'll learn

- How to start the visual editor with `mix phia.design`
- How to configure Claude Code with the MCP server
- How to build complete UIs using natural language
- How to export designs to production code
- How to analyze designs for hooks and dependencies

---

## Prerequisites

- Elixir 1.17+ and Phoenix 1.7+ with LiveView 1.0+
- TailwindCSS v4 configured in your project
- PhiaUI installed: `{:phia_ui, "~> 0.1.16"}` in `mix.exs`
- Bandit in your deps: `{:bandit, "~> 1.6"}` (for the visual editor)
- Claude Code installed (for the AI workflow)

---

## Part 1 — Visual Editor

### Start the editor

```bash
mix phia.design              # Start on port 4200
mix phia.design --port 4201  # Custom port
mix phia.design --no-open    # Don't auto-open browser
```

The editor runs alongside your existing Phoenix app on a separate port.

### Editor layout

The editor has three panels:

1. **Left — Component Browser**: Search and browse all 650 components by tier (primitive, interactive, widget, composite, surface, animation). Click to insert.

2. **Center — Canvas**: Live rendering of your design. Components render with real PhiaUI output (not placeholders). Click nodes to select. Toolbar provides:
   - Save/load designs as `.phia.json` files
   - Page templates (dashboard, settings, auth, landing, etc.)
   - Responsive preview (desktop / tablet / mobile)

3. **Right — Properties + Code**:
   - **Properties tab**: Edit selected node's attributes and slots
   - **Code tab**: Live HEEx preview of the current design

### Page templates

Click "Templates" in the toolbar to start from a pre-built page:

| Template | Components included |
|---|---|
| `dashboard` | Shell, sidebar, stat cards, chart, data grid |
| `settings` | Tabs, form sections, inputs, switches |
| `auth_login` | Card, input fields, button, links |
| `auth_register` | Card, form with validation fields |
| `landing` | Hero section, features grid, CTA |
| `pricing` | Pricing cards, toggle, feature comparison |
| `profile` | Avatar, form, card sections |
| `empty` | Clean slate |
| `kanban` | Kanban board with columns and cards |

### Save and load

Designs are saved as `.phia.json` files in `priv/phiaui_design/projects/`. The format stores all nodes, their hierarchy, attributes, slots, and theme.

---

## Part 2 — Claude Code + MCP

### Configure MCP

Add the PhiaUI Design MCP server to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "phiaui-design": {
      "command": "mix",
      "args": ["phia.design.mcp"],
      "env": {"MIX_ENV": "dev"}
    }
  }
}
```

Or add it globally to `~/.claude/.mcp.json`.

### How it works

The MCP server exposes 15 tools that Claude Code can call:

```
User describes UI → Claude browses catalog → inserts components →
configures attrs/slots → exports code → user gets a working LiveView
```

### Available tools

| Tool | Description |
|---|---|
| `get_phia_catalog` | Browse all 650 components grouped by tier |
| `get_phia_component_info` | Get attrs, slots, variants for a specific component |
| `get_phia_families` | List composable family groups |
| `insert_phia_component` | Insert a component with attrs and slots |
| `set_phia_attr` | Update attributes on a node |
| `set_phia_slot` | Set slot content |
| `delete_phia_node` | Remove a node and children |
| `move_phia_node` | Move/reorder nodes |
| `insert_phia_page` | Apply a page template |
| `set_phia_theme` | Switch theme preset |
| `get_phia_theme` | Get current theme |
| `export_heex` | Export as HEEx template |
| `export_liveview` | Export as LiveView module |
| `get_scene_tree` | Get scene structure as JSON |
| `clear_scene` | Clear all nodes |

### Example prompts

**Dashboard:**
```
Design a SaaS analytics dashboard with a sidebar, 3 KPI stat cards,
a monthly revenue bar chart, and a data grid of recent orders.
Export as MyAppWeb.DashboardLive.
```

**Login page:**
```
Create a centered login page with email and password inputs,
a "Sign in" button, and a "Forgot password?" link.
Use the card component for the form container.
```

**Landing page:**
```
Build a landing page with an animated gradient background,
a glass card hero section, feature cards in a 3-column grid,
a pricing section, and a CTA at the bottom.
```

**Settings page:**
```
Design a settings page with tabs for Profile, Account, and
Notifications. Each tab has form sections with appropriate inputs.
Use the settings page template as a starting point.
```

---

## Part 3 — Export & Analyze

### Export to code

```bash
# Export as LiveView module
mix phia.design.export my_design.phia.json \
  --format liveview \
  --output lib/my_app_web/live/dashboard_live.ex \
  --module MyAppWeb.DashboardLive \
  --web-module MyAppWeb

# Export as HEEx template only
mix phia.design.export my_design.phia.json \
  --format heex \
  --output lib/my_app_web/templates/page.html.heex

# Print to stdout (for piping)
mix phia.design.export my_design.phia.json
```

### Analyze a design

```bash
# Human-readable analysis
mix phia.design.analyze my_design.phia.json

# JSON output (for CI/scripts)
mix phia.design.analyze my_design.phia.json --json
```

Output includes:
- Total node count
- Unique components used
- Required JS hooks
- Install commands needed

### Round-trip workflow

1. **Design** — use the visual editor or Claude Code MCP
2. **Save** — design is persisted as `.phia.json`
3. **Export** — generate LiveView module with `mix phia.design.export`
4. **Compile** — `mix compile` succeeds, page renders correctly
5. **Iterate** — re-open design, modify, re-export

---

## Part 4 — Tips

### Combining visual editor + Claude Code

You can use both tools together:

1. Start with a page template in the visual editor
2. Ask Claude Code to add specific components via MCP
3. Fine-tune attrs in the properties panel
4. Export the final result

### Component families

Many components belong to families that work together:

- **Card family**: `card`, `card_header`, `card_title`, `card_description`, `card_content`, `card_footer`
- **Form family**: `form_section`, `form_fieldset`, `form_grid`, `form_row`, `form_actions`
- **Data grid family**: `data_grid`, `data_grid_head`, `data_grid_cell`, `data_grid_row`

When using Claude Code, mention the family name and it will compose components correctly.

### Theme switching

```
Set the theme to rose
```

Claude will call `set_phia_theme` with `rose`. Available themes: zinc, slate, stone, gray, red, rose, orange, blue, green, violet.
