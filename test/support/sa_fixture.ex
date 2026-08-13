defmodule Noizu.Google.Test.SAFixture do
  @moduledoc false

  @doc "Generate an RSA PEM + service-account map (never a real Google key)."
  def creds(overrides \\ %{}) do
    pem = rsa_pem()

    Map.merge(
      %{
        "type" => "service_account",
        "project_id" => "test-project",
        "private_key_id" => "test-key-id",
        "private_key" => pem,
        "client_email" => "sa@test-project.iam.gserviceaccount.com",
        "client_id" => "1234567890",
        "token_uri" => "https://oauth2.googleapis.com/token"
      },
      overrides
    )
  end

  def write_temp!(overrides \\ %{}) do
    path = Path.join(System.tmp_dir!(), "noizu-google-sa-#{System.unique_integer([:positive])}.json")
    File.write!(path, Jason.encode!(creds(overrides)))
    path
  end

  def rsa_pem do
    rsa = :public_key.generate_key({:rsa, 2048, 65537})
    entry = :public_key.pem_entry_encode(:RSAPrivateKey, rsa)
    :public_key.pem_encode([entry])
  end
end
