# PhiaUI

A comprehensive, accessible, and composable UI component library for Phoenix LiveView applications, inspired by shadcn/ui.

PhiaUI brings beautifully designed, enterprise-ready dashboard components, interactive widgets, and accessible primitives to your Elixir ecosystem without the bloat. We stand out by offering advanced analytics widgets and an ejectable component architecture.

## 🚀 Features & Architecture

PhiaUI is organized into a robust domain model designed for maximum flexibility and developer experience:

### 🧩 Primitive Components
Stateless HEEx components that transform assigns into beautifully rendered HTML using TailwindCSS. Fully customizable and composable.
*Includes: `Button`, `Card`, `Badge`, `Input`, `Label`, `Separator`, `Skeleton`, `Avatar`, `Progress`, `Table`*

### ⚡ Interactive Components
Rich interactive components powered by lightweight Phoenix JS Hooks for robust WAI-ARIA accessibility, keyboard navigation, and focus management.
*Includes: `Dialog`, `DropdownMenu`, `Sheet`, `Tabs`, `Accordion`, `Popover`, `Tooltip`, `Select`, `Checkbox`, `Switch`, `Slider`*

### 📝 Form Integration
Seamless integration with `Phoenix.HTML.Form` and Ecto Changesets. Supports real-time validation via `phx-debounce` and customizable error translations.
*Includes: `FormField`, `PhiaInput`, `Textarea`, `InputOTP`*

### 📊 Dashboard Shell & Widgets (Enterprise Ready)
Our competitive advantage: Built-in, high-quality layouts and widgets tailored for financial terminals, BI panels, and KPI monitors.
* **Dashboard Shell**: CSS Grid desktop layouts with Flexbox mobile drawers (No Alpine.js required). Includes `Shell`, `Sidebar`, `Topbar`.
* **Dashboard Widgets**: Ready-to-use analytical components built on top of our primitives. Includes `StatCard`, `MetricGrid`, `ChartShell`.

### 🧭 Navigation & Feedback
Components to structure application navigation and communicate state clearly.
*Includes: `Breadcrumb`, `Pagination`, `ScrollArea`, `Alert`, `AlertDialog`, `Toast`*

## 🛠 Tech Stack

- **Elixir** & **Phoenix Framework**
- **Phoenix LiveView**
- **TailwindCSS**
- **JavaScript** (Vanilla JS Hooks, zero heavy dependencies)

## 📦 Installation

*(Note: PhiaUI is currently under active development. Once published to Hex, the following instructions will apply.)*

Add `phia_ui` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phia_ui, "~> 0.1.0"}
  ]
end
```

### Ejectable Architecture

PhiaUI embraces the "ejectable" component philosophy. Manage your library using Mix tasks to bring component code directly into your project:

```bash
# Install core dependencies and setup
mix phia.install

# List available components
mix phia.list

# Add specific components into your codebase
mix phia.add button card
```

## 📚 Documentation

Full documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and will be published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/phia_ui>.

## 🤝 Contributing

We value **Clarity**, **Simplicity**, and **Testability**. All features must be tested, and all code must pass linting without warnings.

