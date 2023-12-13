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
    "Invalid Login or user disabled"
  end

  def unauthorized(%{message: message}) do
    message
  end

  def unauthorized(_assigns) do
    "Unauthorized"
  end

  def forbidden(%{message: message}) do
    message
  end

  def forbidden(_assigns) do
    "Forbidden"
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def cannot_create_user(_assigns) do
    "Cannot create user. You must be an admin"
  end
end
