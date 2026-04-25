#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Verify every templates/<slug>/definition.json carries a unique uuid
and a unique name. Run by validate_all.sh on every PR.

Same shape as misp-objects/unique_uuid.py.
"""

from glob import glob
import json
import sys
from typing import Dict


def main() -> int:
    seen_uuid: Dict[str, str] = {}
    seen_name: Dict[str, str] = {}

    for definition in sorted(glob('./templates/*/definition.json')):
        with open(definition, 'r', encoding='utf-8') as f:
            d = json.load(f)

        uuid = d.get('uuid')
        name = d.get('name')

        if not uuid:
            print(f'ERROR: {definition} has no uuid', file=sys.stderr)
            return 1
        if not name:
            print(f'ERROR: {definition} has no name', file=sys.stderr)
            return 1

        if uuid in seen_uuid:
            print(
                f'ERROR: duplicate uuid {uuid} in {definition} and '
                f'{seen_uuid[uuid]}',
                file=sys.stderr,
            )
            return 1
        if name in seen_name:
            print(
                f'ERROR: duplicate name "{name}" in {definition} and '
                f'{seen_name[name]}',
                file=sys.stderr,
            )
            return 1

        seen_uuid[uuid] = definition
        seen_name[name] = definition

    print(f'OK: {len(seen_uuid)} template(s), all uuids and names unique.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
