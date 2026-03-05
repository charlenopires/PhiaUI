# Tutorial: Booking Platform

Build a complete medical/service appointment booking flow in Phoenix LiveView using PhiaUI. The result is a polished multi-step wizard that lets patients select a date, time, service, and fill in their details — all in a single LiveView with real-time validation.

## What you'll build

- Booking calendar showing available/unavailable dates
- Time slot grid for selecting an appointment time
- Service selection with selectable cards
- Patient info form with Ecto validation
- Multi-step wizard with a step tracker
- Confirmation dialog
- Success toast on booking completion

## Prerequisites

- Phoenix 1.8+ with LiveView 1.1+
- Elixir 1.17+
- TailwindCSS v4 configured
- PhiaUI 0.1.5

---

## Step 1 — Install PhiaUI

```elixir
# mix.exs
def deps do
  [{:phia_ui, "~> 0.1.5"}]
end
```

```bash
mix deps.get
mix phia.install
```

In `assets/css/app.css`:

```css
@import "tailwindcss";
@import "../../../deps/phia_ui/priv/static/theme.css";
```

---

## Step 2 — Eject components

```bash
mix phia.add booking_calendar time_slot_grid step_tracker selectable_card
mix phia.add dialog form field phia_input select button badge toast spinner
mix phia.add card separator icon avatar
```

---

## Step 3 — Register JS hooks

In `assets/js/app.js`:

```javascript
import PhiaDialog from "./phia_hooks/dialog"
import PhiaToast  from "./phia_hooks/toast"

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { PhiaDialog, PhiaToast }
})
```

---

## Step 4 — Define the Booking schema

```elixir
# lib/my_app/bookings/booking.ex
defmodule MyApp.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :date,           :date
    field :time_slot,      :string
    field :service_id,     :string
    field :patient_name,   :string
    field :patient_email,  :string
    field :patient_phone,  :string
    field :notes,          :string
    timestamps()
  end

  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:date, :time_slot, :service_id, :patient_name, :patient_email, :patient_phone, :notes])
    |> validate_required([:date, :time_slot, :service_id, :patient_name, :patient_email])
    |> validate_format(:patient_email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "must be a valid email")
    |> validate_length(:patient_phone, min: 10, message: "must be at least 10 digits")
    |> validate_length(:patient_name, min: 2, max: 100)
  end
end
```

---

## Step 5 — Create the Booking context

```elixir
# lib/my_app/bookings.ex
defmodule MyApp.Bookings do
  alias MyApp.Repo
  alias MyApp.Bookings.Booking

  @services [
    %{id: "general",       name: "General Consultation", duration: "30 min", icon: "stethoscope",    price: "$50"},
    %{id: "dental",        name: "Dental Checkup",       duration: "45 min", icon: "smile",          price: "$80"},
    %{id: "physio",        name: "Physiotherapy",        duration: "60 min", icon: "activity",       price: "$90"},
    %{id: "dermatology",   name: "Dermatology",          duration: "30 min", icon: "shield",         price: "$70"}
  ]

  def list_services, do: @services

  def find_service(id), do: Enum.find(@services, &(&1.id == id))

  # Returns a map of %{Date.t => :available | :unavailable}
  def availability_map(from_date, to_date) do
    booked_dates = Repo.all(
      from b in Booking,
        where: b.date >= ^from_date and b.date <= ^to_date,
        select: {b.date, count(b.id)},
        group_by: b.date
    )
    |> Map.new()

    Date.range(from_date, to_date)
    |> Enum.map(fn date ->
      day = Date.day_of_week(date)  # 1=Mon, 7=Sun
      status = cond do
        day in [6, 7] -> :unavailable                      # weekends closed
        Date.before?(date, Date.utc_today()) -> :unavailable
        Map.get(booked_dates, date, 0) >= 10 -> :unavailable
        true -> :available
      end
      {date, status}
    end)
    |> Map.new()
  end

  def available_slots(date) do
    booked = Repo.all(from b in Booking, where: b.date == ^date, select: b.time_slot)
    all_slots = ~w[09:00 09:30 10:00 10:30 11:00 11:30 14:00 14:30 15:00 15:30 16:00 16:30]
    Enum.reject(all_slots, &(&1 in booked))
  end

  def create_booking(attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end
end
```

