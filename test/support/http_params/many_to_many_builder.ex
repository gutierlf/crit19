defmodule Crit.Params.ManyToManyBuilder do
  @moduledoc """
  A builder for controller params of this form:

  %{
    "0" => %{...},
    "1" => %{...},
    ...
  }
  """

  defmacro __using__(_) do
    quote do
      use Crit.Params.Builder
      alias Crit.Params.Builder
      alias Crit.Params.Validation

      # ----------------------------------------------------------------------------

      defp make_params_for_name(config, name),
        do: Builder.make_numbered_params(config(), [name])


      def that_are(descriptors) when is_list(descriptors) do
        Builder.make_numbered_params(config(), descriptors)
      end
  
      def that_are(descriptor),       do: that_are([descriptor])
      def that_are(descriptor, opts), do: that_are([[descriptor | opts]])
    end
  end  
end
