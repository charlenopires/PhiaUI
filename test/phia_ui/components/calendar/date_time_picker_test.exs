defmodule PhiaUi.Components.DateTimePickerTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  defmodule H do
    @moduledoc false
    use Phoenix.Component
    import PhiaUi.Components.DateTimePicker

    def render_default(assigns) do
      ~H"""
      <.date_time_picker id="dtp1" name="dtp" />
      """
    end

    def render_with_id(assigns) do
      ~H"""
      <.date_time_picker id="dtp-custom" name="dtp" />
      """
    end

    def render_with_name(assigns) do
      ~H"""
      <.date_time_picker id="dtp2" name="scheduled_at" />
      """
    end

    def render_with_value(assigns) do
      ~H"""
      <.date_time_picker id="dtp3" name="dtp" value="2026-03-04T10:30" />
      """
    end

    def render_with_label(assigns) do
      ~H"""
      <.date_time_picker id="dtp4" name="dtp" label="Scheduled Date & Time" />
      """
    end

    def render_with_description(assigns) do
      ~H"""
      <.date_time_picker
        id="dtp5"
        name="dtp"
        label="Appointment"
        description="Choose your appointment date and time"
      />
      """
    end

    def render_disabled(assigns) do
      ~H"""
      <.date_time_picker id="dtp6" name="dtp" disabled={true} />
      """
    end

    def render_with_seconds(assigns) do
      ~H"""
      <.date_time_picker id="dtp7" name="dtp" with_seconds={true} />
      """
    end

    def render_without_seconds(assigns) do
      ~H"""
      <.date_time_picker id="dtp8" name="dtp" with_seconds={false} />
      """
    end

    def render_sm(assigns) do
      ~H"""
      <.date_time_picker id="dtp9" name="dtp" size={:sm} />
      """
    end

    def render_lg(assigns) do
      ~H"""
      <.date_time_picker id="dtp10" name="dtp" size={:lg} />
      """
    end

    def render_custom_class(assigns) do
      ~H"""
      <.date_time_picker id="dtp11" name="dtp" class="my-dtp-class" />
      """
    end

    def render_with_error(assigns) do
      ~H"""
      <.date_time_picker id="dtp12" name="dtp" errors={["can't be blank"]} />
      """
    end

    def render_with_multiple_errors(assigns) do
      ~H"""
      <.date_time_picker id="dtp13" name="dtp" errors={["is invalid", "can't be blank"]} />
      """
    end

    def render_no_label(assigns) do
      ~H"""
      <.date_time_picker id="dtp14" name="dtp" />
      """
    end

    def render_empty_errors(assigns) do
      ~H"""
      <.date_time_picker id="dtp15" name="dtp" errors={[]} />
      """
    end
  end

  describe "date_time_picker/1" do
    test "renders input type=datetime-local" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ ~s(type="datetime-local")
    end

    test "renders with id attribute" do
      html = render_component(&H.render_with_id/1, %{})
      assert html =~ ~s(id="dtp-custom")
    end

    test "renders with name attribute" do
      html = render_component(&H.render_with_name/1, %{})
      assert html =~ ~s(name="scheduled_at")
    end

    test "renders with value attribute" do
      html = render_component(&H.render_with_value/1, %{})
      assert html =~ ~s(value="2026-03-04T10:30")
    end

    test "renders label element" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ "Scheduled Date &amp; Time"
    end

    test "label has for= attribute matching id" do
      html = render_component(&H.render_with_label/1, %{})
      assert html =~ ~s(for="dtp4")
    end

    test "renders description text" do
      html = render_component(&H.render_with_description/1, %{})
      assert html =~ "Choose your appointment date and time"
    end

    test "no label rendered when label not provided" do
      html = render_component(&H.render_no_label/1, %{})
      refute html =~ "<label"
    end

    test "renders disabled input" do
      html = render_component(&H.render_disabled/1, %{})
      assert html =~ "disabled"
    end

    test "with_seconds=true adds step=1" do
      html = render_component(&H.render_with_seconds/1, %{})
      assert html =~ ~s(step="1")
    end

    test "with_seconds=false does not add step attribute" do
      html = render_component(&H.render_without_seconds/1, %{})
      refute html =~ ~s(step="1")
    end

    test "size :sm renders h-8" do
      html = render_component(&H.render_sm/1, %{})
      assert html =~ "h-8"
    end

    test "size :default renders h-10" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "h-10"
    end

    test "size :lg renders h-12" do
      html = render_component(&H.render_lg/1, %{})
      assert html =~ "h-12"
    end

    test "custom class is applied" do
      html = render_component(&H.render_custom_class/1, %{})
      assert html =~ "my-dtp-class"
    end

    test "renders rounded-md" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "rounded-md"
    end

    test "renders border" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "border"
    end

    test "renders focus-visible ring styling" do
      html = render_component(&H.render_default/1, %{})
      assert html =~ "focus-visible:ring"
    end

    test "renders error message text" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "can&#39;t be blank"
    end

    test "error state adds border-destructive class" do
      html = render_component(&H.render_with_error/1, %{})
      assert html =~ "border-destructive"
    end

    test "empty errors renders without error class" do
      html = render_component(&H.render_empty_errors/1, %{})
      refute html =~ "border-destructive"
    end

    test "renders multiple error messages" do
      html = render_component(&H.render_with_multiple_errors/1, %{})
      assert html =~ "is invalid"
      assert html =~ "can&#39;t be blank"
    end
  end
end
