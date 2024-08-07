starkbank_project = Application.get_env(:starkbank, :project, [])
starkbank_language = Application.get_env(:starkbank, :language, [])
starkbank_organization = Application.get_env(:starkbank, :organization, [])

if (starkbank_project != []) do
  Application.put_env(:starkcore, :project, starkbank_project)
end

if (starkbank_language != []) do
  Application.put_env(:starkcore, :language, starkbank_language)
end

if (starkbank_organization != []) do
  Application.put_env(:starkcore, :organization, starkbank_organization)
end
