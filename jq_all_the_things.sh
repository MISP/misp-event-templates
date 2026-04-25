#!/bin/bash
#
# Canonicalises every JSON document in the repository:
#  - templates/<slug>/definition.json
#  - schema_event_template.json
#
# Sorts keys, normalises indent. Run before opening a PR; CI rejects
# non-canonical JSON.
#
# Same shape as the equivalent script in misp-objects / misp-galaxy.
# Requires: jq, sponge (moreutils).

# First, confirm every JSON parses.
for f in $(find . -name "*.json" -not -path "./.git/*"); do
    echo "validating ${f}"
    cat "${f}" | jq . > /dev/null
    rc=$?
    if [[ ${rc} != 0 ]]; then
        exit ${rc}
    fi
done

set -e
set -x

# Canonicalise every template definition.
for f in templates/*/definition.json; do
    [ -e "${f}" ] || continue
    cat "${f}" | jq -S . | sponge "${f}"
done

# Canonicalise the schema.
cat schema_event_template.json | jq . | sponge schema_event_template.json
