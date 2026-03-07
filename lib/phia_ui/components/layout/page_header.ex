defmodule PhiaUi.Components.Layout.PageHeader do
  @moduledoc """
  Page title bar with breadcrumb, title, description, and actions slots.

  Renders a structured page header with semantic hierarchy. Slot usage is
  flexible — use only the slots you need.

  ## Examples

      <%!-- Minimal title + actions --%>
      <.page_header>
        <:title>Dashboard</:title>
        <:actions>
          <.button>Export</.button>
          <.button variant={:default}>New project</.button>
        </:actions>
      </.page_header>

      <%!-- With breadcrumb and description --%>
      <.page_header border>
        <:breadcrumb>
          <.breadcrumb>
            <.breadcrumb_item href="/projects">Projects</.breadcrumb_item>
            <.breadcrumb_separator />
            <.breadcrumb_item>Settings</.breadcrumb_item>
          </.breadcrumb>
        </:breadcrumb>
        <:title>Project Settings</:title>
        <:description>Manage this project's configuration.</:description>
      </.page_header>
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  attr(:border, :boolean, default: false, doc: "Adds `border-b border-border` below the header.")

  attr(:class, :string, default: nil, doc: "Additional CSS classes merged via cn/1.")

  attr(:rest, :global, doc: "HTML attributes forwarded to the root element.")

  slot(:breadcrumb, doc: "Optional breadcrumb navigation above the title.")
  slot(:title, doc: "Main page title (rendered as h1).")
  slot(:description, doc: "Optional subtitle or description.")
  slot(:actions, doc: "Optional right-side action buttons.")

  @doc "Renders a page header with structured slots."
  def page_header(assigns) do
    ~H"""
    <div
      class={cn([
        "py-6",
        @border && "border-b border-border",
        @class
      ])}
      {@rest}
    >
      <%= if @breadcrumb != [] do %>
        <div class="mb-2">
          <%= render_slot(@breadcrumb) %>
        </div>
      <% end %>

      <div class="flex items-start justify-between gap-4">
        <div class="min-w-0 flex-1">
          <%= if @title != [] do %>
            <h1 class="text-2xl font-bold tracking-tight text-foreground truncate">
              <%= render_slot(@title) %>
            </h1>
          <% end %>
          <%= if @description != [] do %>
            <p class="mt-1 text-sm text-muted-foreground">
              <%= render_slot(@description) %>
            </p>
          <% end %>
        </div>

        <%= if @actions != [] do %>
          <div class="flex items-center gap-2 shrink-0">
            <%= render_slot(@actions) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
