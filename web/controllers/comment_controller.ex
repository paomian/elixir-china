defmodule ElixirChina.CommentController do
  import Ecto.Query
  use Phoenix.Controller
  alias ElixirChina.Router
  alias ElixirChina.Comment

  def index(conn, %{"post_id" => post_id}) do
    render conn, "index", post_id: post_id, 
      comments: Repo.all(from comment in Comment, where: comment.post_id == ^String.to_integer(post_id))
  end

  def show(conn, %{"post_id" => post_id, "id" => id}) do
    case Repo.get(Comment, String.to_integer(id)) do
      comment when is_map(comment) ->
        render conn, "show", post_id: post_id, comment: comment
      _ ->
        redirect conn, Router.page_path(page: "unauthorized")
    end
  end

  def new(conn, %{"post_id" => post_id}) do
    render conn, "new",  post_id: post_id
  end

  def create(conn, %{"post_id" => post_id, "comment" => params}) do
    comment = %Comment{post_id: String.to_integer(post_id), content: params["content"]}

    case Comment.validate(comment) do
      [] ->
        comment = Repo.insert(comment)
        render conn, "show", comment: comment, post_id: post_id
      errors ->
        render conn, "new", comment: comment, errors: errors
    end
  end

  def edit(conn, %{"post_id" => post_id, "id" => id}) do
    case Repo.get(Comment, String.to_integer(id)) do
      comment when is_map(comment) ->
        render conn, "edit", comment: comment, post_id: post_id
      _ ->
        redirect conn, Router.page_path("unauthorized")
    end
  end

  def update(conn, %{"post_id" => post_id, "id" => id, "comment" => params}) do
    comment = Repo.get(Comment, String.to_integer(id))
    comment = %{comment | content: params["content"]}

    case Comment.validate(comment) do
      [] ->
        Repo.update(comment)
        json conn, 201, JSON.encode!(%{location: Router.post_comment_path(:show, post_id, comment.id)})
      errors ->
        json conn, errors: errors
    end
  end

  def destroy(conn, %{"post_id" => post_id, "id" => id}) do
    comment = Repo.get(Comment, String.to_integer(id))
    case comment do
      comment when is_map(comment) ->
        Repo.delete(comment)
        json conn, 200, JSON.encode!(%{location: Router.post_path(:show, post_id)})
      _ ->
        redirect conn, Router.page_path("unauthorized")
    end
  end
end