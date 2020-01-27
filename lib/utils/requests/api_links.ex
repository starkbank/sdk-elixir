defmodule StarkBank.Utils.Requests.APILinks do
  @sandbox_url 'https://sandbox.api.starkbank.com/v1/'
  @production_url 'https://api.starkbank.com/v1/'

  def get_url_by_env(env) do
    cond do
      env == :sandbox -> @sandbox_url
      env == :production -> @production_url
    end
  end
end
