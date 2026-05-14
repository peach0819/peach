#!/usr/bin/env python3
"""Build the SQL Format Desktop Application.

Creates:
  build/desktop/SqlFormat.exe  (Windows executable)
  build/desktop/sql-format.bat (batch launcher, fallback)

Requirements:
  - JDK 8+ (JAVA_HOME or javac/java on PATH)
  - .NET Framework (for csc.exe to create EXE) — optional, falls back to .bat
"""

import os
import subprocess
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, 'src', 'main', 'java')
CLASSES = os.path.join(BASE, 'build', 'classes', 'desktop')
DIST = os.path.join(BASE, 'build', 'desktop')

# Engine + GUI source packages
ENGINE_PKG = os.path.join(SRC, 'com', 'peach', 'sqlformat', 'engine')
GUI_PKG = os.path.join(SRC, 'com', 'peach', 'sqlformat', 'gui')

JAR_NAME = 'sql-format-app.jar'
EXE_NAME = 'SqlFormat.exe'
BAT_NAME = 'sql-format.bat'


def run(cmd, cwd=BASE):
    cmd_str = ' '.join(cmd) if isinstance(cmd, list) else cmd
    print(f'  -> {cmd_str}')
    subprocess.run(cmd, cwd=cwd, check=True)


def find_jdk():
    """Find javac and java executables."""
    # Check JAVA_HOME first
    java_home = os.environ.get('JAVA_HOME')
    if java_home:
        javac = os.path.join(java_home, 'bin', 'javac.exe')
        java = os.path.join(java_home, 'bin', 'java.exe')
        if os.path.exists(javac) and os.path.exists(java):
            return javac, java

    # Try PATH
    for cmd in ['javac', 'javac.exe']:
        try:
            result = subprocess.run(['where', cmd], capture_output=True, text=True)
            if result.returncode == 0:
                javac_path = result.stdout.strip().split('\n')[0].strip()
                java_path = javac_path.replace('javac.exe', 'java.exe').replace('javac', 'java.exe')
                if os.path.exists(java_path):
                    return javac_path, java_path
        except FileNotFoundError:
            pass

    return None, None


def find_csc():
    """Find the C# compiler (csc.exe) from .NET Framework."""
    # Common paths for csc.exe
    csc_paths = [
        r'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe',
        r'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe',
        r'C:\Windows\Microsoft.NET\Framework64\v3.5\csc.exe',
        r'C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe',
    ]
    for path in csc_paths:
        if os.path.exists(path):
            return path
    return None


def compile_java(javac):
    """Compile Java classes for desktop application."""
    print('=== 1. Compile Java classes ===')
    os.makedirs(CLASSES, exist_ok=True)

    java_files = []
    for pkg_dir in [ENGINE_PKG, GUI_PKG]:
        for root, dirs, files in os.walk(pkg_dir):
            for f in files:
                if f.endswith('.java'):
                    java_files.append(os.path.join(root, f))

    run([javac, '-encoding', 'UTF-8', '-d', CLASSES] + java_files)
    print(f'  Compiled {len(java_files)} source files to {CLASSES}')
    print()


def create_jar(java):
    """Create a runnable JAR with manifest."""
    print('=== 2. Create runnable JAR ===')
    os.makedirs(DIST, exist_ok=True)

    # Create manifest
    manifest_dir = os.path.join(BASE, 'build', 'manifest')
    os.makedirs(manifest_dir, exist_ok=True)
    manifest_file = os.path.join(manifest_dir, 'MANIFEST.MF')
    with open(manifest_file, 'w') as f:
        f.write('Manifest-Version: 1.0\n')
        f.write('Main-Class: com.peach.sqlformat.gui.SqlFormatGui\n')
        f.write('\n')

    jar_path = os.path.join(DIST, JAR_NAME)
    run(['jar', 'cfm', jar_path, manifest_file, '-C', CLASSES, '.'])
    print(f'  Created: {jar_path}')
    print()


