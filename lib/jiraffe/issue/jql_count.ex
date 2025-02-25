defmodule Jiraffe.Issue.JqlCount do
  @moduledoc false

  alias Jiraffe.{Issue, Error}
  use Jiraffe.Pagination

  @type jql_search_params() :: [
          jql: String.t()
        ]

  @impl Jiraffe.Pagination
  @spec page(
          Jiraffe.Client.t(),
          params :: jql_search_params()
        ) ::
          {:ok, Jiraffe.ResultsPage.t()} | {:error, Error.t()}
  def page(client, params) do
    body = %{
      jql: Keyword.get(params, :jql)
    }

    case Jiraffe.post(client, "/rest/api/2/search/approximate-count", body) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, result} ->
        {:error, Error.new(:unexpected_status, result)}

      {:error, reason} ->
        {:error, Error.new(reason)}
    end
  end

  @impl Jiraffe.Pagination
  def transform_values(list) do
    list
    |> Enum.reduce(%{issues: [], names: %{}, schema: %{}}, fn v, acc ->
      %{
        issues: acc.issues ++ v.issues,
        names: Map.merge(acc.names, v.names),
        schema: Map.merge(acc.schema, v.schema)
      }
    end)
  end
end
