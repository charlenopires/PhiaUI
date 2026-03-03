defmodule PhiaUi.ComponentHelpers do
  @moduledoc """
  Reusable test helpers for PhiaUI component tests.

  ## Usage

      use PhiaUi.ComponentHelpers

  Sets up `ExUnit.Case` with `async: true` and imports
  `Phoenix.LiveViewTest.render_component/2` plus assertion helpers.

  ## Helpers

  - `render_component/2` — renders a function component to an HTML string
  - `assert_has_class/2` — asserts the HTML contains a CSS class
  - `refute_has_class/2` — asserts the HTML does NOT contain a CSS class
  """

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import Phoenix.LiveViewTest, only: [render_component: 2]
      import PhiaUi.ComponentHelpers
    end
  end

  @doc """
  Asserts that the HTML string contains the given CSS class (or substring).

  ## Example

      assert_has_class(html, "bg-primary")
  """
  defmacro assert_has_class(html, class) do
    quote do
      assert unquote(html) =~ unquote(class)
    end
  end

  @doc """
  Asserts that the HTML string does NOT contain the given CSS class (or substring).

  ## Example

      refute_has_class(html, "pointer-events-none")
  """
  defmacro refute_has_class(html, class) do
    quote do
      refute unquote(html) =~ unquote(class)
    end
  end
end
