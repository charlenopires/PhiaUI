defmodule PhiaUi.Components.NativeSelectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.NativeSelect

    def render_default(assigns) do
      ~H"""
      <.native_select
        name="color"
        options={[{"Red", "red"}, {"Blue", "blue"}, {"Green", "green"}]}
      />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.native_select
        name="color"
        options={[{"Red", "red"}, {"Blue", "blue"}]}
        label="Favorite Color"
      />
      """
    end

    def render_with_placeholder(assigns) do
      ~H"""
      <.native_select
        name="size"
        options={[{"Small", "sm"}, {"Medium", "md"}, {"Large", "lg"}]}
        placeholder="Choose a size..."
      />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.native_select
        name="plan"
        options={[{"Free", "free"}, {"Pro", "pro"}, {"Enterprise", "ent"}]}
        value="pro"
        label="Plan"
      />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.native_select
        name="role"
        options={[{"Admin", "admin"}, {"Member", "member"}]}
        label="Role"
        error="Role is required"
      />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.native_select
        name="country"
        options={[{"US", "us"}, {"CA", "ca"}]}
        disabled={true}
      />
      """
    end

    def render_required(assigns) do
      ~H"""
      <.native_select
        name="priority"
        options={[{"Low", "low"}, {"High", "high"}]}
        label="Priority"
        required={true}
      />
      """
    end

    def render_small(assigns) do
      ~H"""
      <.native_select
        name="size"
        options={[{"A", "a"}, {"B", "b"}]}
        size="sm"
      />
      """
    end

    def render_large(assigns) do
      ~H"""
      <.native_select
        name="size"
        options={[{"A", "a"}, {"B", "b"}]}
        size="lg"
      />
      """
    end

    def render_inset(assigns) do
      ~H"""
      <.native_select
        name="category"
        options={[{"Tech", "tech"}, {"Design", "design"}]}
        label="Category"
        variant="inset"
      />
      """
    end

    def render_overlapping(assigns) do
      ~H"""
      <.native_select
        name="type"
        options={[{"Bug", "bug"}, {"Feature", "feature"}]}
        label="Type"
        variant="overlapping"
      />
      """
    end

    def render_grouped(assigns) do
      ~H"""
      <.native_select
        name="food"
        grouped_options={[
          {"Fruits", [{"Apple", "apple"}, {"Banana", "banana"}]},
          {"Vegetables", [{"Carrot", "carrot"}, {"Spinach", "spinach"}]}
        ]}
        label="Food"
      />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.native_select
        name="tz"
        options={[{"UTC", "utc"}, {"EST", "est"}]}
        label="Timezone"
        description="Used for scheduling reminders."
      />
      """
    end

    def render_with_icon(assigns) do
      ~H"""
      <.native_select
        name="status"
        options={[{"Active", "active"}, {"Inactive", "inactive"}]}
        label="Status"
      >
        <:icon>
          <span class="icon-globe">G</span>
        </:icon>
      </.native_select>
      """
    end

    def render_with_class(assigns) do
      ~H"""
      <.native_select
        name="x"
        options={[{"A", "a"}]}
        class="w-64"
      />
      """
    end

    def render_with_id(assigns) do
      ~H"""
      <.native_select
        id="my-select"
        name="x"
        options={[{"A", "a"}]}
      />
      """
    end
  end

  describe "native_select/1 basics" do
    test "renders a select element with options" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "<select"
      assert html =~ "name=\"color\""
      assert html =~ "Red"
      assert html =~ "Blue"
      assert html =~ "Green"
    end

    test "renders label when provided" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Favorite Color"
      assert html =~ "<label"
    end

    test "renders placeholder as disabled option" do
      html = render_component(&H.render_with_placeholder/1, %{})
      assert html =~ "Choose a size..."
      assert html =~ "disabled"
    end

    test "pre-selects value" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ "selected"
      assert html =~ "pro"
    end

    test "uses custom id when provided" do
      html = render_component(&H.render_with_id/1, %{})
      assert html =~ "id=\"my-select\""
    end
  end

  describe "native_select/1 states" do
    test "renders error message and destructive styling" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "Role is required"
      assert html =~ "text-destructive"
    end

    test "renders disabled select" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "renders required asterisk" do
      html = render_component(&H.render_required/1, %{})
      assert html =~ "*"
    end
  end

  describe "native_select/1 sizes" do
    test "renders small size" do
      html = render_component(&H.render_small/1, %{})
      assert html =~ "h-8"
    end

    test "renders large size" do
      html = render_component(&H.render_large/1, %{})
      assert html =~ "h-12"
    end
  end

  describe "native_select/1 variants" do
    test "inset variant renders label inside border" do
      html = render_component(&H.render_inset/1, %{})
      assert html =~ "Category"
      assert html =~ "border rounded-md"
    end

    test "overlapping variant renders floating label" do
      html = render_component(&H.render_overlapping/1, %{})
      assert html =~ "Type"
      assert html =~ "-top-2.5"
    end
  end

  describe "native_select/1 grouped options" do
    test "renders optgroup elements" do
      html = render_component(&H.render_grouped/1, %{})
      assert html =~ "<optgroup"
      assert html =~ "Fruits"
      assert html =~ "Vegetables"
      assert html =~ "Apple"
      assert html =~ "Spinach"
    end
  end

  describe "native_select/1 extras" do
    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Used for scheduling reminders."
      assert html =~ "text-muted-foreground"
    end

    test "renders icon slot" do
      html = render_component(&H.render_with_icon/1, %{})
      assert html =~ "icon-globe"
    end

    test "merges custom class" do
      html = render_component(&H.render_with_class/1, %{})
      assert html =~ "w-64"
    end

    test "renders chevron-down icon" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "chevron-down"
    end
  end
end
