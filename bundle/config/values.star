load("@ytt:data", "data")
load("@ytt:assert", "assert")

data.values.repository or assert.fail("missing repository")
