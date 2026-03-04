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

  ## Sub-components

  | Component           | Element              | Purpose                                             |
  |---------------------|----------------------|-----------------------------------------------------|
  | `input_otp/1`       | Group + N slots      | Simple all-in-one OTP field (most common usage)     |
  | `input_otp_group/1` | `<div role="group">` | Container that groups slots and separators          |
  | `input_otp_slot/1`  | `<input type="text">`| Individual digit cell                               |
  | `input_otp_separator/1` | `<div aria-hidden>` | Visual separator between slot groups             |

  ## Simple usage (all-in-one)

      <%!-- 6-digit OTP, default length --%>
      <.input_otp id="otp" name="otp" value={@otp} />

      <%!-- 4-digit PIN --%>
      <.input_otp id="pin" name="pin" value={@pin} length={4} />

      <%!-- Disabled state --%>
      <.input_otp id="otp" name="otp" value="" disabled />

  ## Composable usage (with separator)

      <.input_otp_group id="otp-group">
        <.input_otp_slot index={0} value={String.at(@otp, 0)} name="otp[0]" />
        <.input_otp_slot index={1} value={String.at(@otp, 1)} name="otp[1]" />
        <.input_otp_slot index={2} value={String.at(@otp, 2)} name="otp[2]" />
        <.input_otp_separator />
        <.input_otp_slot index={3} value={String.at(@otp, 3)} name="otp[3]" />
        <.input_otp_slot index={4} value={String.at(@otp, 4)} name="otp[4]" />
        <.input_otp_slot index={5} value={String.at(@otp, 5)} name="otp[5]" />
      </.input_otp_group>

  ## Collecting the value in LiveView

      # In your handle_event/3:
      def handle_event("validate", %{"otp" => digits}, socket) do
        otp = digits |> Map.values() |> Enum.join()
        {:noreply, assign(socket, otp: otp)}
      end

  ## Accessibility

  - The group container carries `role="group"` to semantically associate
    the individual inputs as a single compound widget.
  - Each slot has `aria-label="Digit N"` (1-based) for screen readers.
  - `inputmode="numeric"` on every slot brings up the numeric keyboard on
    mobile devices without restricting input to only numbers on desktop.
  - `autocomplete="one-time-code"` is set on the **first** slot (index 0)
    only, enabling the browser/OS SMS OTP autofill flow.
  - Separators carry `aria-hidden="true"` since they are purely decorative.
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # input_otp/1 — simple all-in-one wrapper
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Base ID for the group and each individual slot. Slot IDs are derived as `\#{id}-\#{index}`."
  )

  attr(:length, :integer,
    default: 6,
    doc: "Total number of digit slots to render. Defaults to 6 for standard TOTP codes."
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

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the group container via `cn/1`."
  )

  @doc """
  Renders a complete OTP input field as a group of individual digit slots.

  Each slot is an `<input type="text" maxlength="1">`. Focus advances
  automatically to the next slot when a digit is entered, and backs up to
  the previous slot when Backspace is pressed on an empty slot.

  ## Examples

      <%!-- 6-digit default --%>
      <.input_otp id="otp" name="otp" value={@otp} />

      <%!-- 4-digit PIN --%>
      <.input_otp id="pin" name="pin" value={@pin} length={4} />

      <%!-- Pre-filled, disabled --%>
      <.input_otp id="code" name="code" value="123456" disabled />
  """
  def input_otp(assigns) do
    ~H"""
    <.input_otp_group id={@id} class={@class}>
      <%= for i <- 0..(@length - 1) do %>
        <.input_otp_slot
          index={i}
          name={"#{@name}[#{i}]"}
          value={String.at(@value || "", i) || ""}
          disabled={@disabled}
          id={"#{@id}-#{i}"}
          next_id={if i < @length - 1, do: "#{@id}-#{i + 1}", else: nil}
          prev_id={if i > 0, do: "#{@id}-#{i - 1}", else: nil}
        />
      <% end %>
    </.input_otp_group>
    """
  end

  # ---------------------------------------------------------------------------
  # input_otp_group/1 — container
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    default: nil,
    doc: "ID for the group container element."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged into the group `<div>` via `cn/1`."
  )

  attr(:rest, :global,
    doc: "Additional HTML attributes forwarded to the group `<div>`."
  )

  slot(:inner_block,
    required: true,
    doc: "Slot content: `input_otp_slot/1` and `input_otp_separator/1` components."
  )

  @doc """
  Renders the OTP group container `<div role="group">`.

  Use this component directly when building a composable OTP layout with
  custom separators between groups of digits.

  ## Example

      <.input_otp_group id="otp-group">
        <.input_otp_slot index={0} name="otp[0]" value="1" />
        <.input_otp_slot index={1} name="otp[1]" value="2" />
        <.input_otp_separator />
        <.input_otp_slot index={2} name="otp[2]" value="3" />
      </.input_otp_group>
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

  attr(:index, :integer,
    required: true,
    doc: "Zero-based slot position. Used to compute `aria-label`, autocomplete, and JS navigation IDs."
  )

  attr(:name, :string,
    default: nil,
    doc: "The `name` attribute of the `<input>`. Typically `\#{base_name}[\#{index}]`."
  )

  attr(:value, :string,
    default: "",
    doc: "The current digit value for this slot (a single character string or empty string)."
  )

  attr(:id, :string,
    default: nil,
    doc: "ID for the `<input>` element. Used for JS focus navigation between adjacent slots."
  )

  attr(:next_id, :string,
    default: nil,
    doc: "ID of the next slot element, used for auto-advance on input."
  )

  attr(:prev_id, :string,
    default: nil,
    doc: "ID of the previous slot element, used for backspace-to-previous behaviour."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "When `true`, disables the input."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`."
  )

  attr(:rest, :global,
    doc: "Additional HTML attributes forwarded to the `<input>` element."
  )

  @doc """
  Renders a single OTP digit `<input type="text" maxlength="1">` cell.

  Focus auto-advances to the next slot on key-up (when a character is
  entered) and returns to the previous slot on Backspace when empty.

  ## Examples

      <.input_otp_slot index={0} name="otp[0]" value="3" />
      <.input_otp_slot index={1} name="otp[1]" value="" disabled />
  """
  def input_otp_slot(assigns) do
    ~H"""
    <input
      type="text"
      id={@id}
      name={@name}
      value={@value}
      maxlength="1"
      inputmode="numeric"
      autocomplete={if @index == 0, do: "one-time-code", else: nil}
      aria-label={"Digit #{@index + 1}"}
      disabled={@disabled}
      class={cn([slot_base_class(), @class])}
      onkeyup={onkeyup_handler(@next_id)}
      onkeydown={onkeydown_handler(@prev_id)}
      {@rest}
    />
    """
  end

  # ---------------------------------------------------------------------------
  # input_otp_separator/1 — visual separator
  # ---------------------------------------------------------------------------

  attr(:class, :string,
    default: nil,
    doc: "Additional CSS classes merged via `cn/1`."
  )

  @doc """
  Renders a decorative separator `<div>` between OTP slot groups.

  Carries `aria-hidden="true"` so screen readers skip it. The default
  content is a dash (`-`) character styled in `text-muted-foreground`.

  ## Example

      <.input_otp_group id="otp-group">
        <.input_otp_slot index={0} name="otp[0]" value="" />
        <.input_otp_slot index={1} name="otp[1]" value="" />
        <.input_otp_separator />
        <.input_otp_slot index={2} name="otp[2]" value="" />
        <.input_otp_slot index={3} name="otp[3]" value="" />
      </.input_otp_group>
  """
  def input_otp_separator(assigns) do
    ~H"""
    <div aria-hidden="true" class={cn(["text-muted-foreground", @class])}>-</div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  # Base Tailwind class string for every digit slot input.
  # Uses semantic theme tokens so it respects light/dark mode and theme presets.
  defp slot_base_class do
    "h-10 w-10 text-center border border-border rounded-md font-mono text-sm " <>
      "bg-background text-foreground " <>
      "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " <>
      "disabled:cursor-not-allowed disabled:opacity-50"
  end

  # Generates the onkeyup inline handler for auto-advance to the next slot.
  # When next_id is nil (last slot), no handler is needed.
  defp onkeyup_handler(nil), do: nil

  defp onkeyup_handler(next_id) do
    "if(this.value.length>=1){var n=document.getElementById('#{next_id}');if(n)n.focus();}"
  end

  # Generates the onkeydown inline handler for backspace-to-previous.
  # When prev_id is nil (first slot), no handler is needed.
  defp onkeydown_handler(nil), do: nil

  defp onkeydown_handler(prev_id) do
    "if(event.key==='Backspace'&&!this.value){var p=document.getElementById('#{prev_id}');if(p){p.focus();p.value='';}}"
  end
end
