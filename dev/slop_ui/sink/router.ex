defmodule SlopUI.Sink.ErrorHTML do
  def render(template, _assigns), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule SlopUI.Sink.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_root_layout, html: {SlopUI.Sink.Layouts, :root}
  end

  scope "/", SlopUI.Sink do
    pipe_through :browser

    live "/_contracts", ContractLive
    live "/templates/:name", TemplateLive, :show, as: :template
    live "/", Live, :index, as: :sink
    live "/:page", Live, :page, as: :sink
  end
end
