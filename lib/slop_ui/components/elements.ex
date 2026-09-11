defmodule SlopUI.Components.Elements do
  @moduledoc "Small building blocks: skeleton, progress, spinner, kbd, separator, breadcrumbs, pagination."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Loading placeholder. `aria-hidden`; pair with `aria-busy` on the region.

      <.skeleton shape="circle" height="2.5rem" />
      <.skeleton shape="text" width="60%" />
  """
  attr :shape, :string, default: "rect", values: ~w(rect text circle)
  attr :width, :string, default: nil
  attr :height, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def skeleton(assigns) do
    style =
      [width_var(assigns.width), height_var(assigns.height)]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    assigns = assign(assigns, :style, if(style == "", do: nil, else: style))

    ~H"""
    <span
      class={[@class, "sl-skeleton"]}
      data-shape={@shape}
      style={@style}
      aria-hidden="true"
      {@rest}
    />
    """
  end

  defp width_var(nil), do: nil
  defp width_var(w), do: "--sl-skeleton-width: #{w};"
  defp height_var(nil), do: nil
  defp height_var(h), do: "--sl-skeleton-height: #{h};"

  @doc """
  Progress bar. Omit `value` for an indeterminate bar.

      <.progress value={42} label="Uploading" />
  """
  attr :value, :integer, default: nil, doc: "0..max"
  attr :max, :integer, default: 100
  attr :label, :string, default: nil, doc: "accessible name"
  attr :color, :string, default: "accent", values: ~w(accent success warning danger)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global

  def progress(assigns) do
    ~H"""
    <div
      class={[@class, "sl-progress"]}
      role="progressbar"
      aria-label={@label}
      aria-valuemin="0"
      aria-valuemax={@max}
      aria-valuenow={@value}
      data-color={@color}
      data-size={@size}
      data-indeterminate={is_nil(@value)}
      style={@value && "--_value: #{@value / @max * 100}"}
      {@rest}
    />
    """
  end

  @doc "Spinner with an accessible label."
  attr :label, :string, default: nil, doc: ~s|defaults to "Loading"|
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <span
      class={[@class, "sl-spinner"]}
      role="status"
      aria-label={@label || t("Loading")}
      data-size={@size}
      {@rest}
    />
    """
  end

  @doc "Keyboard key."
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def kbd(assigns) do
    ~H"""
    <kbd class={[@class, "sl-kbd"]} {@rest}>{render_slot(@inner_block)}</kbd>
    """
  end

  @doc "Separator, optionally with a label."
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block

  def separator(assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation={@orientation}
      class={[@class, "sl-separator"]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Breadcrumb trail. The last crumb is the current page.

      <.breadcrumbs>
        <:crumb navigate={~p"/"}>Home</:crumb>
        <:crumb navigate={~p"/posts"}>Posts</:crumb>
        <:crumb>Editing</:crumb>
      </.breadcrumbs>
  """
  attr :class, :any, default: nil
  attr :rest, :global

  slot :crumb, required: true do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
  end

  def breadcrumbs(assigns) do
    ~H"""
    <nav aria-label={t("Breadcrumb")} class={[@class, "sl-breadcrumbs"]} {@rest}>
      <ol>
        <li :for={{crumb, i} <- Enum.with_index(@crumb)}>
          <.icon :if={i > 0} name="chevron-down" />
          <.link
            :if={crumb[:navigate] || crumb[:patch] || crumb[:href]}
            navigate={crumb[:navigate]}
            patch={crumb[:patch]}
            href={crumb[:href]}
          >
            {render_slot(crumb)}
          </.link>
          <span :if={!(crumb[:navigate] || crumb[:patch] || crumb[:href])} aria-current="page">
            {render_slot(crumb)}
          </span>
        </li>
      </ol>
    </nav>
    """
  end

  @doc """
  Pagination. `path` is a function from page number to a path; links use
  `patch` by default.

      <.pagination page={@page} total_pages={@pages} path={&~p"/posts?page=\#{&1}"} />
  """
  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :path, :any, required: true, doc: "fn page -> path"
  attr :link, :string, default: "patch", values: ~w(patch navigate)
  attr :siblings, :integer, default: 1, doc: "pages shown on each side of the current one"
  attr :class, :any, default: nil
  attr :rest, :global

  def pagination(assigns) do
    assigns =
      assign(assigns, :items, page_items(assigns.page, assigns.total_pages, assigns.siblings))

    ~H"""
    <nav aria-label={t("Pagination")} class={[@class, "sl-pagination"]} {@rest}>
      <ul>
        <li>
          <.page_link
            page={@page - 1}
            path={@path}
            link={@link}
            disabled={@page <= 1}
            aria-label={t("Previous page")}
          >
            <.icon name="chevron-down" style="rotate: 90deg" />
          </.page_link>
        </li>
        <li :for={item <- @items}>
          <span :if={item == :gap} class="sl-pagination-gap" aria-hidden="true">…</span>
          <.page_link :if={item != :gap} page={item} path={@path} link={@link} current={item == @page}>
            {item}
          </.page_link>
        </li>
        <li>
          <.page_link
            page={@page + 1}
            path={@path}
            link={@link}
            disabled={@page >= @total_pages}
            aria-label={t("Next page")}
          >
            <.icon name="chevron-down" style="rotate: -90deg" />
          </.page_link>
        </li>
      </ul>
    </nav>
    """
  end

  attr :page, :integer, required: true
  attr :path, :any, required: true
  attr :link, :string, required: true
  attr :current, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  defp page_link(%{disabled: true} = assigns) do
    ~H"""
    <span class="sl-button" data-variant="ghost" data-size="sm" data-icon aria-disabled="true" {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp page_link(assigns) do
    ~H"""
    <.link
      patch={@link == "patch" && @path.(@page)}
      navigate={@link == "navigate" && @path.(@page)}
      class="sl-button"
      data-variant={if @current, do: "soft", else: "ghost"}
      data-size="sm"
      data-icon
      aria-current={@current && "page"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp page_items(page, total, siblings) do
    lo = max(2, page - siblings)
    hi = min(total - 1, page + siblings)

    middle = if hi >= lo, do: Enum.to_list(lo..hi), else: []

    [1] ++
      if(lo > 2, do: [:gap], else: []) ++
      middle ++
      if(hi < total - 1, do: [:gap], else: []) ++
      if total > 1, do: [total], else: []
  end
end
