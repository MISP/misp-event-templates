#!/bin/bash
#
# Run the full pre-PR validation suite:
#  1. canonicalise every JSON via jq_all_the_things.sh and refuse to
#     proceed if that produced any diffs (you forgot to commit
#     canonicalisation)
#  2. ensure no JSON file has the executable flag set
#  3. run JSON-schema validation per template/<slug>/definition.json
#  4. confirm uuids are unique across templates/
#
# Same shape as misp-objects/validate_all.sh. CI runs this on every PR.
#
# Requires: jq, sponge (moreutils), python3 with jsonschema, uuidparse
# (uuid-runtime).

# Check Jsons format, and beautify
./jq_all_the_things.sh
rc=$?
if [[ ${rc} != 0 ]]; then
    exit ${rc}
fi

set -e
set -x

diffs=$(git status --porcelain | wc -l)
if ! [ "${diffs}" -eq 0 ]; then
    echo "ERROR: Please commit your changes, and make sure you run ./jq_all_the_things.sh before committing."
    if [ $# -eq 0 ]; then
        exit 1
    fi
fi

# Remove the exec flag on every JSON so PRs don't smuggle in 0755.
find . -name "*.json" -not -path "./.git/*" -exec chmod -x "{}" \;

diffs=$(git status --porcelain | wc -l)
if ! [ "${diffs}" -eq 0 ]; then
    echo 'ERROR: Please make sure JSON files are not executable before committing: find -name "*.json" -exec chmod -x "{}" \;'
    exit 1
fi

# Validate every template definition against the schema.
for dir in templates/*/definition.json; do
    [ -e "${dir}" ] || continue
    echo -n "${dir}: "
    jsonschema -i "${dir}" schema_event_template.json
    echo ''
done

# UUIDs must be unique across the catalogue.
./unique_uuid.py

# Quick sanity-check on uuid format (catches typos that are valid
# JSON but not valid uuids).
for dir in templates/*/definition.json; do
    [ -e "${dir}" ] || continue
    cat "${dir}" | jq -r .uuid | uuidparse > /dev/null
done

echo "Success: All is fine, please go ahead."
