defmodule StarkBankTest.Workspace do
  use ExUnit.Case

  @tag :workspace
  test "query workspace" do
    StarkBank.Workspace.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :workspace
  test "query! workspace" do
    StarkBank.Workspace.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :workspace
  test "query workspace ids" do
    workspaces_ids_expected =
      StarkBank.Workspace.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, workspace} -> workspace.id end)

    assert length(workspaces_ids_expected) <= 10

    workspaces_ids_result =
      StarkBank.Workspace.query(ids: workspaces_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, workspace} -> workspace.id end)

    assert length(workspaces_ids_result) <= 10

    workspaces_ids_expected = Enum.sort(workspaces_ids_expected)
    workspaces_ids_result = Enum.sort(workspaces_ids_result)

    assert workspaces_ids_expected == workspaces_ids_result
  end

  @tag :workspace
  test "query! workspace ids" do
    workspaces_ids_expected =
      StarkBank.Workspace.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn workspace -> workspace.id end)

    assert length(workspaces_ids_expected) <= 10

    workspaces_ids_result =
      StarkBank.Workspace.query!(ids: workspaces_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn workspace -> workspace.id end)

    assert length(workspaces_ids_result) <= 10

    workspaces_ids_expected = Enum.sort(workspaces_ids_expected)
    workspaces_ids_result = Enum.sort(workspaces_ids_result)

    assert workspaces_ids_expected == workspaces_ids_result
  end

  @tag :workspace
  test "get workspace" do
    workspace =
      StarkBank.Workspace.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _workspace} = StarkBank.Workspace.get(workspace.id)
  end

  @tag :workspace
  test "get! workspace" do
    workspace =
      StarkBank.Workspace.query!()
      |> Enum.take(1)
      |> hd()

    _workspace = StarkBank.Workspace.get!(workspace.id)
  end

  def example_workspace() do
    %StarkBank.Workspace{
      username: "starkbankworkspace",
      name: "Stark Bank Workspace",
    }
  end
end
