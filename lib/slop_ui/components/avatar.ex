defmodule SlopUI.Components.Avatar do
  @moduledoc "Avatars and avatar groups."
  use Phoenix.Component
  import SlopUI.I18n
  import SlopUI.Icons

  @doc """
  Renders an avatar: an image when `src` is given, otherwise initials derived
  from `name`, otherwise a generic person icon.

      <.avatar src={@user.avatar_url} name={@user.name} />
      <.avatar name="Ada Lovelace" size="lg" status="online" />
      <.avatar name="Ada Lovelace" shape="square" />

  Behaviour worth knowing:

    * If the image fails to load it is removed and the initials show instead
      (a single delegated listener in the SlopUI JS handles this; no hook).
    * Initials get a stable background hue derived from `name`, so the same
      person always gets the same color. Set `color` to override.
    * `status` renders a dot with an accessible label; the avatar's own
      `aria-label` becomes "Name, online".
  """
  attr :src, :string, default: nil
  attr :name, :string, default: nil, doc: "used for the accessible name and initials"
  attr :size, :string, default: "md", values: ~w(xs sm md lg xl)
  attr :shape, :string, default: "circle", values: ~w(circle square)
  attr :status, :string, default: nil, values: [nil, "online", "offline", "busy", "away"]

  attr :color, :string,
    default: nil,
    doc: "accent | neutral | success | warning | danger | info; default hashes the name"

  attr :class, :any, default: nil
  attr :rest, :global

  def avatar(assigns) do
    assigns =
      assigns
      |> assign(:initials, initials(assigns.name))
      |> assign(:hue, if(assigns.color, do: nil, else: hue(assigns.name)))
      |> assign(
        :label,
        [assigns.name, assigns.status] |> Enum.reject(&is_nil/1) |> Enum.join(", ")
      )

    ~H"""
    <span
      class={[@class, "sl-avatar"]}
      data-size={@size}
      data-shape={@shape}
      data-color={@color}
      style={@hue && "--_hue: #{@hue}"}
      role="img"
      aria-label={@label != "" && @label}
      {@rest}
    >
      <span :if={@initials} class="sl-avatar-fallback" aria-hidden="true">{@initials}</span>
      <.icon :if={!@initials} name="user" class="sl-avatar-fallback" />
      <img :if={@src} src={@src} alt="" loading="lazy" decoding="async" />
      <span :if={@status} class="sl-avatar-status" data-status={@status} />
    </span>
    """
  end

  @doc """
  Overlapping group of avatars. Pass `overflow` to append a "+N" marker.

      <.avatar_group overflow={4}>
        <.avatar name="Ada" /><.avatar name="Grace" /><.avatar name="Linus" />
      </.avatar_group>
  """
  attr :size, :string, default: "md", values: ~w(xs sm md lg xl)
  attr :overflow, :integer, default: nil, doc: "number of avatars not shown"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def avatar_group(assigns) do
    ~H"""
    <div class={[@class, "sl-avatar-group"]} data-size={@size} {@rest}>
      {render_slot(@inner_block)}
      <span
        :if={@overflow && @overflow > 0}
        class="sl-avatar sl-avatar-overflow"
        data-size={@size}
        aria-label={tn("%{count} more", "%{count} more", @overflow)}
      >
        +{@overflow}
      </span>
    </div>
    """
  end

  defp initials(nil), do: nil

  defp initials(name) do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
    |> case do
      "" -> nil
      s -> s
    end
  end

  # Stable hue in 0..359 from the name, so a person keeps their color.
  defp hue(nil), do: nil
  defp hue(name), do: :erlang.phash2(name, 360)
end
