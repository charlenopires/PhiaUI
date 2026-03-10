defmodule PhiaUiDesign.Templates.PageTemplates do
  @moduledoc """
  Pre-built page scaffolds for the PhiaUI Design editor.

  Each template function builds a set of nodes in a Scene, creating
  a ready-to-customize page layout with real PhiaUI components.

  Templates return `{:ok, scene}` on success, or `{:error, reason}` on failure.
  Node IDs are generated automatically so templates can be applied multiple times
  to different scenes without collision.

  ## Usage

      scene = Scene.new()
      {:ok, scene} = PageTemplates.apply_template(scene, :dashboard)

  ## Available templates

      PageTemplates.list()
      # => [%{key: :dashboard, name: "Dashboard", ...}, ...]
  """

  alias PhiaUiDesign.Canvas.Scene

  @templates [
    %{
      key: :dashboard,
      name: "Dashboard",
      description: "Sidebar navigation, stat cards, and data table",
      category: :app
    },
    %{
      key: :settings,
      name: "Settings",
      description: "Settings page with form sections and sidebar nav",
      category: :app
    },
    %{
      key: :auth_login,
      name: "Login",
      description: "Centered login form with card",
      category: :auth
    },
    %{
      key: :auth_register,
      name: "Register",
      description: "Centered registration form with card",
      category: :auth
    },
    %{
      key: :landing,
      name: "Landing Page",
      description: "Hero section, features grid, CTA",
      category: :marketing
    },
    %{
      key: :crud_list,
      name: "CRUD List",
      description: "Data table with search, filters, and actions",
      category: :app
    },
    %{
      key: :profile,
      name: "Profile",
      description: "User profile with avatar, stats, and activity",
      category: :app
    },
    %{
      key: :pricing,
      name: "Pricing",
      description: "Pricing cards comparison layout",
      category: :marketing
    },
    %{
      key: :empty,
      name: "Blank Page",
      description: "Empty page with just a container",
      category: :utility
    }
  ]

  @template_keys Enum.map(@templates, & &1.key)

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  List all available page templates with metadata.

  Returns a list of maps with `:key`, `:name`, `:description`, and `:category`.
  """
  @spec list() :: [map()]
  def list, do: @templates

  @doc """
  List templates filtered by category.

  Categories: `:app`, `:auth`, `:marketing`, `:utility`.
  """
  @spec list_by_category(atom()) :: [map()]
  def list_by_category(category) do
    Enum.filter(@templates, &(&1.category == category))
  end

  @doc """
  Get a single template's metadata by key.
  """
  @spec get(atom()) :: map() | nil
  def get(key) do
    Enum.find(@templates, &(&1.key == key))
  end

  @doc """
  Return the list of valid template keys.
  """
  @spec keys() :: [atom()]
  def keys, do: @template_keys

  @doc """
  Apply a page template to a scene.

  Inserts the template's nodes into the given scene and returns
  `{:ok, scene}`. The scene is mutated in place (ETS), so the
  returned reference is the same as the input.

  Returns `{:error, :unknown_template}` if the key is not recognized.
  """
  @spec apply_template(Scene.scene_id(), atom()) :: {:ok, Scene.scene_id()} | {:error, atom()}
  def apply_template(scene, template_key)

  def apply_template(scene, :dashboard), do: build_dashboard(scene)
  def apply_template(scene, :settings), do: build_settings(scene)
  def apply_template(scene, :auth_login), do: build_auth_login(scene)
  def apply_template(scene, :auth_register), do: build_auth_register(scene)
  def apply_template(scene, :landing), do: build_landing(scene)
  def apply_template(scene, :crud_list), do: build_crud_list(scene)
  def apply_template(scene, :profile), do: build_profile(scene)
  def apply_template(scene, :pricing), do: build_pricing(scene)
  def apply_template(scene, :empty), do: build_empty(scene)
  def apply_template(_scene, _key), do: {:error, :unknown_template}

  # ---------------------------------------------------------------------------
  # Dashboard — sidebar + stat cards + data table
  # ---------------------------------------------------------------------------

  defp build_dashboard(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "flex h-screen bg-background",
      name: "Dashboard Root"
    )

    # -- Sidebar --
    {:ok, sidebar} = Scene.insert_element(scene, "aside",
      classes: "w-64 border-r border-border bg-card p-4 flex flex-col gap-2",
      parent_id: root.id,
      name: "Sidebar"
    )

    {:ok, _logo} = Scene.insert_component(scene, :heading,
      attrs: %{level: 3},
      slots: %{inner_block: "Dashboard"},
      parent_id: sidebar.id,
      name: "Sidebar Title"
    )

    {:ok, _sep} = Scene.insert_component(scene, :separator,
      parent_id: sidebar.id,
      name: "Sidebar Separator"
    )

    {:ok, nav} = Scene.insert_component(scene, :nav_list,
      parent_id: sidebar.id,
      name: "Sidebar Nav"
    )

    for label <- ["Overview", "Analytics", "Reports", "Settings"] do
      Scene.insert_component(scene, :button,
        attrs: %{variant: "ghost", class: "w-full justify-start"},
        slots: %{inner_block: label},
        parent_id: nav.id
      )
    end

    # -- Main content area --
    {:ok, main} = Scene.insert_element(scene, "main",
      classes: "flex-1 p-6 space-y-6 overflow-auto",
      parent_id: root.id,
      name: "Main Content"
    )

    {:ok, _page_hdr} = Scene.insert_component(scene, :page_header,
      attrs: %{title: "Dashboard", description: "Welcome back"},
      parent_id: main.id,
      name: "Page Header"
    )

    # -- Stat cards row --
    {:ok, stats_grid} = Scene.insert_element(scene, "div",
      classes: "grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4",
      parent_id: main.id,
      name: "Stats Grid"
    )

    stats = [
      {"Revenue", "$45,231"},
      {"Users", "2,350"},
      {"Orders", "1,234"},
      {"Growth", "+12.5%"}
    ]

    for {title, value} <- stats do
      Scene.insert_component(scene, :stat_card,
        attrs: %{title: title, value: value},
        parent_id: stats_grid.id
      )
    end

    # -- Data table --
    {:ok, _table} = Scene.insert_component(scene, :data_table,
      attrs: %{},
      slots: %{inner_block: "Recent orders"},
      parent_id: main.id,
      name: "Orders Table"
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Settings — form sections inside cards
  # ---------------------------------------------------------------------------

  defp build_settings(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "max-w-4xl mx-auto p-8 space-y-8",
      name: "Settings Root"
    )

    {:ok, _hdr} = Scene.insert_component(scene, :page_header,
      attrs: %{title: "Settings", description: "Manage your account preferences"},
      parent_id: root.id,
      name: "Settings Header"
    )

    sections = [
      {"Profile", "Update your personal information and avatar."},
      {"Notifications", "Choose which notifications you receive."},
      {"Security", "Password, two-factor authentication, and sessions."}
    ]

    for {title, description} <- sections do
      {:ok, section} = Scene.insert_component(scene, :form_section,
        attrs: %{title: title, description: description},
        parent_id: root.id,
        name: "Section: #{title}"
      )

      {:ok, grid} = Scene.insert_component(scene, :form_grid,
        parent_id: section.id,
        name: "#{title} Fields"
      )

      Scene.insert_component(scene, :input,
        attrs: %{placeholder: "Enter value..."},
        parent_id: grid.id
      )

      Scene.insert_component(scene, :input,
        attrs: %{placeholder: "Enter value..."},
        parent_id: grid.id
      )
    end

    {:ok, actions} = Scene.insert_component(scene, :form_actions,
      parent_id: root.id,
      name: "Form Actions"
    )

    Scene.insert_component(scene, :button,
      attrs: %{variant: "outline"},
      slots: %{inner_block: "Cancel"},
      parent_id: actions.id
    )

    Scene.insert_component(scene, :button,
      slots: %{inner_block: "Save Changes"},
      parent_id: actions.id
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Auth Login — centered card with email/password form
  # ---------------------------------------------------------------------------

  defp build_auth_login(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "min-h-screen flex items-center justify-center bg-muted/50",
      name: "Login Root"
    )

    {:ok, card} = Scene.insert_component(scene, :card,
      attrs: %{class: "w-full max-w-md"},
      parent_id: root.id,
      name: "Login Card"
    )

    {:ok, header} = Scene.insert_element(scene, "div",
      classes: "space-y-1.5 p-6 pb-0",
      parent_id: card.id,
      name: "Card Header"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 2},
      slots: %{inner_block: "Sign In"},
      parent_id: header.id
    )

    Scene.insert_component(scene, :paragraph,
      slots: %{inner_block: "Enter your credentials to continue"},
      parent_id: header.id
    )

    {:ok, body} = Scene.insert_element(scene, "div",
      classes: "p-6 space-y-4",
      parent_id: card.id,
      name: "Card Body"
    )

    Scene.insert_component(scene, :label,
      attrs: %{},
      slots: %{inner_block: "Email"},
      parent_id: body.id
    )

    Scene.insert_component(scene, :input,
      attrs: %{type: "email", placeholder: "name@example.com"},
      parent_id: body.id
    )

    Scene.insert_component(scene, :label,
      attrs: %{},
      slots: %{inner_block: "Password"},
      parent_id: body.id
    )

    Scene.insert_component(scene, :input,
      attrs: %{type: "password", placeholder: "Password"},
      parent_id: body.id
    )

    Scene.insert_component(scene, :button,
      attrs: %{class: "w-full"},
      slots: %{inner_block: "Sign In"},
      parent_id: body.id
    )

    {:ok, footer} = Scene.insert_element(scene, "div",
      classes: "p-6 pt-0 text-center text-sm text-muted-foreground",
      parent_id: card.id,
      name: "Card Footer"
    )

    Scene.insert_component(scene, :text,
      slots: %{inner_block: "Don't have an account? Sign up"},
      parent_id: footer.id
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Auth Register — centered card with name/email/password form
  # ---------------------------------------------------------------------------

  defp build_auth_register(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "min-h-screen flex items-center justify-center bg-muted/50",
      name: "Register Root"
    )

    {:ok, card} = Scene.insert_component(scene, :card,
      attrs: %{class: "w-full max-w-md"},
      parent_id: root.id,
      name: "Register Card"
    )

    {:ok, header} = Scene.insert_element(scene, "div",
      classes: "space-y-1.5 p-6 pb-0",
      parent_id: card.id,
      name: "Card Header"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 2},
      slots: %{inner_block: "Create Account"},
      parent_id: header.id
    )

    Scene.insert_component(scene, :paragraph,
      slots: %{inner_block: "Fill in the details to get started"},
      parent_id: header.id
    )

    {:ok, body} = Scene.insert_element(scene, "div",
      classes: "p-6 space-y-4",
      parent_id: card.id,
      name: "Card Body"
    )

    fields = [
      {"Full Name", "text", "Jane Doe"},
      {"Email", "email", "name@example.com"},
      {"Password", "password", "Password"},
      {"Confirm Password", "password", "Confirm password"}
    ]

    for {lbl, type, placeholder} <- fields do
      Scene.insert_component(scene, :label,
        slots: %{inner_block: lbl},
        parent_id: body.id
      )

      Scene.insert_component(scene, :input,
        attrs: %{type: type, placeholder: placeholder},
        parent_id: body.id
      )
    end

    Scene.insert_component(scene, :button,
      attrs: %{class: "w-full"},
      slots: %{inner_block: "Create Account"},
      parent_id: body.id
    )

    {:ok, footer} = Scene.insert_element(scene, "div",
      classes: "p-6 pt-0 text-center text-sm text-muted-foreground",
      parent_id: card.id,
      name: "Card Footer"
    )

    Scene.insert_component(scene, :text,
      slots: %{inner_block: "Already have an account? Sign in"},
      parent_id: footer.id
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Landing Page — hero + features grid + CTA
  # ---------------------------------------------------------------------------

  defp build_landing(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "space-y-16",
      name: "Landing Root"
    )

    # -- Hero section --
    {:ok, hero} = Scene.insert_element(scene, "section",
      classes: "text-center py-20 px-6 space-y-6",
      parent_id: root.id,
      name: "Hero"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 1},
      slots: %{inner_block: "Build Amazing Products"},
      parent_id: hero.id
    )

    Scene.insert_component(scene, :lead,
      slots: %{inner_block: "The modern platform for building great user experiences."},
      parent_id: hero.id
    )

    {:ok, cta_row} = Scene.insert_element(scene, "div",
      classes: "flex gap-4 justify-center",
      parent_id: hero.id,
      name: "CTA Buttons"
    )

    Scene.insert_component(scene, :button,
      slots: %{inner_block: "Get Started"},
      parent_id: cta_row.id
    )

    Scene.insert_component(scene, :button,
      attrs: %{variant: "outline"},
      slots: %{inner_block: "Learn More"},
      parent_id: cta_row.id
    )

    # -- Features grid --
    {:ok, features_section} = Scene.insert_element(scene, "section",
      classes: "max-w-6xl mx-auto px-6",
      parent_id: root.id,
      name: "Features"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 2, class: "text-center mb-8"},
      slots: %{inner_block: "Features"},
      parent_id: features_section.id
    )

    {:ok, features_grid} = Scene.insert_element(scene, "div",
      classes: "grid grid-cols-1 gap-8 md:grid-cols-3",
      parent_id: features_section.id,
      name: "Features Grid"
    )

    features = [
      {"Lightning Fast", "Optimized for speed with zero client-side JavaScript overhead."},
      {"Fully Accessible", "WCAG 2.1 compliant components out of the box."},
      {"Customizable", "Tailwind-based theming that adapts to your brand."}
    ]

    for {title, description} <- features do
      Scene.insert_component(scene, :feature_card,
        attrs: %{title: title, description: description},
        parent_id: features_grid.id
      )
    end

    # -- CTA section --
    {:ok, cta} = Scene.insert_element(scene, "section",
      classes: "text-center py-16 px-6",
      parent_id: root.id,
      name: "CTA Section"
    )

    Scene.insert_component(scene, :cta_card,
      attrs: %{
        title: "Ready to get started?",
        description: "Join thousands of developers building with PhiaUI.",
        button_label: "Start Free Trial"
      },
      parent_id: cta.id
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # CRUD List — search bar + data table with action buttons
  # ---------------------------------------------------------------------------

  defp build_crud_list(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "p-6 space-y-4",
      name: "CRUD List Root"
    )

    # -- Header row --
    {:ok, header_row} = Scene.insert_element(scene, "div",
      classes: "flex items-center justify-between",
      parent_id: root.id,
      name: "Header Row"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 2},
      slots: %{inner_block: "Items"},
      parent_id: header_row.id
    )

    Scene.insert_component(scene, :button,
      slots: %{inner_block: "Add New"},
      parent_id: header_row.id
    )

    # -- Filters row --
    {:ok, filters_row} = Scene.insert_element(scene, "div",
      classes: "flex items-center gap-3",
      parent_id: root.id,
      name: "Filters"
    )

    Scene.insert_component(scene, :search_input,
      attrs: %{placeholder: "Search items..."},
      parent_id: filters_row.id
    )

    Scene.insert_component(scene, :select,
      attrs: %{placeholder: "Status"},
      parent_id: filters_row.id
    )

    # -- Data table --
    Scene.insert_component(scene, :data_table,
      attrs: %{},
      slots: %{inner_block: "Table content"},
      parent_id: root.id,
      name: "Items Table"
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Profile — avatar header + stat cards + activity section
  # ---------------------------------------------------------------------------

  defp build_profile(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "max-w-2xl mx-auto p-8 space-y-6",
      name: "Profile Root"
    )

    # -- Profile header --
    {:ok, profile_header} = Scene.insert_element(scene, "div",
      classes: "flex items-center gap-6",
      parent_id: root.id,
      name: "Profile Header"
    )

    Scene.insert_component(scene, :avatar,
      attrs: %{size: "lg", fallback: "JD"},
      parent_id: profile_header.id,
      name: "User Avatar"
    )

    {:ok, info} = Scene.insert_element(scene, "div",
      classes: "space-y-1",
      parent_id: profile_header.id,
      name: "User Info"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 2},
      slots: %{inner_block: "Jane Doe"},
      parent_id: info.id
    )

    Scene.insert_component(scene, :text,
      slots: %{inner_block: "Software Engineer"},
      parent_id: info.id
    )

    Scene.insert_component(scene, :separator,
      parent_id: root.id
    )

    # -- Stats row --
    {:ok, stats_row} = Scene.insert_element(scene, "div",
      classes: "grid grid-cols-3 gap-4",
      parent_id: root.id,
      name: "Stats"
    )

    for {title, value} <- [{"Projects", "12"}, {"Followers", "1.2k"}, {"Following", "342"}] do
      Scene.insert_component(scene, :stat_card,
        attrs: %{title: title, value: value},
        parent_id: stats_row.id
      )
    end

    # -- Activity section --
    Scene.insert_component(scene, :separator,
      parent_id: root.id
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 3},
      slots: %{inner_block: "Recent Activity"},
      parent_id: root.id
    )

    Scene.insert_component(scene, :card,
      slots: %{inner_block: "Activity feed content"},
      parent_id: root.id,
      name: "Activity Card"
    )

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Pricing — heading + pricing cards comparison
  # ---------------------------------------------------------------------------

  defp build_pricing(scene) do
    {:ok, root} = Scene.insert_element(scene, "div",
      classes: "py-16 px-6 text-center space-y-12",
      name: "Pricing Root"
    )

    Scene.insert_component(scene, :heading,
      attrs: %{level: 1},
      slots: %{inner_block: "Pricing"},
      parent_id: root.id
    )

    Scene.insert_component(scene, :lead,
      slots: %{inner_block: "Choose the plan that works for you."},
      parent_id: root.id
    )

    {:ok, cards_row} = Scene.insert_element(scene, "div",
      classes: "grid grid-cols-1 gap-8 max-w-5xl mx-auto md:grid-cols-3",
      parent_id: root.id,
      name: "Pricing Cards"
    )

    plans = [
      %{title: "Starter", price: "$9", period: "/month",
        features: ["5 projects", "10 GB storage", "Email support"]},
      %{title: "Pro", price: "$29", period: "/month",
        features: ["Unlimited projects", "100 GB storage", "Priority support"]},
      %{title: "Enterprise", price: "$99", period: "/month",
        features: ["Unlimited everything", "Custom integrations", "Dedicated support"]}
    ]

    for plan <- plans do
      Scene.insert_component(scene, :pricing_card,
        attrs: %{
          title: plan.title,
          price: plan.price,
          period: plan.period,
          features: plan.features
        },
        parent_id: cards_row.id,
        name: "#{plan.title} Plan"
      )
    end

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # Empty / Blank Page — just a container
  # ---------------------------------------------------------------------------

  defp build_empty(scene) do
    {:ok, _container} = Scene.insert_element(scene, "div",
      classes: "p-6",
      name: "Container"
    )

    {:ok, scene}
  end
end
