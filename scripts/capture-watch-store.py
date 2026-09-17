#!/usr/bin/env python3
"""Capture the installed DEBUG Watch app on a disposable, booted simulator."""
import argparse
import pathlib
import shutil
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--device', required=True, help='Disposable Watch simulator UUID')
parser.add_argument('--fixture', required=True, type=pathlib.Path, help='Synthetic WatchCache JSON')
parser.add_argument('--output', required=True, type=pathlib.Path)
args = parser.parse_args()
bundle = 'st.rio.facet.watchkitapp'
locales = [('ja','ja_JP'),('en','en_US'),('zh-Hans','zh_CN'),('zh-Hant','zh_TW'),('ko','ko_KR'),('fr','fr_FR'),('de','de_DE'),('es','es_ES'),('es-419','es_MX'),('pt-BR','pt_BR'),('pt-PT','pt_PT'),('it','it_IT')]

def sim(*values, check=True):
    return subprocess.run(['xcrun', 'simctl', *values], check=check, capture_output=True, text=True)

sim('terminate', args.device, bundle, check=False)
container = pathlib.Path(sim('get_app_container', args.device, bundle, 'data').stdout.strip())
cache = container / 'Library/Application Support/Facet/watch.json'
cache.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(args.fixture, cache)
for language, locale in locales:
    folder = args.output / language
    folder.mkdir(parents=True, exist_ok=True)
    for index, profile in enumerate(['work', 'personal', 'combined', 'app-share'], 1):
        sim('terminate', args.device, bundle, check=False)
        sim('launch', args.device, bundle, '-AppleLanguages', f'({language})', '-AppleLocale', locale, '--screenshot-profile', profile)
        time.sleep(2)
        sim('io', args.device, 'screenshot', '--type=jpeg', str(folder / f'{index:02}-{profile}.jpg'))
    print(language, 'captured', flush=True)