---

## Step 6 — Create BookingLive

```elixir
# lib/my_app_web/live/booking_live.ex
defmodule MyAppWeb.BookingLive do
  use MyAppWeb, :live_view
  alias MyApp.Bookings
  alias MyApp.Bookings.Booking

  @total_steps 4

  @impl true
  def mount(_params, _session, socket) do
    availability = Bookings.availability_map(
      Date.utc_today(),
      Date.add(Date.utc_today(), 60)
    )

    form = %Booking{} |> Booking.changeset(%{}) |> to_form()

    {:ok, assign(socket,
      step: 1,
      total_steps: @total_steps,
      availability: availability,
      selected_date: nil,
      available_slots: [],
      selected_slot: nil,
      selected_service: nil,
      services: Bookings.list_services(),
      form: form,
      show_confirm: false
    )}
  end

  @impl true
  def handle_event("select-date", %{"date" => iso}, socket) do
    date = Date.from_iso8601!(iso)
    slots = Bookings.available_slots(date)
    {:noreply, assign(socket, selected_date: date, available_slots: slots, selected_slot: nil)}
  end

  def handle_event("select-slot", %{"value" => slot}, socket) do
    {:noreply, assign(socket, selected_slot: slot)}
  end

  def handle_event("next-step", _params, %{assigns: %{step: 1}} = socket) do
    if socket.assigns.selected_date && socket.assigns.selected_slot do
      {:noreply, assign(socket, step: 2)}
    else
      {:noreply, put_flash(socket, :error, "Please select a date and time slot.")}
    end
  end

  def handle_event("next-step", _params, %{assigns: %{step: 2}} = socket) do
    if socket.assigns.selected_service do
      {:noreply, assign(socket, step: 3)}
    else
      {:noreply, put_flash(socket, :error, "Please select a service.")}
    end
  end

  def handle_event("next-step", _params, %{assigns: %{step: 3}} = socket) do
    changeset = validate_step3(socket.assigns.form)
    if changeset.valid? do
      {:noreply, assign(socket, step: 4, show_confirm: true)}
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("prev-step", _params, socket) do
    {:noreply, assign(socket, step: max(socket.assigns.step - 1, 1))}
  end

  def handle_event("select-service", %{"value" => service_id}, socket) do
    {:noreply, assign(socket, selected_service: service_id)}
  end

  def handle_event("validate", %{"booking" => params}, socket) do
    form = %Booking{} |> Booking.changeset(params) |> Map.put(:action, :validate) |> to_form()
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("cancel-confirm", _params, socket) do
    {:noreply, assign(socket, show_confirm: false)}
  end

  def handle_event("confirm-booking", _params, socket) do
    assigns = socket.assigns
    params = %{
      date:           assigns.selected_date,
      time_slot:      assigns.selected_slot,
      service_id:     assigns.selected_service,
      patient_name:   assigns.form.params["patient_name"],
      patient_email:  assigns.form.params["patient_email"],
      patient_phone:  assigns.form.params["patient_phone"],
      notes:          assigns.form.params["notes"]
    }

    case Bookings.create_booking(params) do
      {:ok, _booking} ->
        socket = socket
          |> assign(show_confirm: false, step: 1)
          |> push_event("phia-toast", %{
              title: "Booking confirmed!",
              description: "Your appointment is scheduled for #{assigns.selected_date} at #{assigns.selected_slot}.",
              variant: "success",
              duration_ms: 6000
            })
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset), show_confirm: false, step: 3)}
    end
  end

  defp validate_step3(form) do
    %Booking{} |> Booking.changeset(form.params) |> Map.put(:action, :validate)
  end

  defp step_status(current, n) do
    cond do
      n < current -> "complete"
      n == current -> "active"
      true -> "upcoming"
    end
  end
end
```

