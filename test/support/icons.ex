defmodule SlopUI.Test.Icons do
  use SlopUI.Icons,
    sets: [
      app: [dir: "test/fixtures/icons", icons: :all],
      phosphor: [dir: "test/fixtures/phosphor", icons: ~w(house)],
      bold: [preset: :phosphor, weight: :bold, dir: "test/fixtures/phosphor", icons: ~w(house)],
      duo: [preset: :phosphor, weight: :duotone, dir: "test/fixtures/phosphor", icons: [:house]],
      hero: [dir: "test/fixtures/heroicons/24/outline", icons: ~w(arrow-path)],
      bare: [dir: "test/fixtures/icons", icons: ~w(spark), prefix: false]
    ]
end
