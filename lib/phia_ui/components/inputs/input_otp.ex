defmodule PhiaUi.Components.InputOtp do
  @moduledoc """
  One-time password (OTP) input component with individual digit slots.

  Provides a composable OTP input following the shadcn/ui InputOTP anatomy
  adapted for Phoenix LiveView. Each digit is rendered as a separate
  `<input type="text" maxlength="1">` element with automatic focus advancement
  on input and focus-back-on-backspace behaviour via inline `onkeyup` /
  `onkeydown` handlers.

  No external JS hook required — navigation is handled with minimal inline
  event handlers.

  ## Enhancements

  - `type` — `:numeric` (default) or `:alphanumeric` (pattern `[A-Za-z0-9]`)
  - `separator` — character shown between the two halves (e.g. `"-"`)
  - `grouped` — visual grouping: removes inner rounded corners and gaps

  ## Sub-components

  | Component           | Element              | Purpose                                             |
  |---------------------|----------------------|-----------------------------------------------------|
  | `input_otp/1`       | Group + N slots      | Simple all-in-one OTP field (most common usage)     |
  | `input_otp_group/1` | `<div role="group">` | Container that groups slots and separators          |
  | `input_otp_slot/1`  | `<input type="text">`| Individual digit cell                               |
  | `input_otp_separator/1` | `<div aria-hidden>` | Visual separator between slot groups             |

  ## Simple usage

      <%!-- 6-digit numeric OTP --%>
      <.input_otp id="otp" name="otp" value={@otp} />

      <%!-- 6-digit alphanumeric with separator and grouping --%>
      <.input_otp id="code" name="code" value={@code} type={:alphanumeric} separator="-" grouped={true} />

      <%!-- 4-digit PIN --%>
      <.input_otp id="pin" name="pin" value={@pin} length={4} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # input_otp/1 — simple all-in-one wrapper
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc:
      "Base ID for the group and each individual slot. Slot IDs are derived as `\#{id}-\#{index}`."
  )

  attr(:length, :integer,
    default: 6,
    doc: "Total number of digit slots to render."
  )

  attr(:name, :string,
    default: nil,
    doc: "Base name for slots. Each slot name is `\#{name}[\#{index}]`."
  )

  attr(:value, :string,
    default: "",
    doc: "Current OTP string. Characters are distributed to slots by position."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, all digit slots are disabled."
  )

  attr(:type, :atom,
    values: [:numeric, :alphanumeric],
    default: :numeric,
    doc: "`:numeric` uses `inputmode=numeric`. `:alphanumeric` uses `inputmode=text` with pattern."
  )

  attr(:separator, :string,
    default: nil,
    doc: "Character shown between the two halves of slots (e.g. `\"-\"`). Nil = no separator."
  )

  attr(:grouped, :boolean,
    default: false,
    doc: "When `true`, removes inner rounded corners/gaps to visually group slots per half."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the group container via `cn/1`."
  )

  @doc """
  Renders a complete OTP input field as a group of individual digit slots.
  """
  def input_otp(assigns) do
    mid = div(assigns.length, 2)
    has_sep = not is_nil(assigns.separator)
    assigns = assign(assigns, :_mid, mid) |> assign(:_has_sep, has_sep)

    ~H"""
    <.input_otp_group id={@id} class={@class}>
      <%= for i <- 0..(@length - 1) do %>
        <% group_pos =
          if @grouped do
            if @_has_sep do
              # Two groups: 0..(mid-1) and mid..(length-1)
              g_start = if i >= @_mid, do: @_mid, else: 0
              g_end = if i >= @_mid, do: @length - 1, else: @_mid - 1
              g_size = g_end - g_start + 1
              pos_in_g = i - g_start
              slot_grouped_pos(pos_in_g, g_size - 1)
            else
              slot_grouped_pos(i, @length - 1)
            end
          end %>
        <.input_otp_slot
          index={i}
          name={"#{@name}[#{i}]"}
          value={String.at(@value || "", i) || ""}
          disabled={@disabled}
          id={"#{@id}-#{i}"}
          next_id={if i < @length - 1, do: "#{@id}-#{i + 1}", else: nil}
          prev_id={if i > 0, do: "#{@id}-#{i - 1}", else: nil}
          input_type={@type}
          group_pos={group_pos}
        />
        <%= if @_has_sep and i == @_mid - 1 do %>
          <div aria-hidden="true" class="text-muted-foreground">{@separator}</div>
        <% end %>
      <% end %>
    </.input_otp_group>
    """
  end

  # ---------------------------------------------------------------------------
  # input_otp_group/1 — container
  # ---------------------------------------------------------------------------

  attr(:id, :string, default: nil, doc: "ID for the group container element.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "Additional HTML attributes forwarded to the group `<div>`.")

  slot(:inner_block,
    required: true,
    doc: "Slot content: `input_otp_slot/1` and `input_otp_separator/1` components."
  )

  @doc """
  Renders the OTP group container `<div role=\"group\">`.
  """
  def input_otp_group(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      class={cn(["flex items-center gap-2", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # input_otp_slot/1 — individual digit cell
  # ---------------------------------------------------------------------------

  attr(:index, :integer, required: true, doc: "Zero-based slot position.")
  attr(:name, :string, default: nil, doc: "The `name` attribute of the `<input>`.")
  attr(:value, :string, default: "", doc: "The current digit value.")
  attr(:id, :string, default: nil, doc: "ID for the `<input>` element.")
  attr(:next_id, :string, default: nil, doc: "ID of the next slot for auto-advance.")
  attr(:prev_id, :string, default: nil, doc: "ID of the previous slot for backspace-back.")
  attr(:disabled, :boolean, default: false, doc: "When `true`, disables the input.")

  attr(:input_type, :atom,
    values: [:numeric, :alphanumeric],
    default: :numeric,
    doc: "Input mode — `:numeric` or `:alphanumeric`."
  )

  attr(:group_pos, :atom,
    default: nil,
    doc: "Grouped position — `:first`, `:middle`, `:last`, `:standalone`, or `nil`."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "Additional HTML attributes forwarded to the `<input>` element.")

  @doc """
  Renders a single OTP digit `<input type=\"text\" maxlength=\"1\">` cell.
  """
  def input_otp_slot(assigns) do
    ~H"""
    <input
      type="text"
      id={@id}
      name={@name}
      value={@value}
      maxlength="1"
      inputmode={if @input_type == :alphanumeric, do: "text", else: "numeric"}
      pattern={if @input_type == :alphanumeric, do: "[A-Za-z0-9]", else: nil}
      autocomplete={if @index == 0, do: "one-time-code", else: nil}
      aria-label={"Digit #{@index + 1}"}
      disabled={@disabled}
      class={cn([slot_class(@group_pos), @class])}
      onkeyup={onkeyup_handler(@next_id)}
      onkeydown={onkeydown_handler(@prev_id)}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # input_otp_separator/1 — visual separator
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes.")

  @doc """
  Renders a decorative separator `<div>` between OTP slot groups.
  """
  def input_otp_separator(assigns) do
    ~H"""
    <div aria-hidden="true" class={cn(["text-muted-foreground", @class])}>-</div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp slot_class(nil) do
    "h-10 w-10 text-center border border-border rounded-md font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slot_class(:standalone) do
    "h-10 w-10 text-center border border-border rounded-md font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slot_class(:first) do
    "h-10 w-10 text-center border border-border border-r-0 rounded-l-md font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slot_class(:middle) do
    "h-10 w-10 text-center border border-border border-r-0 rounded-none font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slot_class(:last) do
    "h-10 w-10 text-center border border-border rounded-r-md font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp slot_grouped_pos(0, 0), do: :standalone
  defp slot_grouped_pos(0, _last), do: :first
  defp slot_grouped_pos(pos, last) when pos == last, do: :last
  defp slot_grouped_pos(_, _), do: :middle

  defp onkeyup_handler(nil), do: nil

  defp onkeyup_handler(next_id) do
    "if(this.value.length>=1){var n=document.getElementById('#{next_id}');if(n)n.focus();}"
  end

  defp onkeydown_handler(nil), do: nil

  defp onkeydown_handler(prev_id) do
    "if(event.key==='Backspace'&&!this.value){var p=document.getElementById('#{prev_id}');if(p){p.focus();p.value='';}}"
  end
end
