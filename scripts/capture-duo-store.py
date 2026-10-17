#!/usr/bin/env python3
"""Run the inner-display screenshot test and capture native Duo pixels.

Open the dedicated Duo simulator in Device Hub first. Supply its UUID and a new
output directory. XCTest screenshots round the inner display by one pixel;
simctl captures the actual 2853 x 2007 display without resizing.
"""
import argparse
import os
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('device')
parser.add_argument('output', type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
env = dict(os.environ, TEST_RUNNER_FACET_NATIVE_CAPTURE='1')
command = ['xcodebuild', '-project', 'Facet.xcodeproj', '-scheme', 'FacetStoreScreenshots',
           '-destination', f'platform=iOS Simulator,id={args.device}',
           '-derivedDataPath', str(args.output.parent / 'DerivedData'),
           '-resultBundlePath', str(args.output / 'capture.xcresult'),
           '-parallel-testing-enabled', 'NO',
           '-only-testing:FacetUITests/FacetStoreScreenshotTests/testCaptureLocalizedDuoInnerScreenshots',
           'CODE_SIGNING_ALLOWED=NO', 'test']
count = 0
with (args.output / 'capture.log').open('w') as log:
    process = subprocess.Popen(command, env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True, bufsize=1)
    for line in process.stdout:
        log.write(line)
        log.flush()
        if line.startswith('FACET_DUO_CAPTURE '):
            _, name, acknowledgment = line.strip().split(' ', 2)
            locale, filename = name.split('__')
            target = args.output / 'screenshots' / locale / (filename + '.png')
            target.parent.mkdir(parents=True, exist_ok=True)
            subprocess.run(['xcrun', 'simctl', 'io', args.device, 'screenshot',
                            '--display=3', str(target)], check=True, stdout=subprocess.DEVNULL)
            Path(acknowledgment).touch()
            count += 1
            print(f'Captured {name}', flush=True)
    result = process.wait()
if result or count != 24:
    raise SystemExit(f'Capture failed: xcodebuild={result}, images={count}/24')
print('Captured all 24 native inner-display screenshots')