def create_bat():
    """Create a batch file launcher."""
    print('=== 3. Create batch launcher ===')
    bat_path = os.path.join(DIST, BAT_NAME)
    jarname = JAR_NAME
    content = '''@echo off
setlocal enabledelayedexpansion

:: Find the directory where this script is located
set "SCRIPT_DIR=%~dp0"

:: Try java from PATH
where java >nul 2>nul
if !ERRORLEVEL! == 0 (
    java -jar "%SCRIPT_DIR%%s" %*
    goto :eof
)

:: Try JAVA_HOME
if not "%JAVA_HOME%" == "" (
    if exist "%JAVA_HOME%\\bin\\java.exe" (
        "%JAVA_HOME%\\bin\\java.exe" -jar "%SCRIPT_DIR%%s" %*
        goto :eof
    )
)

:: Try Program Files
if exist "C:\\Program Files\\Java\\jre1.8.0_202\\bin\\java.exe" (
    "C:\\Program Files\\Java\\jre1.8.0_202\\bin\\java.exe" -jar "%SCRIPT_DIR%%s" %*
    goto :eof
)

:: Java not found
echo [ERROR] Java is not installed or not found on PATH.
echo Please install Java 8 or later from https://www.java.com/download/
echo.
pause
exit /b 1
'''.replace('%s', jarname)

    with open(bat_path, 'w', newline='\r\n') as f:
        f.write(content)
    print(f'  Created: {bat_path}')
    print()


def create_exe_with_csharp():
    """Create a Windows EXE using C# compiler (csc.exe)."""
    print('=== 4. Create Windows EXE ===')

    csc = find_csc()
    if not csc:
        print('  [SKIP] C# compiler (csc.exe) not found. Using batch file as fallback.')
        return False

    cs_source = os.path.join(DIST, 'Launcher.cs')
    exe_path = os.path.join(DIST, EXE_NAME)
    jarname = JAR_NAME

    cs_code = '''using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

namespace SqlFormatLauncher
{
    class Program
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        static extern int MessageBox(IntPtr hWnd, string text, string caption, uint type);

        static void Main()
        {
            string appDir = AppDomain.CurrentDomain.BaseDirectory;
            string jarPath = Path.Combine(appDir, "{JAR_NAME}");

            if (!File.Exists(jarPath))
            {
                MessageBox(IntPtr.Zero,
                    "Cannot find " + jarPath,
                    "Error", 0x00000010);
                return;
            }

            string javaExe = FindJava();
            if (javaExe == null)
            {
                MessageBox(IntPtr.Zero,
                    "Java is not installed. Please install Java 8 or later.",
                    "Java Not Found", 0x00000010);
                return;
            }

            try
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = javaExe;
                psi.Arguments = "-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -jar \\"" + jarPath + "\\"";
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                using (Process process = Process.Start(psi))
                {
                    // Don't wait for idle — Java's initial window may not signal idle state
                }
            }
            catch (Exception ex)
            {
                MessageBox(IntPtr.Zero,
                    "Failed to launch application:\\n" + ex.Message,
                    "Error", 0x00000010);
            }
        }

        static string FindJava()
        {
            try
            {
                var psi = new ProcessStartInfo("where", "java");
                psi.RedirectStandardOutput = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                using (var p = Process.Start(psi))
                {
                    string output = p.StandardOutput.ReadToEnd();
                    p.WaitForExit();
                    if (p.ExitCode == 0)
                    {
                        string path = output.Trim().Split(new[] { '\\r', '\\n' }, StringSplitOptions.RemoveEmptyEntries)[0];
                        if (File.Exists(path)) return path;
                    }
                }
            } catch { }

            string javaHome = Environment.GetEnvironmentVariable("JAVA_HOME");
            if (!string.IsNullOrEmpty(javaHome))
            {
                string path = Path.Combine(javaHome, "bin", "java.exe");
                if (File.Exists(path)) return path;
            }

            string[] commonPaths = new[]
            {
                @"C:\\Program Files\\Java\\jre1.8.0_202\\bin\\java.exe",
                @"C:\\Program Files\\Java\\jdk1.8.0_202\\bin\\java.exe",
                @"C:\\Program Files (x86)\\Java\\jre1.8.0_202\\bin\\java.exe",
                @"C:\\Program Files\\Java\\jre\\bin\\java.exe",
            };
            foreach (string path in commonPaths)
            {
                if (File.Exists(path)) return path;
            }

            return null;
        }
    }
}
'''.replace('{JAR_NAME}', jarname)

    with open(cs_source, 'w', encoding='utf-8') as f:
        f.write(cs_code)

    # Compile with csc.exe (target: winexe for no console window)
    run([csc, '/target:winexe', '/platform:anycpu',
         '/optimize+',
         '/out:' + exe_path,
         cs_source])
    print(f'  Created: {exe_path}')
    print()
    return True


