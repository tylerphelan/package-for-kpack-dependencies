load("@ytt:data", "data")
load("@ytt:assert", "assert")

data.values.repository or assert.fail("missing repository")
# extract the docker registry from the repository string
parts = data.values.repository.split("/", 1)
if len(parts) == 1:
	assert.fail("repository must be a valid writeable repository and must include a '/'")
end