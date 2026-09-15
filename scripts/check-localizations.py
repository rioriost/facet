#!/usr/bin/env python3
"""Validate source catalogs and, optionally, built iPhone/Watch bundles on macOS."""
import argparse
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
LANGUAGES = {'ja', 'en', 'zh-Hans', 'zh-Hant', 'ko', 'fr', 'de', 'es', 'es-419', 'pt-BR', 'pt-PT', 'it'}

def read(path):
    return json.loads(subprocess.check_output(['plutil', '-convert', 'json', '-o', '-', str(path)]))

def tables(folder, filename):
    paths = list(folder.glob(f'*.lproj/{filename}'))
    result = {p.parent.stem.lower(): read(p) for p in paths}
    assert set(result) == {s.lower() for s in LANGUAGES}, (folder, result.keys())
    return result

def check_resources(folder):
    catalogs = tables(folder, 'Localizable.strings')
    reference = catalogs['en']
    for language, values in catalogs.items():
        assert values.keys() == reference.keys(), language
        for key, value in values.items():
            assert value.strip(), (language, key)
            assert sorted(re.findall(r'%\d+\$@', value)) == sorted(re.findall(r'%\d+\$@', reference[key])), (language, key)
    return catalogs

def check_info(folder, watch=False):
    for language, values in tables(folder, 'InfoPlist.strings').items():
        assert values['CFBundleDisplayName'] == ('Facet' if watch else 'Facet – Contact QR')
        if watch:
            assert 'NSContactsUsageDescription' not in values
        else:
            assert values['NSContactsUsageDescription'].strip(), language

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--app', type=Path, help='Built Facet.app; also checks its embedded Watch app')
args = parser.parse_args()
catalogs = check_resources(ROOT / 'Sources/FacetCore/Resources')
used = set()
for folder in ['Sources', 'Apps']:
    for path in (ROOT / folder).rglob('*.swift'):
        used.update(re.findall(r'L10n\.text\("([^"]+)"\)', path.read_text()))
# The formatter calls text() within the L10n namespace.
used.add('field.labeled')
assert used == catalogs['en'].keys(), ('missing', used - catalogs['en'].keys(), 'unused', catalogs['en'].keys() - used)
check_info(ROOT / 'Apps/iOS/Resources')
check_info(ROOT / 'Apps/Watch/Resources', watch=True)
if args.app:
    for app, watch in [(args.app, False), (args.app / 'Watch/FacetWatch.app', True)]:
        check_info(app, watch)
        check_resources(app / 'FacetCore_FacetCore.bundle')
        info = read(app / 'Info.plist')
        assert info['CFBundleDevelopmentRegion'] == 'en'
        if watch:
            assert 'NSContactsUsageDescription' not in info
print(f'PASS: 12 localizations, {len(catalogs["en"])} UI strings, permission descriptions, format placeholders and source references' + ('; both built apps verified' if args.app else ''))