---

## Step 7 — Build the template

```heex
<%!-- lib/my_app_web/live/booking_live.html.heex --%>

<%!-- Mount toast once --%>
<.toast id="booking-toast" />

<div class="min-h-screen bg-muted/30">
  <div class="max-w-4xl mx-auto px-4 py-10">

    <%!-- Header --%>
    <div class="mb-8 text-center">
      <h1 class="text-3xl font-bold">Book an Appointment</h1>
      <p class="text-muted-foreground mt-2">Choose your service, date, and time</p>
    </div>

    <%!-- Step tracker --%>
    <.step_tracker class="mb-10">
      <.step step={1} label="Date & Time"  status={step_status(@step, 1)} />
      <.step step={2} label="Service"      status={step_status(@step, 2)} />
      <.step step={3} label="Your Details" status={step_status(@step, 3)} />
      <.step step={4} label="Confirm"      status={step_status(@step, 4)} />
    </.step_tracker>

    <%!-- STEP 1: Date and Time --%>
    <.card :if={@step == 1}>
      <.card_header>
        <.card_title>Select a Date & Time</.card_title>
        <.card_description>Available slots shown in green</.card_description>
      </.card_header>
      <.card_content>
        <div class="flex flex-col lg:flex-row gap-8">
          <%!-- Calendar --%>
          <div class="flex-1">
            <.booking_calendar
              id="booking-cal"
              availability={@availability}
              selected={@selected_date}
              on_select="select-date"
              min_date={Date.utc_today()}
            />
          </div>

          <%!-- Time Slots --%>
          <div class="flex-1" :if={@selected_date}>
            <h3 class="font-medium mb-3">
              Available times for <%= Calendar.strftime(@selected_date, "%A, %B %d") %>
            </h3>
            <.time_slot_grid
              id="time-slots"
              slots={@available_slots}
              selected={@selected_slot}
              on_select="select-slot"
              cols={3}
            />
            <.empty_state :if={@available_slots == []}>
              <:icon><.icon name="calendar-x" class="h-10 w-10 text-muted-foreground" /></:icon>
              <:title>No slots available</:title>
              <:description>Please select a different date.</:description>
            </.empty_state>
          </div>

          <div :if={!@selected_date} class="flex-1 flex items-center justify-center text-muted-foreground">
            <p class="text-sm">← Select a date to see available times</p>
          </div>
        </div>
      </.card_content>
      <.card_footer>
        <.button
          class="ml-auto"
          phx-click="next-step"
          disabled={!@selected_date || !@selected_slot}
        >
          Continue <.icon name="arrow-right" size="sm" />
        </.button>
      </.card_footer>
    </.card>

    <%!-- STEP 2: Service Selection --%>
    <.card :if={@step == 2}>
      <.card_header>
        <.card_title>Choose a Service</.card_title>
        <.card_description>Select the type of appointment you need</.card_description>
      </.card_header>
      <.card_content>
        <div class="grid grid-cols-2 gap-4">
          <.selectable_card
            :for={service <- @services}
            id={"service-#{service.id}"}
            selected={@selected_service == service.id}
            on_select="select-service"
            value={service.id}
            class="text-center p-6"
          >
            <.icon name={service.icon} class="h-10 w-10 mx-auto mb-3 text-primary" />
            <p class="font-semibold"><%= service.name %></p>
            <p class="text-sm text-muted-foreground mt-1"><%= service.duration %></p>
            <.badge variant="outline" class="mt-2"><%= service.price %></.badge>
          </.selectable_card>
        </div>
      </.card_content>
      <.card_footer class="flex gap-2">
        <.button variant="outline" phx-click="prev-step">Back</.button>
        <.button class="flex-1" phx-click="next-step" disabled={!@selected_service}>
          Continue <.icon name="arrow-right" size="sm" />
        </.button>
      </.card_footer>
    </.card>

    <%!-- STEP 3: Patient Info --%>
    <.card :if={@step == 3}>
      <.card_header>
        <.card_title>Your Details</.card_title>
        <.card_description>Please provide your contact information</.card_description>
      </.card_header>
      <.card_content>
        <.form for={@form} id="patient-form" phx-change="validate" phx-submit="next-step">
          <div class="space-y-4">
            <.phia_input field={@form[:patient_name]} label="Full name" placeholder="Jane Doe" />
            <.phia_input field={@form[:patient_email]} type="email" label="Email"
              placeholder="jane@example.com" phx-debounce="blur" />
            <.phia_input field={@form[:patient_phone]} label="Phone number"
              placeholder="+1 (555) 000-0000" />
            <.phia_input field={@form[:notes]} label="Notes (optional)"
              placeholder="Any special requirements or allergies…" />
          </div>
          <input type="submit" class="hidden" />
        </.form>
      </.card_content>
      <.card_footer class="flex gap-2">
        <.button variant="outline" phx-click="prev-step">Back</.button>
        <.button class="flex-1" phx-click="next-step">Review booking</.button>
      </.card_footer>
    </.card>

    <%!-- Confirmation Dialog --%>
    <.alert_dialog id="confirm-booking" open={@show_confirm}>
      <.alert_dialog_header>
        <.alert_dialog_title>Confirm your appointment</.alert_dialog_title>
        <.alert_dialog_description>
          Please review the details below before confirming.
        </.alert_dialog_description>
      </.alert_dialog_header>

      <div class="my-4 rounded-lg border p-4 space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-muted-foreground">Date</span>
          <span class="font-medium">
            <%= if @selected_date, do: Calendar.strftime(@selected_date, "%B %d, %Y") %>
          </span>
        </div>
        <div class="flex justify-between">
          <span class="text-muted-foreground">Time</span>
          <span class="font-medium"><%= @selected_slot %></span>
        </div>
        <div class="flex justify-between">
          <span class="text-muted-foreground">Service</span>
          <span class="font-medium">
            <%= if @selected_service, do: Bookings.find_service(@selected_service)[:name] %>
          </span>
        </div>
        <.separator />
        <div class="flex justify-between">
          <span class="text-muted-foreground">Patient</span>
          <span class="font-medium"><%= @form.params["patient_name"] %></span>
        </div>
        <div class="flex justify-between">
          <span class="text-muted-foreground">Email</span>
          <span class="font-medium"><%= @form.params["patient_email"] %></span>
        </div>
      </div>

      <.alert_dialog_footer>
        <.alert_dialog_cancel phx-click="cancel-confirm">Go back</.alert_dialog_cancel>
        <.alert_dialog_action phx-click="confirm-booking">
          Confirm booking
        </.alert_dialog_action>
      </.alert_dialog_footer>
    </.alert_dialog>

  </div>
</div>
```

---

## Step 8 — Add router

```elixir
# lib/my_app_web/router.ex
scope "/", MyAppWeb do
  pipe_through :browser
  live "/book", BookingLive, :index
end
```

---

## What you've built

A complete 4-step booking wizard with:
- **BookingCalendar** showing real-time availability from your database
- **TimeSlotGrid** with booked slots automatically excluded
- **SelectableCard** grid for service selection
- **PhiaInput** form with live Ecto validation and inline errors
- **StepTracker** showing progress through the wizard
- **AlertDialog** for booking confirmation
- **Toast** notification on successful booking

> **Next steps:** Add SMS/email confirmation via `Swoosh`, integrate Google Calendar via the `google_api` library, or add a patient portal LiveView where patients can view and cancel upcoming appointments.

← [Back to README](../../README.md)

**See also**: [booking_calendar](../components/calendar.md#booking_calendar) · [time_slot_grid](../components/calendar.md#time_slot_grid) · [selectable_card](../components/cards.md#selectable_card) · [step_tracker](../components/feedback.md#step_tracker)
