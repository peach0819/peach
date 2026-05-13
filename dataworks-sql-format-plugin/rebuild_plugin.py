#!/usr/bin/env python3
"""Rebuild dataworks-sql-format-plugin distribution ZIP.

Usage: python rebuild_plugin.py

Creates:
  build/libs/dataworks-sql-format-plugin-1.0.0.jar
  build/libs/instrumented-dataworks-sql-format-plugin-1.0.0.jar
  build/distributions/dataworks-sql-format-plugin-1.0.0.zip
"""

import os
import subprocess
import zipfile

BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, 'src', 'main', 'java')
RESOURCES = os.path.join(BASE, 'src', 'main', 'resources')
CLASSES = os.path.join(BASE, 'build', 'classes', 'java', 'main')
INSTRUMENTED = os.path.join(BASE, 'build', 'instrumented', 'instrumentCode')
LIBS = os.path.join(BASE, 'build', 'libs')
DIST = os.path.join(BASE, 'build', 'distributions')

PLUGIN_NAME = 'dataworks-sql-format-plugin'
PLUGIN_VERSION = '1.0.0'
JAR_NAME = f'{PLUGIN_NAME}-{PLUGIN_VERSION}.jar'
INSTRUMENTED_JAR_NAME = f'instrumented-{JAR_NAME}'
ZIP_NAME = f'{PLUGIN_NAME}-{PLUGIN_VERSION}.zip'


def run(cmd, cwd=BASE):
    cmd_str = ' '.join(cmd)
    print(f'  -> {cmd_str}')
    subprocess.run(cmd, cwd=cwd, check=True)


def build():
    print('=== 1. Compile ===')
    os.makedirs(CLASSES, exist_ok=True)
    # Only compile engine package (action package depends on IntelliJ SDK)
    engine_src = os.path.join(SRC, 'com', 'peach', 'sqlformat', 'engine')
    javac_files = []
    for root, dirs, files in os.walk(engine_src):
        for f in files:
            if f.endswith('.java'):
                javac_files.append(os.path.join(root, f))
    run(['javac', '-encoding', 'UTF-8', '-d', CLASSES] + javac_files)

    print()
    print('=== 2. Copy to instrumentCode ===')
    os.makedirs(INSTRUMENTED, exist_ok=True)
    # Remove old content then copy
    for entry in os.listdir(INSTRUMENTED):
        path = os.path.join(INSTRUMENTED, entry)
        if os.path.isdir(path):
            subprocess.run(['rm', '-rf', path], check=True)
        else:
            os.remove(path)
    subprocess.run(['cp', '-r', os.path.join(CLASSES, 'com'), os.path.join(INSTRUMENTED, 'com')], check=True)

    print()
    print('=== 3. Build JARs ===')
    os.makedirs(LIBS, exist_ok=True)

    # Regular JAR
    jar_path = os.path.join(LIBS, JAR_NAME)
    run(['jar', 'cf', jar_path,
         '-C', CLASSES, '.',
         '-C', RESOURCES, 'META-INF/plugin.xml',
         '-C', RESOURCES, 'com/peach/sqlformat/SQL_FORMAT_RULES.md'])

    # Instrumented JAR
    instr_jar_path = os.path.join(LIBS, INSTRUMENTED_JAR_NAME)
    run(['jar', 'cf', instr_jar_path,
         '-C', INSTRUMENTED, '.',
         '-C', RESOURCES, 'META-INF/plugin.xml',
         '-C', RESOURCES, 'com/peach/sqlformat/SQL_FORMAT_RULES.md'])

    print()
    print('=== 4. Build ZIP ===')
    os.makedirs(DIST, exist_ok=True)
    zip_path = os.path.join(DIST, ZIP_NAME)

    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        # JAR inside lib/
        zf.write(instr_jar_path,
                 f'{PLUGIN_NAME}/lib/{INSTRUMENTED_JAR_NAME}')
        # Also copy META-INF/plugin.xml for safety
        zf.write(os.path.join(RESOURCES, 'META-INF', 'plugin.xml'),
                 f'{PLUGIN_NAME}/META-INF/plugin.xml')

    print(f'  Created: {zip_path}')
    with zipfile.ZipFile(zip_path, 'r') as zf:
        for info in zf.infolist():
            print(f'    {info.filename} ({info.file_size} bytes)')

    print()
    print('=== DONE ===')
    print(f'Plugin ZIP: {zip_path}')
    print(f'Instrumented JAR: {instr_jar_path}')


if __name__ == '__main__':
    build()
