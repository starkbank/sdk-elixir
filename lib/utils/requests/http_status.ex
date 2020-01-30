defmodule StarkBank.Utils.Requests.HTTPStatus do
  @moduledoc false

  @ok 200
  @unauthorized 401

  def unauthorized do
    @unauthorized
  end

  def ok do
    @ok
  end
end
