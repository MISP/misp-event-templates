# misp-event-templates

A community-maintained, versioned library of event templates for the
[MISP](https://www.misp-project.org/) threat-intelligence sharing
platform.

Event templates encode common incident-response playbooks
(spearphishing triage, ransomware response, credential exposure, …)
as reusable JSON documents. Operators pull this library into their
MISP instance via the `Update from library` flow, then enable the
templates that fit their team's workflow. Template users land on a
single-page form pre-shaped for the incident type and produce a
consistent event without having to navigate the full MISP type tree.

This repository follows the same shape as
[misp-objects](https://github.com/MISP/misp-objects),
[misp-galaxy](https://github.com/MISP/misp-galaxy), and
[misp-taxonomies](https://github.com/MISP/misp-taxonomies):

- per-template directory under `templates/`,
- a JSON schema (`schema_event_template.json`) that every
  `definition.json` validates against,
- canonicalisation (`jq_all_the_things.sh`) and validation
  (`validate_all.sh`) scripts you run before sending a PR,
- CI runs the same validation on every PR.

Anyone can contribute a template. See [CONTRIBUTE.md](CONTRIBUTE.md).

## Repository layout

```
.
├── README.md
├── CONTRIBUTE.md
├── LICENSE
├── schema_event_template.json
├── templates/
│   ├── spearphishing-email/
│   │   └── definition.json
│   └── ...
├── jq_all_the_things.sh
├── validate_all.sh
└── unique_uuid.py
```

Each template lives in its own directory under `templates/` so the
folder can later carry per-template extras (an example event,
screenshots, a per-template README) without changing the layout.

## Templates included

| Slug | Use case |
|---|---|
| `spearphishing-email` | Inbound email reported as suspicious — credential phishing, malware delivery, BEC. Email + attachment objects. |
| `ransomware-incident` | Ongoing ransomware response — family / variant, affected scope, network indicators, sample hashes, ransom note. |
| `credential-exposure` | Paste-site dumps, breach marketplace listings, OSINT tips, HIBP-style notifications. |
| `suspicious-domain-triage` | First-pass triage on a flagged domain — WHOIS + DNS resolution objects + observed URLs. |
| `malware-sample-submission` | Analyst-with-the-binary submission — full hash set + AV labels + sandbox C2 indicators. |
| `vulnerability-disclosure` | Tracking a vulnerability relevant to the org using CVE/GCVE/GHSA/advisory IDs — fresh disclosure, 0-day rumour, in-the-wild exploitation. |
| `supply-chain-compromise` | Backdoored npm/PyPI/cargo package, compromised Docker image, malicious GitHub Action. |

PRs to add new templates are welcome — see [CONTRIBUTE.md](CONTRIBUTE.md).
The bar for inclusion is "a template several SOC teams could plausibly want."

## Format of an event template

A `definition.json` is a JSON document conforming to
`schema_event_template.json`. The schema is a superset of MISP core's
`event-template-v1.schema.json` plus two library-specific top-level
fields: `misp_default` (boolean — marks the template as library-managed
so MISP will auto-update it) and `library_metadata` (informational
fields like `compatible_misp_version`, `authors`, `tags`).

A condensed example:

```jsonc
{
  "misp_default": true,
  "library_metadata": {
    "compatible_misp_version": "2.5.0",
    "authors": [
      {"name": "MISP Project", "contact": "info@misp-project.org"}
    ],
    "tags": ["incident-response", "email", "phishing"]
  },
  "schema_version": 1,
  "uuid": "9a59a4f2-7e22-4c6c-a8a8-c8bec8c1a5f9",
  "name": "Spearphishing email triage",
  "description": "Extract IOCs from a flagged email, structured for downstream detection.",
  "event_defaults": {
    "info_template": "Spearphishing — {{date}} — {{field:sender}}",
    "distribution": 1,
    "threat_level_id": 2,
    "analysis": 0,
    "tags": [{"name": "tlp:amber", "locked": true}]
  },
  "structure": [
    {
      "type": "section",
      "id": "s_headers",
      "label": "Email headers",
      "help": "Data visible in the raw email headers."
    },
    {
      "type": "attribute_field",
      "id": "sender",
      "parent": "s_headers",
      "label": "Sender email",
      "help": "The From: header.",
      "mandatory": true,
      "misp": {
        "category": "Payload delivery",
        "type": "email-src"
      }
    }
  ]
}
```

The full element-type vocabulary
(`section`, `text_block`, `attribute_field`, `object_field`,
`object_reference`, `tag_field`, `galaxy_field`, `file_field`)
and event-defaults are documented in MISP core's
[event-templating PRD §7](https://github.com/MISP/MISP/blob/templating/docs/dev/event-templating-prd.md).

## How operators consume this library

1. MISP core ships with this repo registered as a git submodule at
   `app/files/misp-event-templates/`.
2. After `git pull` + `git submodule update`, a site admin clicks
   **Update from library** on the event-templates index. The loader
   walks every `templates/*/definition.json`, validates it, and
   upserts by uuid. New templates are installed; existing
   library-managed (`misp_default = 1`) templates are upgraded; rows
   the operator has explicitly forked (`misp_default = 0`) are
   skipped.
3. Library imports default to `active = 0` and `distribution = 1`
   (community). The site admin enables the ones the team wants.

For the full operator-side flow including the upgrade semantics,
see MISP core's
[event-template library admin docs](https://github.com/MISP/MISP/blob/templating/docs/event-template-library-admin.md)
(populated when MISP core's Phase 5 lands).

## Independent use

The JSON documents are usable outside MISP. Any tool that can parse
the schema can render the form, validate user input against
attribute / object semantics, or convert filled values to its own
event model. Schemas and tooling are MIT-licensed; templates
themselves are also MIT.

## Contributing

PRs welcome. See [CONTRIBUTE.md](CONTRIBUTE.md) for the authoring
workflow, JSON conventions, and the local validation steps.

## License

MIT — see [LICENSE](LICENSE).
