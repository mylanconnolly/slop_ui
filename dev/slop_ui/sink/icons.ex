defmodule SlopUI.Sink.Icons do
  @moduledoc "The kitchen sink's own icon sets, showing `use SlopUI.Icons`."

  use SlopUI.Icons,
    sets: [
      phosphor: [
        icons: ~w(house users bell gear rocket-launch heart star lightning coffee planet)
      ],
      bold: [preset: :phosphor, weight: :bold, icons: ~w(heart star lightning)],
      fill: [preset: :phosphor, weight: :fill, icons: ~w(heart star lightning)],
      duo: [preset: :phosphor, weight: :duotone, icons: ~w(heart star lightning rocket-launch)],
      sink: [dir: "dev/icons", icons: :all]
    ]
end
