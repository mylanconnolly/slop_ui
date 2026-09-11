defmodule SlopUI.Components.Carousel do
  @moduledoc "A scroll-snap carousel with buttons, dots and optional autoplay."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders a carousel of slides.

      <.carousel id="hero" label="Featured posts" loop>
        <:slide :for={post <- @posts}><.card>…</.card></:slide>
      </.carousel>

      <.carousel id="logos" label="Customers" per_view={3} autoplay={4000}>…</.carousel>

  The track is a native scroll-snap container, so it scrolls by touch, wheel
  and keyboard without JavaScript; the hook adds previous/next buttons, dot
  tabs, wrap-around (`loop`) and autoplay. Autoplay (milliseconds per slide)
  pauses while hovered or focused, has a visible pause button (WCAG 2.2.2),
  and never starts for users who prefer reduced motion. The current slide is
  announced politely on user-driven changes.

  Keyboard: Left/Right (or Up/Down) move a slide, Home/End jump, on the track
  or any control; the dots are a tab list with the same arrow keys.
  """
  attr :id, :string, required: true
  attr :label, :string, required: true, doc: "accessible name of the carousel"
  attr :per_view, :integer, default: 1, doc: "slides visible at once"
  attr :loop, :boolean, default: false
  attr :autoplay, :integer, default: nil, doc: "milliseconds per slide; nil disables"
  attr :dots, :boolean, default: true
  attr :controls, :boolean, default: true, doc: "previous/next buttons"
  attr :style, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :slide, required: true do
    attr :label, :string, doc: ~s|accessible name; defaults to "n of m"|
  end

  def carousel(assigns) do
    assigns = assign(assigns, :count, length(assigns.slide))

    ~H"""
    <section
      id={@id}
      class={[@class, "sl-carousel"]}
      style={"--sl-carousel-per-view: #{@per_view};#{@style}"}
      aria-roledescription={t("carousel")}
      aria-label={@label}
      data-loop={@loop}
      data-autoplay={@autoplay}
      data-label-slide={t("Slide %{n} of %{total}", n: "%{n}", total: "%{total}")}
      data-label-pause={t("Pause")}
      data-label-play={t("Play")}
      phx-hook="SlCarousel"
      {@rest}
    >
      <div id={"#{@id}-track"} class="sl-carousel-track" tabindex="0" aria-live="off">
        <div
          :for={{slide, i} <- Enum.with_index(@slide, 1)}
          id={"#{@id}-slide-#{i}"}
          class="sl-carousel-slide"
          role="tabpanel"
          aria-roledescription={t("slide")}
          aria-label={slide[:label] || t("%{n} of %{total}", n: i, total: @count)}
          data-index={i}
        >
          {render_slot(slide)}
        </div>
      </div>

      <div :if={@controls || @dots || @autoplay} class="sl-carousel-bar">
        <button
          :if={@controls}
          type="button"
          class="sl-button"
          data-variant="outline"
          data-size="sm"
          data-icon
          data-sl-prev
          aria-label={t("Previous slide")}
          aria-controls={"#{@id}-track"}
        >
          <.icon name="chevron-left" />
        </button>

        <div :if={@dots} class="sl-carousel-dots" role="tablist" aria-label={t("Choose a slide")}>
          <button
            :for={i <- 1..@count//1}
            type="button"
            role="tab"
            class="sl-carousel-dot"
            aria-selected={to_string(i == 1)}
            aria-controls={"#{@id}-slide-#{i}"}
            aria-label={t("Slide %{n}", n: i)}
            tabindex={if i == 1, do: "0", else: "-1"}
            data-index={i}
          ></button>
        </div>

        <button
          :if={@autoplay}
          type="button"
          class="sl-button"
          data-variant="ghost"
          data-size="sm"
          data-sl-pause
          aria-pressed="false"
        >
          {t("Pause")}
        </button>

        <button
          :if={@controls}
          type="button"
          class="sl-button"
          data-variant="outline"
          data-size="sm"
          data-icon
          data-sl-next
          aria-label={t("Next slide")}
          aria-controls={"#{@id}-track"}
        >
          <.icon name="chevron-right" />
        </button>
      </div>
      <span class="sl-visually-hidden" aria-live="polite" data-sl-announce></span>
    </section>
    """
  end
end
