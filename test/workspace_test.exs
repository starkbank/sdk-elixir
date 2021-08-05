defmodule StarkBankTest.Workspace do
  use ExUnit.Case

  @tag :workspace
  test "create and update workspace" do
    workspace_info = example_workspace()
    {:ok, workspace} = StarkBank.Workspace.create(
      username: workspace_info.username,
      name: workspace_info.name,
      allowed_tax_ids: workspace_info.allowed_tax_ids,
      user: organization()
    )
    assert not is_nil(workspace.id)

    update = example_workspace()
    {:ok, updated_workspace} = StarkBank.Workspace.update(
      workspace.id,
      username: update.username,
      name: update.name,
      allowed_tax_ids: update.allowed_tax_ids,
      user: organization() |> StarkBank.Organization.replace(workspace.id)
    )
    assert updated_workspace.username == update.username
    assert updated_workspace.name == update.name
    assert updated_workspace.allowed_tax_ids == update.allowed_tax_ids
  end

  @tag :workspace
  test "create! and update! workspace" do
    workspace_info = example_workspace()
    workspace = StarkBank.Workspace.create!(
      username: workspace_info.username,
      name: workspace_info.name,
      allowed_tax_ids: workspace_info.allowed_tax_ids,
      user: organization()
    )
    assert not is_nil(workspace.username)

    update = example_workspace()
    updated_workspace = StarkBank.Workspace.update!(
      workspace.id,
      username: update.username,
      name: update.name,
      allowed_tax_ids: update.allowed_tax_ids,
      user: organization() |> StarkBank.Organization.replace(workspace.id)
    )
    assert updated_workspace.username == update.username
    assert updated_workspace.name == update.name
    assert updated_workspace.allowed_tax_ids == update.allowed_tax_ids
  end

  @tag :workspace
  test "query workspace" do
    StarkBank.Workspace.query(limit: 101, user: organization())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :workspace
  test "query! workspace" do
    StarkBank.Workspace.query!(limit: 101, user: organization())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :workspace
  test "query workspace ids" do
    workspaces_ids_expected =
      StarkBank.Workspace.query(limit: 10, user: organization())
      |> Enum.take(100)
      |> Enum.map(fn {:ok, workspace} -> workspace.id end)

    assert length(workspaces_ids_expected) <= 10

    workspaces_ids_result =
      StarkBank.Workspace.query(ids: workspaces_ids_expected, user: organization())
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
      StarkBank.Workspace.query!(limit: 10, user: organization())
      |> Enum.take(100)
      |> Enum.map(fn workspace -> workspace.id end)

    assert length(workspaces_ids_expected) <= 10

    workspaces_ids_result =
      StarkBank.Workspace.query!(ids: workspaces_ids_expected, user: organization())
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
      StarkBank.Workspace.query!(user: organization())
      |> Enum.take(1)
      |> hd()

    {:ok, _workspace} = StarkBank.Workspace.get(workspace.id, user: organization() |> StarkBank.Organization.replace(workspace.id))
  end

  @tag :workspace
  test "get! workspace" do
    workspace =
      StarkBank.Workspace.query!(user: organization())
      |> Enum.take(1)
      |> hd()

    _workspace = StarkBank.Workspace.get!(workspace.id, user: organization() |> StarkBank.Organization.replace(workspace.id))
  end

  def example_workspace() do
    id = Enum.random(0..100_000_000_000) |> Integer.to_string
    %StarkBank.Workspace{
      username: "starkv2-" <> id,
      name: "Stark V2: " <> id,
      allowed_tax_ids: ["20.018.183/0001-80"]
    }
  end

  def organization() do
    StarkBank.organization(
      environment: :sandbox,
      id: System.fetch_env!("SANDBOX_ORGANIZATION_ID"),
      private_key: System.fetch_env!("SANDBOX_ORGANIZATION_PRIVATE_KEY")
    )
  end
end