def create_exe_native():
    """Fallback: create a simple C compiled executable using available tools."""
    # Try to find Mingw-w64 gcc
    try:
        result = subprocess.run(['where', 'gcc'], capture_output=True, text=True)
        if result.returncode != 0:
            return False
    except FileNotFoundError:
        return False

    print('  Found gcc, creating native EXE...')
    c_source = os.path.join(DIST, 'launcher.c')
    exe_path = os.path.join(DIST, EXE_NAME)
    jar_relpath = JAR_NAME

    c_code = '''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

int main() {
    char jarPath[MAX_PATH];
    char javaCmd[MAX_PATH + 200];
    char modulePath[MAX_PATH];

    // Get the directory of the executable
    GetModuleFileName(NULL, modulePath, MAX_PATH);
    char* lastSlash = strrchr(modulePath, '\\\\');
    if (lastSlash) {
        *lastSlash = '\\0';
    }

    snprintf(jarPath, sizeof(jarPath), "%s\\\\%s", modulePath, "%s");

    // Try to find java.exe
    char javaExe[MAX_PATH] = {0};

    // Check PATH
    char* pathEnv = getenv("PATH");
    if (pathEnv) {
        char* pathCopy = _strdup(pathEnv);
        char* dir = strtok(pathCopy, ";");
        while (dir) {
            snprintf(javaExe, sizeof(javaExe), "%s\\\\java.exe", dir);
            if (GetFileAttributes(javaExe) != INVALID_FILE_ATTRIBUTES) {
                break;
            }
            javaExe[0] = '\\0';
            dir = strtok(NULL, ";");
        }
        free(pathCopy);
    }

    // Check JAVA_HOME
    if (javaExe[0] == '\\0') {
        char* javaHome = getenv("JAVA_HOME");
        if (javaHome) {
            snprintf(javaExe, sizeof(javaExe), "%s\\\\bin\\\\java.exe", javaHome);
            if (GetFileAttributes(javaExe) == INVALID_FILE_ATTRIBUTES) {
                javaExe[0] = '\\0';
            }
        }
    }

    // Check common install paths
    if (javaExe[0] == '\\0') {
        const char* commonPaths[] = {
            "C:\\\\Program Files\\\\Java\\\\jre1.8.0_202\\\\bin\\\\java.exe",
            "C:\\\\Program Files\\\\Java\\\\jdk1.8.0_202\\\\bin\\\\java.exe",
        };
        for (int i = 0; i < 2; i++) {
            if (GetFileAttributes(commonPaths[i]) != INVALID_FILE_ATTRIBUTES) {
                strcpy(javaExe, commonPaths[i]);
                break;
            }
        }
    }

    if (javaExe[0] == '\\0') {
        MessageBox(NULL, "Java is not installed. Please install Java 8 or later.",
                   "Java Not Found", MB_OK | MB_ICONERROR);
        return 1;
    }

    snprintf(javaCmd, sizeof(javaCmd), "\\"%s\\" -jar \\"%s\\"", javaExe, jarPath);

    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;

    if (CreateProcess(NULL, javaCmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    } else {
        char errMsg[500];
        snprintf(errMsg, sizeof(errMsg), "Failed to launch application. Error code: %lu", GetLastError());
        MessageBox(NULL, errMsg, "Error", MB_OK | MB_ICONERROR);
        return 1;
    }

    return 0;
}
'''.replace('%s', jar_relpath)

    with open(c_source, 'w') as f:
        f.write(c_code)

    run(['gcc', '-O2', '-s', '-mwindows', '-o', exe_path, c_source])
    print(f'  Created native EXE: {exe_path}')
    print()
    return True


def build():
    javac, java = find_jdk()
    if not javac:
        print('ERROR: javac not found. Set JAVA_HOME or add JDK to PATH.')
        sys.exit(1)

    print(f'Using javac: {javac}')
    print(f'Using java:  {java}')
    print()

    compile_java(javac)
    create_jar(java)
    create_bat()

    # Try C# compiler first, then gcc, then fallback
    created_exe = create_exe_with_csharp()
    if not created_exe:
        created_exe = create_exe_native()

    print('=== DONE ===')
    print(f'Output directory: {DIST}')
    print(f'  JAR: {JAR_NAME}')
    print(f'  EXE: {EXE_NAME if created_exe else "(not created, using .bat fallback)"}')
    print(f'  BAT: {BAT_NAME}')
    print()


if __name__ == '__main__':
    build()
