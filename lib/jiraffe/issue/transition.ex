defmodule Jiraffe.Issue.Transition do
  @moduledoc """
  This resource represents Transitions which puts an issue in a new state.

  - Get transitions - GET /rest/api/2/issue/{issueIdOrKey}/transitions
  - Do transition - POST /rest/api/2/issue/{issueIdOrKey}/transitions

  - https://docs.atlassian.com/software/jira/docs/api/REST/7.11.0/#api/2/issue-getTransitions

  """
  alias Jiraffe.Error

  alias __MODULE__
  alias Jiraffe.Error

  defstruct id: nil,
            name: nil

  @type t() :: %__MODULE__{
          id: String.t() | nil,
          name: String.t() | nil
        }

  @doc """
  Converts a map (received from Jira API) to `Transition` struct.
  """
  def new(body) do
    %__MODULE__{
      id: body["id"],
      name: body["name"]
      # fields: Map.get(body, "fields", %{})
    }
  end

  def get(client, issueid_or_key) do
    # Get transitions - GET /rest/api/2/issue/{issueIdOrKey}/transitions
    case Jiraffe.get(client, "/rest/api/2/issue/#{issueid_or_key}/transitions") do
      {:ok, %{status: 200, body: body}} ->
        transitions = Map.get(body, "transitions", []) |> Enum.map(&Transition.new/1)
        {:ok, transitions}

      {:ok, result} ->
        {:error, Error.new(:unexpected_status, result)}

      {:error, reason} ->
        {:error, Error.new(reason)}
    end
  end

  @doc """
  Perform a transition on an issue. When performing the transition you can update or set other issue fields.

  Post transition - POST /rest/api/2/issue/{issueIdOrKey}/transitions

  The fields that can be set on transtion, in either the fields parameter or the update parameter can be determined using
  the /rest/api/2/issue/{issueIdOrKey}/transitions?expand=transitions.fields resource.

  If a field is not configured to appear on the transition screen, then it will not be in the transition metadata,
  and a field validation error will occur if it is submitted.

  @TODO: Implement all options via expand - this initial version only sets a comment.

  Responses:
  STATUS 400 If there is no transition specified.
  STATUS 204 Returned if the transition was successful.
  STATUS 404 The issue does not exist or the user does not have permission to view it
  """
  def to(client, issueid_or_key, transition_id, comment) do
    body = %{
      update: %{
        comment: [
          %{
            add: %{
              body: comment
            }
          }
        ]
      },
      transition: %{id: transition_id}
    }

    case Jiraffe.post(client, "/rest/api/2/issue/#{issueid_or_key}/transitions", body) do
      {:ok, %{status: 204}} ->
        {:ok, %{issueid_or_key: issueid_or_key, transition_id: transition_id}}

      {:ok, result} ->
        {:error, Error.new(:unexpected_status, result)}

      {:error, reason} ->
        {:error, Error.new(reason)}
    end
  end
end
