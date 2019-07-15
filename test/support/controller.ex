defmodule Crit.Test.Controller do

  def flash_error(conn),
    do: Plug.Conn.get_session(conn, :phoenix_flash)["error"]

  def flash_info(conn),
    do: Plug.Conn.get_session(conn, :phoenix_flash)["info"]

  def standard_blank_error, do: "can&#39;t be blank"

  defmacro __using__(controller: controller) do
    quote do
      import Crit.Test.Controller
      
      defp get_via_action(args) do 
        conn = hd(args)
        get(conn, unquote(controller).path(args))
      end

      defp post_to_action(path_args, payload_key, payload_params) do
        conn = hd(path_args)
        post(conn, unquote(controller).path(path_args),
          %{payload_key => payload_params})
      end

      defp assert_purpose(conn, purpose),
        do: assert html_response(conn, 200) =~
          ~r/Purpose:[[:space:]]+#{Regex.escape(purpose)}/

      defp assert_will_post_to(conn, action) do
        assert html_response(conn, 200) =~ "method=\"post\""
        post_to = unquote(controller).path([conn, action])
        assert html_response(conn, 200) =~ "action=\"#{post_to}\""
      end
    end
  end
end