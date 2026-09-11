defmodule SlopUI.Sink.Layouts do
  use Phoenix.Component
  use SlopUI

  attr :inner_content, :any, required: true
  attr :page_title, :string, default: nil

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <.live_title default="SlopUI" suffix=" · SlopUI">{@page_title}</.live_title>
        <.theme_script />
        <link rel="stylesheet" href="/css/app.css" />
        <script defer type="module" src="/js/app.js">
        </script>
      </head>
      <body>
        {@inner_content}
      </body>
    </html>
    """
  end
end
