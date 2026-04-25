# Contributing to misp-event-templates

Thank you for considering a contribution. This repo is the place to
add or refine event templates for incident-response playbooks
people deal with often. The bar for inclusion is "a template several
SOC teams could plausibly want." Niche or org-specific shapes are
better authored locally on the operator's MISP instance and not
shipped here.

## Quick start

```bash
git clone git@github.com:MISP/misp-event-templates.git
cd misp-event-templates

# 1. copy an existing template as a starting point
cp -r templates/spearphishing-email templates/<your-name>

# 2. edit templates/<your-name>/definition.json
#    - change uuid (uuidgen)
#    - change name + description
#    - re-shape the structure for your incident type

# 3. canonicalise the JSON
./jq_all_the_things.sh

# 4. validate locally
./validate_all.sh

# 5. open a PR
git checkout -b new-template/<your-name>
git add templates/<your-name>/
git commit -m "add: [<your-name>] Description of the template"
git push -u origin new-template/<your-name>
```

CI runs `validate_all.sh` on every PR. PRs that fail validation
will be flagged automatically; please re-run locally and push the
fix.

## Authoring conventions

### File layout

Each template lives in its own directory under `templates/`. The
directory name is the template's slug (lowercase, hyphenated).

```
templates/
└── <slug>/
    └── definition.json
```

Per-template extras (an example filled event, a screenshot, a
template-specific README) are welcome inside the same directory but
are not required.

### `definition.json` shape

A `definition.json` is a JSON document conforming to
`schema_event_template.json`. Every shipped template carries:

- `"default": true` — opts the template into MISP's library
  auto-update flow on operator instances.
- `"library_metadata"` — at minimum `authors` and `tags`. The
  `compatible_misp_version` field is recommended; the loader uses
  it to refuse incompatible templates.
- `"schema_version": 1`.
- A fresh `"uuid"` — generate with `uuidgen` or `python -c
  'import uuid; print(uuid.uuid4())'`. Never reuse a uuid from
  another template.
- A clear `"name"` and `"description"` — these render in MISP's
  picker, so make them informative for someone scanning a long list.

### Labels and help text

This is the most important convention. Every interactive element in
the `structure` array (attribute fields, object fields, tag fields,
galaxy fields, file fields, sections) carries a creator-authored
**label** and an optional **help text**.

- The label is what the template user sees as the field's name
  on the form. Plain text. Mandatory. Make it specific (`Sender
  email — From: header` rather than `email-src`).
- The help text is shown beneath the field. Markdown. Optional but
  strongly encouraged. Tell the user *what to put in and why*
  rather than just naming the field. The help text is what
  separates a useful template from one that may as well be a
  blank event.
- For `object_field` elements, override per-relation labels and
  help text where MISP's built-in object-template description is
  too terse for a non-expert template user.

If your template has lots of fields without help text, please
revisit before merging — fields without help text are why the
legacy templates system has the reputation it does.

### Names, uuids, and uniqueness

`validate_all.sh` checks that every template has a unique uuid and
a unique name across the catalogue. If your slug or name overlaps
an existing template, pick a more specific one.

### Element ids

Every `attribute_field`, `object_field`, `tag_field`, `galaxy_field`,
`file_field`, `section`, and `text_block` carries a stable `id` you
assign. Ids are used by `info_template` variable substitution
(`{{field:<id>}}`) and by `object_reference` endpoints. Pick
human-readable, descriptive ids (`sender`, `obj_email`, `tlp`)
rather than generic ones (`field1`, `obj1`). Ids must be unique
within a template and must match the regex `^[a-zA-Z_][a-zA-Z0-9_]*$`.

### Tags, galaxies, and object references

- For `tag_field` elements, restrict to the most specific
  taxonomy / taxonomies that make sense (e.g. `["tlp"]` rather
  than leaving it open to every taxonomy on the instance).
- For `galaxy_field` elements, similarly restrict to relevant
  galaxy types (e.g. `["threat-actor"]`).
- For `object_reference` elements, the source and target ids must
  refer to existing `object_field` elements in the same template.

## Local validation

```bash
./jq_all_the_things.sh   # canonicalise every JSON file (sort keys, fix indent)
./validate_all.sh        # run schema validation + uuid uniqueness + sanity checks
```

Run both before opening a PR. CI runs the same scripts.

### Dependencies

- `jq` — JSON processor.
- `python3` plus the `jsonschema` package
  (`pip install jsonschema`).
- `moreutils` for `sponge` (used by the canonicalisation script).
- `uuid-runtime` for `uuidparse` (used by validation).

On Debian/Ubuntu: `sudo apt install jq moreutils uuid-runtime python3-pip`.

## Commit message style

Loosely follows MISP's `gitchangelog` convention, same as
[misp-objects](https://github.com/MISP/misp-objects/commits/main):

```
add: [<slug>] Short description           # new template
fix: [<slug>] Short description           # bugfix on an existing template
chg: [<area>] Short description           # tooling, schema, infra
```

Examples:
- `add: [spearphishing-email] Initial template`
- `fix: [ransomware-incident] Correct attribute category for ransom-note`
- `chg: [tooling] Tighten validate_all.sh exit handling`

## Review checklist

Before requesting review on a PR, please confirm:

- [ ] `./jq_all_the_things.sh` was run; the diff stays clean.
- [ ] `./validate_all.sh` exits 0.
- [ ] The template's `uuid` is freshly generated and unique.
- [ ] Every interactive element has a non-empty `label`; the
      template user-facing fields have help text where it adds
      value.
- [ ] `library_metadata.authors` is filled in.
- [ ] The template is genuinely community-relevant (not a
      one-off for a specific organisation's pipeline).
- [ ] If the template references MISP object templates, those
      object templates exist in
      [misp-objects](https://github.com/MISP/misp-objects) at
      the pinned version.

## License

By contributing, you agree your contribution is licensed under
[MIT](LICENSE), the same license as the rest of the repository.
