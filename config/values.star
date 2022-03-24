load("@ytt:data", "data")
load("@ytt:assert", "assert")
load("@ytt:json", "json")
load("@ytt:base64", "base64")

data.values.repository or assert.fail("missing repository")
registry_host = ""
# extract the docker registry from the repository string
parts = data.values.repository.split("/", 1)
if len(parts) == 2:
    if ('.' in parts[0] or ':' in parts[0]) and parts[0] != "index.docker.io":
        registry_host = parts[0]
    else:
        registry_host = "https://index.docker.io/v1/"
    end
if len(parts) == 1:
	assert.fail("repository must be a valid writeable repository and must include a '/'")
end

secret_name = kpack-dependency-secret
if (data.values.repository.username and data.values.repository.password) and (data.values.repository_secret.name and data.values.repository_secret.namespace):
    assert.fail("can only use one of repository_secret or repository_username/password"
end

empty_json_base64 = "e30="
docker_configjson = empty_json_base64

if data.values.repository_secret.name:
    secret_name = data.values.repository_secret.name
else:
    data.values.repos_username or assert.fail("missing repository_username")
    data.values.repos_password or assert.fail("missing repository_password")

    docker_auth = base64.encode("{}:{}".format(data.values.repos_username, data.values.repos_password))
    docker_creds = {"username": data.values.repos_username, "password": data.values.repos_password, "auth": docker_auth}
    docker_configjson = base64.encode(json.encode({"auths": {registry_host: docker_creds}}))
end

if not (data.values.repository.username and data.values.repository.password) and not (data.values.repository_secret.name and data.values.repository_secret.namespace):
    assert.fail("require repository_secret or repository_username/password"
end
