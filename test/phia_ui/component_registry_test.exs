defmodule PhiaUi.ComponentRegistryTest do
  use ExUnit.Case, async: true

  alias PhiaUi.ComponentRegistry

  @required_fields [
    :name,
    :module,
    :template_file,
    :js_hooks,
    :dependencies,
    :tier,
    :shadcn_equivalent,
    :status
  ]
  @valid_tiers [:primitive, :interactive, :form, :navigation, :shell, :widget, :layout, :animation, :surface]
  @valid_statuses [:planned, :implemented]

  describe "all/0" do
    test "returns a map" do
      assert is_map(ComponentRegistry.all())
    end

    test "contains exactly 584 components" do
      assert map_size(ComponentRegistry.all()) == 584
    end

    test "all keys are atom component names" do
      ComponentRegistry.all()
      |> Map.keys()
      |> Enum.each(fn key -> assert is_atom(key) end)
    end

    test "every entry has all required fields" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        Enum.each(@required_fields, fn field ->
          assert Map.has_key?(meta, field),
                 "Component #{meta[:name]} missing field :#{field}"
        end)
      end)
    end

    test "every entry has a non-empty string name" do
      ComponentRegistry.all()
      |> Enum.each(fn {key, meta} ->
        assert is_binary(meta.name) and meta.name != "",
               "Component key #{inspect(key)} has invalid :name"
      end)
    end

    test "every entry has a valid tier" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert meta.tier in @valid_tiers,
               "Component #{meta.name} has invalid tier: #{inspect(meta.tier)}"
      end)
    end

    test "every entry has a valid status" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert meta.status in @valid_statuses,
               "Component #{meta.name} has invalid status: #{inspect(meta.status)}"
      end)
    end

    test "every entry has a list for js_hooks" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert is_list(meta.js_hooks),
               "Component #{meta.name} :js_hooks must be a list"
      end)
    end

    test "every entry has a list for dependencies" do
      ComponentRegistry.all()
      |> Enum.each(fn {_key, meta} ->
        assert is_list(meta.dependencies),
               "Component #{meta.name} :dependencies must be a list"
      end)
    end
  end

  describe "get/1" do
    test "returns metadata for a known component" do
      assert %{name: "button"} = ComponentRegistry.get(:button)
    end

    test "returns nil for unknown component" do
      assert ComponentRegistry.get(:unknown_component) == nil
    end
  end

  describe "by_tier/1" do
    test "returns only primitive components" do
      primitives = ComponentRegistry.by_tier(:primitive)
      assert primitives != []
      Enum.each(primitives, fn meta -> assert meta.tier == :primitive end)
    end

    test "returns only interactive components" do
      interactive = ComponentRegistry.by_tier(:interactive)
      assert interactive != []
      Enum.each(interactive, fn meta -> assert meta.tier == :interactive end)
    end
  end

  describe "known components present" do
    test "button is registered" do
      assert ComponentRegistry.get(:button) != nil
    end

    test "card is registered" do
      assert ComponentRegistry.get(:card) != nil
    end

    test "dialog is registered as interactive" do
      meta = ComponentRegistry.get(:dialog)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "stat_card depends on card and badge" do
      meta = ComponentRegistry.get(:stat_card)
      assert :card in meta.dependencies
      assert :badge in meta.dependencies
    end

    test "dialog has js_hooks" do
      meta = ComponentRegistry.get(:dialog)
      assert meta.js_hooks != []
    end

    test "avatar_group is registered" do
      assert ComponentRegistry.get(:avatar_group) != nil
    end

    test "selectable_card is registered as interactive" do
      meta = ComponentRegistry.get(:selectable_card)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "input_addon is registered as form" do
      meta = ComponentRegistry.get(:input_addon)
      assert meta != nil
      assert meta.tier == :form
    end

    test "circular_progress is registered as widget" do
      meta = ComponentRegistry.get(:circular_progress)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "event_calendar is registered as widget" do
      meta = ComponentRegistry.get(:event_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "uptime_bar is registered as widget" do
      meta = ComponentRegistry.get(:uptime_bar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "receipt_card is registered as widget" do
      meta = ComponentRegistry.get(:receipt_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "heatmap_calendar is registered as widget" do
      meta = ComponentRegistry.get(:heatmap_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "sparkline_card is registered as widget" do
      meta = ComponentRegistry.get(:sparkline_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "gauge_chart is registered as widget" do
      meta = ComponentRegistry.get(:gauge_chart)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "gantt_chart is registered as widget" do
      meta = ComponentRegistry.get(:gantt_chart)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "snackbar is registered as interactive" do
      meta = ComponentRegistry.get(:snackbar)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "time_picker is registered as form" do
      meta = ComponentRegistry.get(:time_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "date_time_picker is registered as form" do
      meta = ComponentRegistry.get(:date_time_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "month_picker is registered as form" do
      meta = ComponentRegistry.get(:month_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "year_picker is registered as form" do
      meta = ComponentRegistry.get(:year_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "week_picker is registered as form" do
      meta = ComponentRegistry.get(:week_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "date_field is registered as form" do
      meta = ComponentRegistry.get(:date_field)
      assert meta != nil
      assert meta.tier == :form
    end

    test "calendar_time_picker is registered as widget" do
      meta = ComponentRegistry.get(:calendar_time_picker)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "date_range_presets is registered as widget" do
      meta = ComponentRegistry.get(:date_range_presets)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "big_calendar is registered as widget" do
      meta = ComponentRegistry.get(:big_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "calendar_week_view is registered as widget" do
      meta = ComponentRegistry.get(:calendar_week_view)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "date_card is registered as interactive" do
      meta = ComponentRegistry.get(:date_card)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "date_strip is registered as interactive" do
      meta = ComponentRegistry.get(:date_strip)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "week_calendar is registered as widget" do
      meta = ComponentRegistry.get(:week_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "range_calendar is registered as widget" do
      meta = ComponentRegistry.get(:range_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "time_slot_grid is registered as interactive" do
      meta = ComponentRegistry.get(:time_slot_grid)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "wheel_picker is registered as form" do
      meta = ComponentRegistry.get(:wheel_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "multi_select_calendar is registered as widget" do
      meta = ComponentRegistry.get(:multi_select_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "badge_calendar is registered as widget" do
      meta = ComponentRegistry.get(:badge_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "daily_agenda is registered as widget" do
      meta = ComponentRegistry.get(:daily_agenda)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "schedule_event_card is registered as widget" do
      meta = ComponentRegistry.get(:schedule_event_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "countdown_timer is registered as widget" do
      meta = ComponentRegistry.get(:countdown_timer)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "time_slot_list is registered as interactive" do
      meta = ComponentRegistry.get(:time_slot_list)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "time_slider_picker is registered as form" do
      meta = ComponentRegistry.get(:time_slider_picker)
      assert meta != nil
      assert meta.tier == :form
    end

    test "booking_calendar is registered as widget" do
      meta = ComponentRegistry.get(:booking_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "streak_calendar is registered as widget" do
      meta = ComponentRegistry.get(:streak_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "schedule_view is registered as widget" do
      meta = ComponentRegistry.get(:schedule_view)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "multi_month_calendar is registered as widget" do
      meta = ComponentRegistry.get(:multi_month_calendar)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "image_card is registered as widget" do
      meta = ComponentRegistry.get(:image_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "profile_card is registered as widget" do
      meta = ComponentRegistry.get(:profile_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "feature_card is registered as widget" do
      meta = ComponentRegistry.get(:feature_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "article_card is registered as widget" do
      meta = ComponentRegistry.get(:article_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "testimonial_card is registered as widget" do
      meta = ComponentRegistry.get(:testimonial_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "pricing_card is registered as widget" do
      meta = ComponentRegistry.get(:pricing_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "product_card is registered as widget" do
      meta = ComponentRegistry.get(:product_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "progress_card is registered as widget" do
      meta = ComponentRegistry.get(:progress_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "notification_card is registered as widget" do
      meta = ComponentRegistry.get(:notification_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "file_card is registered as widget" do
      meta = ComponentRegistry.get(:file_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "event_card is registered as widget" do
      meta = ComponentRegistry.get(:event_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "team_card is registered as widget" do
      meta = ComponentRegistry.get(:team_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "link_preview_card is registered as widget" do
      meta = ComponentRegistry.get(:link_preview_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "color_swatch_card is registered as widget" do
      meta = ComponentRegistry.get(:color_swatch_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "cta_card is registered as widget" do
      meta = ComponentRegistry.get(:cta_card)
      assert meta != nil
      assert meta.tier == :widget
    end

    test "marquee is registered as animation" do
      meta = ComponentRegistry.get(:marquee)
      assert meta != nil
      assert meta.tier == :animation
    end

    test "aurora is registered as animation" do
      meta = ComponentRegistry.get(:aurora)
      assert meta != nil
      assert meta.tier == :animation
    end

    test "fade_in is registered as animation" do
      meta = ComponentRegistry.get(:fade_in)
      assert meta != nil
      assert meta.tier == :animation
    end

    test "number_ticker is registered as animation" do
      meta = ComponentRegistry.get(:number_ticker)
      assert meta != nil
      assert meta.tier == :animation
    end

    test "confetti_burst is registered as animation with hook" do
      meta = ComponentRegistry.get(:confetti_burst)
      assert meta != nil
      assert meta.tier == :animation
      assert "PhiaConfetti" in meta.js_hooks
    end

    test "particle_bg is registered as animation with hook" do
      meta = ComponentRegistry.get(:particle_bg)
      assert meta != nil
      assert meta.tier == :animation
      assert "PhiaParticleBg" in meta.js_hooks
    end

    test "typewriter has PhiaTypewriter hook" do
      meta = ComponentRegistry.get(:typewriter)
      assert "PhiaTypewriter" in meta.js_hooks
    end

    test "word_rotate has PhiaWordRotate hook" do
      meta = ComponentRegistry.get(:word_rotate)
      assert "PhiaWordRotate" in meta.js_hooks
    end

    test "spotlight has PhiaSpotlight hook" do
      meta = ComponentRegistry.get(:spotlight)
      assert "PhiaSpotlight" in meta.js_hooks
    end

    test "split_button is registered as interactive with hook" do
      meta = ComponentRegistry.get(:split_button)
      assert meta != nil
      assert meta.tier == :interactive
      assert "PhiaSplitButton" in meta.js_hooks
    end

    test "icon_button is registered as primitive" do
      meta = ComponentRegistry.get(:icon_button)
      assert meta != nil
      assert meta.tier == :primitive
    end

    test "social_button is registered as interactive" do
      meta = ComponentRegistry.get(:social_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "social_button_group is registered as interactive" do
      meta = ComponentRegistry.get(:social_button_group)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "gradient_button is registered as interactive" do
      meta = ComponentRegistry.get(:gradient_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "shimmer_button is registered as interactive" do
      meta = ComponentRegistry.get(:shimmer_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "glow_button is registered as interactive" do
      meta = ComponentRegistry.get(:glow_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "pulse_button is registered as interactive" do
      meta = ComponentRegistry.get(:pulse_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "close_button is registered as primitive" do
      meta = ComponentRegistry.get(:close_button)
      assert meta != nil
      assert meta.tier == :primitive
    end

    test "badge_button is registered as interactive" do
      meta = ComponentRegistry.get(:badge_button)
      assert meta != nil
      assert meta.tier == :interactive
    end

    test "confirm_button is registered as interactive with hook" do
      meta = ComponentRegistry.get(:confirm_button)
      assert meta != nil
      assert meta.tier == :interactive
      assert "PhiaConfirmButton" in meta.js_hooks
    end

    test "countdown_button is registered as interactive with hook" do
      meta = ComponentRegistry.get(:countdown_button)
      assert meta != nil
      assert meta.tier == :interactive
      assert "PhiaCountdownButton" in meta.js_hooks
    end
  end
end
