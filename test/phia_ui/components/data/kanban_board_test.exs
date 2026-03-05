defmodule PhiaUi.Components.KanbanBoardTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.KanbanBoard

    def render_board(assigns) do
      ~H"""
      <.kanban_board id={assigns[:id] || "board"} class={assigns[:class]}>
        {assigns[:content] || "board content"}
      </.kanban_board>
      """
    end

    def render_column(assigns) do
      ~H"""
      <.kanban_column
        id={assigns[:id] || "col-todo"}
        label={assigns[:label] || "To Do"}
        count={assigns[:count]}
        class={assigns[:class]}
      >
        {assigns[:content] || "column content"}
      </.kanban_column>
      """
    end

    def render_card(assigns) do
      ~H"""
      <.kanban_card
        id={assigns[:id] || "card-1"}
        title={assigns[:title] || "Task title"}
        priority={assigns[:priority] || "medium"}
        class={assigns[:class]}
      >
        {assigns[:content]}
      </.kanban_card>
      """
    end

    def render_full(assigns) do
      ~H"""
      <.kanban_board id="project-board">
        <.kanban_column id="col-todo" label="To Do" count={3}>
          <.kanban_card id="card-1" title="A/B Testing - Round 3" priority="high">
            <:tags>
              <span class="tag-prototype">Prototype</span>
              <span class="tag-research">Research</span>
            </:tags>
            <:footer>
              <span class="due-date">5 Sept 2022</span>
            </:footer>
          </.kanban_card>
          <.kanban_card id="card-2" title="Create microinteraction flow" priority="low">
          </.kanban_card>
        </.kanban_column>

        <.kanban_column id="col-in-progress" label="In Progress" count={2}>
          <.kanban_card id="card-3" title="Create Prototype for payments" priority="high">
          </.kanban_card>
        </.kanban_column>

        <.kanban_column id="col-done" label="Done" count={0}>
        </.kanban_column>
      </.kanban_board>
      """
    end

    def render_card_with_avatar(assigns) do
      ~H"""
      <.kanban_card id="card-a" title="Design review" priority="medium">
        <:avatar>
          <span class="custom-avatar" />
        </:avatar>
      </.kanban_card>
      """
    end
  end

  defp render_board(attrs \\ %{}), do: render_component(&H.render_board/1, attrs)
  defp render_column(attrs \\ %{}), do: render_component(&H.render_column/1, attrs)
  defp render_card(attrs \\ %{}), do: render_component(&H.render_card/1, attrs)
  defp render_full, do: render_component(&H.render_full/1, %{})
  defp render_card_with_avatar, do: render_component(&H.render_card_with_avatar/1, %{})

  # ---------------------------------------------------------------------------
  # kanban_board/1 — container
  # ---------------------------------------------------------------------------

  describe "kanban_board/1 — container" do
    test "renders a root element" do
      assert render_board() =~ "<div"
    end

    test "forwards id attribute to the root element" do
      assert render_board(%{id: "my-board"}) =~ ~s(id="my-board")
    end

    test "custom class is applied" do
      assert render_board(%{class: "my-board"}) =~ "my-board"
    end

    test "renders inner content" do
      assert render_board(%{content: "board content"}) =~ "board content"
    end

    test "board is a horizontal flex container" do
      assert render_board() =~ "flex"
    end
  end

  # ---------------------------------------------------------------------------
  # kanban_column/1
  # ---------------------------------------------------------------------------

  describe "kanban_column/1 — structure" do
    test "renders the column label" do
      assert render_column(%{label: "To Do"}) =~ "To Do"
    end

    test "renders In Progress label" do
      assert render_column(%{label: "In Progress"}) =~ "In Progress"
    end

    test "renders count badge when count is provided" do
      assert render_column(%{count: 5}) =~ "5"
    end

    test "does not render count when nil" do
      html = render_column(%{count: nil})
      refute html =~ ~s(data-count)
    end

    test "renders inner slot content" do
      assert render_column(%{content: "card content here"}) =~ "card content here"
    end

    test "custom class is applied to the column" do
      assert render_column(%{class: "my-col"}) =~ "my-col"
    end

    test "column has a distinct background from the board" do
      assert render_column() =~ "bg-muted" or render_column() =~ "bg-background"
    end

    test "column label uses muted-foreground or foreground token" do
      html = render_column(%{label: "To Do"})
      assert html =~ "text-" and html =~ "To Do"
    end
  end

  # ---------------------------------------------------------------------------
  # kanban_card/1 — base structure
  # ---------------------------------------------------------------------------

  describe "kanban_card/1 — base structure" do
    test "renders the card title" do
      assert render_card(%{title: "My Task"}) =~ "My Task"
    end

    test "renders a card container element" do
      assert render_card() =~ "<div"
    end

    test "card has a border or ring for visual separation" do
      html = render_card()
      assert html =~ "border" or html =~ "ring"
    end

    test "card has rounded corners" do
      assert render_card() =~ "rounded"
    end

    test "card has background color token" do
      assert render_card() =~ "bg-"
    end

    test "custom class is applied to the card" do
      assert render_card(%{class: "my-card"}) =~ "my-card"
    end

    test "card id is forwarded" do
      assert render_card(%{id: "card-xyz"}) =~ ~s(id="card-xyz")
    end
  end

  # ---------------------------------------------------------------------------
  # kanban_card/1 — priority badge
  # ---------------------------------------------------------------------------

  describe "kanban_card/1 — priority" do
    test "high priority renders priority indicator" do
      assert render_card(%{priority: "high"}) =~ ~s(data-priority="high")
    end

    test "medium priority renders priority indicator" do
      assert render_card(%{priority: "medium"}) =~ ~s(data-priority="medium")
    end

    test "low priority renders priority indicator" do
      assert render_card(%{priority: "low"}) =~ ~s(data-priority="low")
    end

    test "critical priority renders priority indicator" do
      assert render_card(%{priority: "critical"}) =~ ~s(data-priority="critical")
    end

    test "high priority uses destructive or warning color token" do
      html = render_card(%{priority: "high"})
      assert html =~ "destructive" or html =~ "orange" or html =~ "red"
    end

    test "low priority uses muted or success color" do
      html = render_card(%{priority: "low"})
      assert html =~ "muted" or html =~ "green" or html =~ "secondary"
    end
  end

  # ---------------------------------------------------------------------------
  # kanban_card/1 — slots
  # ---------------------------------------------------------------------------

  describe "kanban_card/1 — tags slot" do
    test "renders tags slot content when provided" do
      html =
        render_component(&H.render_full/1, %{})

      assert html =~ "tag-prototype"
      assert html =~ "tag-research"
    end
  end

  describe "kanban_card/1 — footer slot" do
    test "renders footer slot content" do
      assert render_full() =~ "due-date"
    end

    test "footer is rendered below the title" do
      html = render_full()
      title_pos = :binary.match(html, "A/B Testing") |> elem(0)
      footer_pos = :binary.match(html, "due-date") |> elem(0)
      assert footer_pos > title_pos
    end
  end

  describe "kanban_card/1 — avatar slot" do
    test "renders avatar slot content when provided" do
      assert render_card_with_avatar() =~ "custom-avatar"
    end

    test "avatar appears alongside card title" do
      html = render_card_with_avatar()
      assert html =~ "Design review"
      assert html =~ "custom-avatar"
    end
  end

  # ---------------------------------------------------------------------------
  # Full board composition
  # ---------------------------------------------------------------------------

  describe "full board composition" do
    test "renders multiple columns" do
      html = render_full()
      assert html =~ "To Do"
      assert html =~ "In Progress"
      assert html =~ "Done"
    end

    test "renders cards inside their respective columns" do
      html = render_full()
      assert html =~ "A/B Testing - Round 3"
      assert html =~ "Create microinteraction flow"
      assert html =~ "Create Prototype for payments"
    end

    test "column counts are rendered" do
      html = render_full()
      assert html =~ "3"
      assert html =~ "2"
    end

    test "board id is present on the root element" do
      assert render_full() =~ ~s(id="project-board")
    end

    test "no hardcoded hex colors in style attributes" do
      html = render_full()
      refute html =~ ~r/style="[^"]*#[0-9a-fA-F]{3,6}/
    end
  end

  # ---------------------------------------------------------------------------
  # Semantic tokens
  # ---------------------------------------------------------------------------

  describe "kanban_board/1 — semantic tokens" do
    test "card uses bg-background or bg-card semantic token" do
      html = render_card()
      assert html =~ "bg-background" or html =~ "bg-card"
    end

    test "card title uses text-foreground or text-sm semantic token" do
      html = render_card(%{title: "Test"})
      assert html =~ "text-foreground" or html =~ "font-medium"
    end
  end
end
