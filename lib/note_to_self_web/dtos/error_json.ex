defmodule NoteToSelfWeb.Dtos.ErrorJSON do
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  alias NoteToSelfWeb.Dtos.ErrorHelpers
  def ecto(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)}
  end

  def login(_assigns) do
    IO.puts("Inside login")
    "Invalid Login"
  end

  def render(template, _assigns) do
    IO.puts("Inside render")
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
