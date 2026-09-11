defmodule SlopUI.Components.Structure do
  @moduledoc "Page structure: page header, empty state, description list."
  use Phoenix.Component
  import SlopUI.Icons

  @doc """
  Renders a page header with title, optional description, an eyebrow slot
  (breadcrumbs go here) and an actions slot.

      <.page_header title="Projects" description="Everything your team is working on.">
        <:eyebrow><.breadcrumbs>…</.breadcrumbs></:eyebrow>
        <:actions><.button color="accent">New project</.button></:actions>
      </.page_header>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :heading_level, :string, default: "h1"
  attr :divider, :boolean, default: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :eyebrow
  slot :actions

  def page_header(assigns) do
    ~H"""
    <header class={[@class, "sl-page-header"]} data-divider={to_string(@divider)} {@rest}>
      <div class="sl-page-header-text">
        <div :if={@eyebrow != []} class="sl-page-header-eyebrow">{render_slot(@eyebrow)}</div>
        <.dynamic_tag tag_name={@heading_level} class="sl-page-title">{@title}</.dynamic_tag>
        <p :if={@description} class="sl-page-description">{@description}</p>
      </div>
      <div :if={@actions != []} class="sl-page-header-actions">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders an empty state.

      <.empty_state title="No projects yet" description="Create your first project to get started.">
        <:icon><.icon name="plus" /></:icon>
        <:actions><.button color="accent">New project</.button></:actions>
      </.empty_state>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :variant, :string, default: "dashed", values: ~w(dashed plain)
  attr :class, :any, default: nil
  attr :rest, :global
  slot :icon
  slot :actions
  slot :inner_block

  def empty_state(assigns) do
    ~H"""
    <div class={[@class, "sl-empty-state"]} data-variant={@variant} {@rest}>
      <span :if={@icon != []} class="sl-empty-state-icon">{render_slot(@icon)}</span>
      <p class="sl-empty-state-title">{@title}</p>
      <p :if={@description} class="sl-empty-state-description">{@description}</p>
      {render_slot(@inner_block)}
      <div :if={@actions != []} class="sl-empty-state-actions">{render_slot(@actions)}</div>
    </div>
    """
  end

  @doc """
  Renders a description list.

      <.description_list divider>
        <:item label="Name">Ada Lovelace</:item>
        <:item label="Role"><.badge>Owner</.badge></:item>
      </.description_list>
  """
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :divider, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :label, :string, required: true
  end

  def description_list(assigns) do
    ~H"""
    <dl
      class={[@class, "sl-description-list"]}
      data-orientation={@orientation}
      data-divider={@divider}
      {@rest}
    >
      <%= for item <- @item do %>
        <dt>{item.label}</dt>
        <dd>{render_slot(item)}</dd>
      <% end %>
    </dl>
    """
  end

  @doc """
  Renders a step indicator.

      <.stepper current={2}>
        <:step title="Account" description="Email and password" />
        <:step title="Profile" />
        <:step title="Done" />
      </.stepper>

  Steps before `current` are complete, `current` is marked with
  `aria-current="step"`. Give a step `navigate`/`patch` to make it a link.
  Set `pulse` when the stepper tracks something running on its own (a
  deploy, an import) so the current marker breathes; it stays still under
  `prefers-reduced-motion`.
  """
  attr :current, :integer, required: true, doc: "1-based index of the current step"
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)

  attr :pulse, :boolean,
    default: false,
    doc: "animate the current step's marker; for tasks in progress, not for forms the user drives"

  attr :class, :any, default: nil
  attr :rest, :global

  slot :step, required: true do
    attr :title, :string, required: true
    attr :description, :string
    attr :navigate, :string
    attr :patch, :string
  end

  def stepper(assigns) do
    ~H"""
    <ol class={[@class, "sl-stepper"]} data-orientation={@orientation} data-pulse={@pulse} {@rest}>
      <li
        :for={{step, i} <- Enum.with_index(@step, 1)}
        class="sl-step"
        data-state={
          cond do
            i < @current -> "complete"
            i == @current -> "current"
            true -> "upcoming"
          end
        }
        aria-current={i == @current && "step"}
      >
        <span class="sl-step-marker" aria-hidden="true">
          <.icon :if={i < @current} name="check" />
        </span>
        <div class="sl-step-body">
          <.link
            :if={step[:navigate] || step[:patch]}
            navigate={step[:navigate]}
            patch={step[:patch]}
            class="sl-step-title"
          >{step.title}</.link>
          <div :if={!(step[:navigate] || step[:patch])} class="sl-step-title">{step.title}</div>
          <div :if={step[:description]} class="sl-step-description">{step.description}</div>
        </div>
      </li>
    </ol>
    """
  end

  @doc """
  Renders a vertical timeline.

      <.timeline>
        <:item title="Deployed v2.1" time="2h ago" color="success">Rolled out to all regions.</:item>
        <:item title="Build started" time="3h ago" />
      </.timeline>
  """
  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :title, :string, required: true
    attr :time, :string
    attr :color, :string, doc: "accent | success | warning | danger | info"
  end

  def timeline(assigns) do
    ~H"""
    <ol class={[@class, "sl-timeline"]} {@rest}>
      <li :for={item <- @item} class="sl-timeline-item" data-color={item[:color]}>
        <span class="sl-timeline-marker" aria-hidden="true"></span>
        <div class="sl-timeline-body">
          <div class="sl-timeline-head">
            <span class="sl-timeline-title">{item.title}</span>
            <time :if={item[:time]} class="sl-timeline-time">{item.time}</time>
          </div>
          <div :if={item[:inner_block]} class="sl-timeline-content">{render_slot(item)}</div>
        </div>
      </li>
    </ol>
    """
  end

  @doc """
  Renders a KPI tile.

      <.stat label="Revenue" value="$48.2k" delta="+12.4%" trend="up" description="vs. last month" />
  """
  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :delta, :string, default: nil
  attr :trend, :string, default: nil, values: [nil, "up", "down", "flat"]
  attr :description, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :icon

  def stat(assigns) do
    ~H"""
    <div class={[@class, "sl-stat"]} {@rest}>
      <div class="sl-stat-head">
        <span>{@label}</span>
        {render_slot(@icon)}
      </div>
      <div class="sl-stat-value">{@value}</div>
      <div :if={@delta || @description} class="sl-stat-foot">
        <span :if={@delta} class="sl-stat-delta" data-trend={@trend}>
          <.icon :if={@trend in ~w(up down)} name="chevron-down" style="rotate: 180deg" />
          {@delta}
        </span>
        <span :if={@description}>{@description}</span>
      </div>
    </div>
    """
  end

  @doc """
  Renders a single collapsible section on `<details>`, with a button as the
  trigger and an animated reveal.

      <.collapsible id="more">
        <:trigger>Show advanced options</:trigger>
        <.input … />
      </.collapsible>
  """
  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  slot :trigger, required: true do
    attr :variant, :string
    attr :size, :string
  end

  slot :inner_block, required: true

  def collapsible(assigns) do
    ~H"""
    <details id={@id} class={[@class, "sl-collapsible"]} open={@open} {@rest}>
      <summary :for={trigger <- @trigger}>
        <span
          class="sl-button"
          data-variant={trigger[:variant] || "ghost"}
          data-color="neutral"
          data-size={trigger[:size] || "sm"}
        >
          {render_slot(trigger)}
          <.icon name="chevron-down" />
        </span>
      </summary>
      <div class="sl-collapsible-content">
        <div class="sl-collapsible-body">{render_slot(@inner_block)}</div>
      </div>
    </details>
    """
  end
end
