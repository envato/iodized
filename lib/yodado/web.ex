defmodule Yodado.Web do
  use Application.Behaviour

  @handler_count 100
  @port 8080

  def start(_type, _args) do
    routes = [
      {"/", :cowboy_static, [ 
        directory: {:priv_dir, :yodado, ["static"]},
        file: "index.html",
        mimetypes: {&:mimetypes.path_to_mimes/2, :default}
      ]},
      {"/feature/[:feature_id]", Yodado.Web.FeatureStatusHandler, []},
      {"/hello/", Yodado.Web.HelloWorldHandler, []},
      {"/static/[...]", :cowboy_static, [ 
        directory: {:priv_dir, :yodado, "static"},
        mimetypes: {&:mimetypes.path_to_mimes/2, :default}
      ]}
    ]

    dispatch = [ {:_, routes } ] |> :cowboy_router.compile

    {:ok, _} = :cowboy.start_http( :http, @handler_count, [port: @port], [env: [dispatch: dispatch]])
    {:ok, self}
  end
end
