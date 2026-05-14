#!/usr/bin/env python3
"""Build a self-contained SQL Format Desktop distribution with bundled JRE.

Creates:
  build/dist/SqlFormat-1.0.0/
    SqlFormat.exe     (Windows EXE launcher)
    sql-format-app.jar
    jre/              (bundled Java Runtime Environment)
  build/dist/SqlFormat-1.0.0.zip  (for distribution)

Usage: python build_dist.py

The resulting folder can be copied to any Windows machine (no Java required).
"""

import os
import subprocess
import sys
import shutil
import zipfile

BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, 'src', 'main', 'java')
CLASSES = os.path.join(BASE, 'build', 'classes', 'desktop')
BUILD_DESKTOP = os.path.join(BASE, 'build', 'desktop')
DIST_DIR = os.path.join(BASE, 'build', 'dist', 'SqlFormat-1.0.0')

JAR_NAME = 'sql-format-app.jar'
EXE_NAME = 'SqlFormat.exe'

# JRE source (bundled with the JDK on this machine)
JRE_SOURCE = r'C:\Program Files\Java\jre1.8.0_202'

# Files to strip from the bundled JRE (unnecessary for a desktop Swing app)
JRE_STRIP_DIRS = [
    'bin\\javafx',
    'bin\\javafx.dll',
    'bin\\fxplugins.dll',
    'bin\\glass.dll',
    'bin\\prism_*',
    'bin\\decora*',
    'bin\\javaw.exe',  # keep javaw.exe only
]

JRE_STRIP_FILES = [
    # JavaFX (not needed for this app, saves ~20MB)
    'lib\\jfxrt.jar',
    'lib\\javafx.properties',
    'lib\\jfxswk.jar',
    # Deployment (browser plugin, web start)
    'lib\\deploy.jar',
    'lib\\plugin.jar',
    'lib\\javaws.jar',
    'lib\\deploy',
    # Unused tools
    'bin\\javaws.exe',
    'bin\\javaws.dll',
    # Windows-specific unused DLLs
    'bin\\dt_shmem.dll',
    'bin\\dt_socket.dll',
    'bin\\hprof.dll',
    'bin\\instrument.dll',  # used by javaagent but this app doesn't use it
    'bin\\management.dll',
    'bin\\npt.dll',
    # Kerberos tools (not needed)
    'bin\\kinit.exe',
    'bin\\klist.exe',
    'bin\\ktab.exe',
    # RMI/CORBA (not needed)
    'bin\\rmid.exe',
    'bin\\rmiregistry.exe',
    'bin\\tnameserv.exe',
    'bin\\servertool.exe',
    'bin\\orbd.exe',
    # Misc (not needed)
    'bin\\policytool.exe',
    'bin\\pack200.exe',
    'bin\\unpack200.exe',
    'bin\\jjs.exe',
    # Thrust media (not needed for Swing)
    'lib\\jli.dll',  # under lib/ not bin/
    # charsets.jar - actually needed for proper Unicode handling
    # localedata.jar - keep for i18n
]


def run(cmd, cwd=BASE):
    cmd_str = ' '.join(cmd) if isinstance(cmd, list) else cmd
    print(f'  -> {cmd_str}')
    subprocess.run(cmd, cwd=cwd, check=True)


def find_csc():
    """Find the C# compiler (csc.exe) from .NET Framework."""
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


def compile_java():
    """Compile Java classes."""
    print('=== 1. Compile Java classes ===')
    os.makedirs(CLASSES, exist_ok=True)

    javac = find_javac()
    if not javac:
        print('ERROR: javac not found. Set JAVA_HOME or add JDK to PATH.')
        sys.exit(1)
    print(f'  Using javac: {javac}')

    java_files = []
    for pkg_name in ['engine', 'gui']:
        pkg_dir = os.path.join(SRC, 'com', 'peach', 'sqlformat', pkg_name)
        for root, dirs, files in os.walk(pkg_dir):
            for f in files:
                if f.endswith('.java'):
                    java_files.append(os.path.join(root, f))

    run([javac, '-encoding', 'UTF-8', '-d', CLASSES] + java_files)
    print(f'  Compiled {len(java_files)} source files')
    print()


def find_javac():
    """Find javac executable."""
    java_home = os.environ.get('JAVA_HOME')
    if java_home:
        javac = os.path.join(java_home, 'bin', 'javac.exe')
        if os.path.exists(javac):
            return javac
    for cmd in ['javac', 'javac.exe']:
        try:
            result = subprocess.run(['where', cmd], capture_output=True, text=True)
            if result.returncode == 0:
                return result.stdout.strip().split('\n')[0].strip()
        except FileNotFoundError:
            pass
    return None


def find_java():
    """Find java executable."""
    java_home = os.environ.get('JAVA_HOME')
    if java_home:
        java = os.path.join(java_home, 'bin', 'java.exe')
        if os.path.exists(java):
            return java
    for cmd in ['java', 'java.exe']:
        try:
            result = subprocess.run(['where', cmd], capture_output=True, text=True)
            if result.returncode == 0:
                return result.stdout.strip().split('\n')[0].strip()
        except FileNotFoundError:
            pass
    return None


def create_jar():
    """Create a runnable JAR with manifest."""
    print('=== 2. Create runnable JAR ===')
    os.makedirs(BUILD_DESKTOP, exist_ok=True)

    manifest_dir = os.path.join(BASE, 'build', 'manifest')
    os.makedirs(manifest_dir, exist_ok=True)
    manifest_file = os.path.join(manifest_dir, 'MANIFEST.MF')
    with open(manifest_file, 'w') as f:
        f.write('Manifest-Version: 1.0\n')
        f.write('Main-Class: com.peach.sqlformat.gui.SqlFormatGui\n')
        f.write('\n')

    jar_path = os.path.join(BUILD_DESKTOP, JAR_NAME)
    run(['jar', 'cfm', jar_path, manifest_file, '-C', CLASSES, '.'])
    print(f'  Created: {jar_path}')
    print()


def create_exe():
    """Create EXE launcher with bundled JRE support."""
    print('=== 3. Create EXE launcher ===')
    csc = find_csc()
    if not csc:
        print('ERROR: C# compiler not found. Cannot create EXE.')
        sys.exit(1)
    print(f'  Using csc: {csc}')

    cs_source = os.path.join(BUILD_DESKTOP, 'Launcher.cs')
    exe_path = os.path.join(BUILD_DESKTOP, EXE_NAME)

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
                ShowError("Cannot find " + jarPath + "\\nMake sure the application files are intact.");
                return;
            }

            string javaExe = FindJava(appDir);
            if (javaExe == null)
            {
                ShowError("Java Runtime Environment not found.\\nPlease install Java 8 or later from:\\nhttps://www.java.com/download/");
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
                ShowError("Failed to launch application:\\n" + ex.Message);
            }
        }

        static void ShowError(string message)
        {
            MessageBox(IntPtr.Zero, message, "SQL Format Tool", 0x00000010);
        }

        static string FindJava(string appDir)
        {
            // 1. Bundled JRE — use javaw.exe (no console window)
            string bundledJre = Path.Combine(appDir, "jre", "bin", "javaw.exe");
            if (File.Exists(bundledJre)) return bundledJre;

            // 2. Try PATH for javaw.exe or java.exe
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
                        foreach (var line in output.Split(new[] { '\\r', '\\n' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            string path = line.Trim();
                            // prefer javaw.exe
                            string javawPath = path.Replace("java.exe", "javaw.exe");
                            if (File.Exists(javawPath)) return javawPath;
                            if (File.Exists(path)) return path;
                        }
                    }
                }
            }
            catch { }

            // 3. Try JAVA_HOME
            string javaHome = Environment.GetEnvironmentVariable("JAVA_HOME");
            if (!string.IsNullOrEmpty(javaHome))
            {
                string path = Path.Combine(javaHome, "bin", "javaw.exe");
                if (File.Exists(path)) return path;
                path = Path.Combine(javaHome, "bin", "java.exe");
                if (File.Exists(path)) return path;
            }

            // 4. Common install locations
            string[] commonPaths = new[]
            {
                @"C:\\Program Files\\Java\\jre1.8.0_202\\bin\\javaw.exe",
                @"C:\\Program Files\\Java\\jdk1.8.0_202\\bin\\javaw.exe",
                @"C:\\Program Files (x86)\\Java\\jre1.8.0_202\\bin\\javaw.exe",
                @"C:\\Program Files\\Java\\jre\\bin\\javaw.exe",
                @"C:\\Program Files\\Java\\jdk-17\\bin\\javaw.exe",
                @"C:\\Program Files\\Java\\jdk-21\\bin\\javaw.exe",
                @"C:\\Program Files\\Eclipse Adoptium\\jre-*\\bin\\javaw.exe",
            };
            foreach (string path in commonPaths)
            {
                try
                {
                    string expanded = Path.GetFullPath(path);
                    if (File.Exists(expanded)) return expanded;
                }
                catch { }
            }

            return null;
        }
    }
}
'''.replace('{JAR_NAME}', JAR_NAME)

    with open(cs_source, 'w', encoding='utf-8') as f:
        f.write(cs_code)

    run([csc, '/target:winexe', '/platform:anycpu',
         '/optimize+',
         '/out:' + exe_path,
         cs_source])
    print(f'  Created: {exe_path}')
    print()
    return exe_path


def bundle_jre():
    """Copy and trim JRE for bundling."""
    print('=== 4. Bundle JRE ===')
    jre_target = os.path.join(DIST_DIR, 'jre')

    if not os.path.exists(JRE_SOURCE):
        print(f'ERROR: JRE source not found at {JRE_SOURCE}')
        return False

    print(f'  Source: {JRE_SOURCE}')
    print(f'  Target: {jre_target}')

    # Remove old JRE if exists
    if os.path.exists(jre_target):
        print('  Removing old JRE copy...')
        shutil.rmtree(jre_target)

    # Copy JRE, excluding large unnecessary files at copy time
    print('  Copying JRE (this may take a moment)...')
    ignored = shutil.ignore_patterns(
        'src.zip',
        'classes.jsa',     # Class Data Sharing archive, not required (saves 18MB)
    )
    shutil.copytree(JRE_SOURCE, jre_target, ignore=ignored)

    # Remove unnecessary files to reduce size
    print('  Removing unnecessary files...')
    strip_patterns = [
        # JavaFX - NOT needed (our app uses Swing only), saves ~80MB
        os.path.join(jre_target, 'lib', 'jfxrt.jar'),
        os.path.join(jre_target, 'lib', 'javafx.properties'),
        os.path.join(jre_target, 'lib', 'jfxswk.jar'),
        os.path.join(jre_target, 'bin', 'jfxwebkit.dll'),       # 60MB!
        os.path.join(jre_target, 'bin', 'glass.dll'),
        os.path.join(jre_target, 'bin', 'gstreamer-lite.dll'),
        os.path.join(jre_target, 'bin', 'glib-lite.dll'),
        os.path.join(jre_target, 'bin', 'decora_sse.dll'),
        os.path.join(jre_target, 'bin', 'fxplugins.dll'),
        os.path.join(jre_target, 'bin', 'prism_*.dll'),
        # Deployment (browser plugin, web start, ActiveX)
        os.path.join(jre_target, 'lib', 'deploy.jar'),
        os.path.join(jre_target, 'lib', 'plugin.jar'),
        os.path.join(jre_target, 'lib', 'javaws.jar'),
        os.path.join(jre_target, 'lib', 'deploy'),
        os.path.join(jre_target, 'bin', 'javaws.exe'),
        os.path.join(jre_target, 'bin', 'dtplugin'),
        os.path.join(jre_target, 'bin', 'deploy.dll'),
        os.path.join(jre_target, 'bin', 'deployJava1.dll'),
        os.path.join(jre_target, 'bin', 'jp2iexp.dll'),
        os.path.join(jre_target, 'bin', 'jp2ssv.dll'),
        os.path.join(jre_target, 'bin', 'jp2native.dll'),
        os.path.join(jre_target, 'bin', 'ssv.dll'),
        os.path.join(jre_target, 'bin', 'ssvagent.exe'),
        os.path.join(jre_target, 'bin', 'eula.dll'),
        os.path.join(jre_target, 'bin', 'regutils.dll'),
        os.path.join(jre_target, 'bin', 'deploy.dll'),
        # Unused tools
        os.path.join(jre_target, 'bin', 'kinit.exe'),
        os.path.join(jre_target, 'bin', 'klist.exe'),
        os.path.join(jre_target, 'bin', 'ktab.exe'),
        os.path.join(jre_target, 'bin', 'rmid.exe'),
        os.path.join(jre_target, 'bin', 'rmiregistry.exe'),
        os.path.join(jre_target, 'bin', 'tnameserv.exe'),
        os.path.join(jre_target, 'bin', 'servertool.exe'),
        os.path.join(jre_target, 'bin', 'orbd.exe'),
        os.path.join(jre_target, 'bin', 'policytool.exe'),
        os.path.join(jre_target, 'bin', 'pack200.exe'),
        os.path.join(jre_target, 'bin', 'unpack200.exe'),
        os.path.join(jre_target, 'bin', 'jjs.exe'),
        # Debug/profiling DLLs (not needed for production use)
        os.path.join(jre_target, 'bin', 'dt_shmem.dll'),
        os.path.join(jre_target, 'bin', 'dt_socket.dll'),
        os.path.join(jre_target, 'bin', 'hprof.dll'),
        os.path.join(jre_target, 'bin', 'jfr.jar'),
        # Accessibility bridge (not needed for our app)
        os.path.join(jre_target, 'bin', 'JAWTAccessBridge-64.dll'),
        os.path.join(jre_target, 'bin', 'JavaAccessBridge-64.dll'),
        os.path.join(jre_target, 'bin', 'WindowsAccessBridge-64.dll'),
        # License files (not needed at runtime)
        os.path.join(jre_target, 'Welcome.html'),
        os.path.join(jre_target, 'COPYRIGHT'),
        os.path.join(jre_target, 'LICENSE'),
        os.path.join(jre_target, 'README.txt'),
        os.path.join(jre_target, 'THIRDPARTYLICENSEREADME.txt'),
        os.path.join(jre_target, 'THIRDPARTYLICENSEREADME-JAVAFX.txt'),
    ]

    import glob as glob_module
    for pattern in strip_patterns:
        # Handle wildcard patterns
        if '*' in pattern:
            for matched_path in glob_module.glob(pattern):
                try:
                    if os.path.isdir(matched_path):
                        shutil.rmtree(matched_path)
                    else:
                        os.remove(matched_path)
                except Exception as e:
                    print(f'    Warning: could not remove {matched_path}: {e}')
        else:
            if os.path.exists(pattern):
                try:
                    if os.path.isdir(pattern):
                        shutil.rmtree(pattern)
                    else:
                        os.remove(pattern)
                except Exception as e:
                    print(f'    Warning: could not remove {pattern}: {e}')

    # Also remove Windows-specific DLLs from lib/ that aren't needed
    lib_jli = os.path.join(jre_target, 'lib', 'jli.dll')
    if os.path.exists(lib_jli):
        try:
            os.remove(lib_jli)
        except:
            pass

    # Calculate size
    total_size = 0
    for root, dirs, files in os.walk(jre_target):
        for f in files:
            fp = os.path.join(root, f)
            total_size += os.path.getsize(fp)

    print(f'  Bundled JRE size: {total_size / 1024 / 1024:.1f} MB')
    print()
    return True


def assemble_distribution(exe_path):
    """Assemble final distribution folder."""
    print('=== 5. Assemble distribution ===')

    # Clean and create dist directory
    # Remove old distribution directory only (not the whole dist/ parent)
    if os.path.exists(DIST_DIR):
        print('  Removing old distribution...')
        def remove_readonly(func, path, exc_info):
            os.chmod(path, 0o777)
            func(path)
        shutil.rmtree(DIST_DIR, onerror=remove_readonly)

    os.makedirs(DIST_DIR)

    # Copy EXE
    shutil.copy2(exe_path, os.path.join(DIST_DIR, EXE_NAME))
    print(f'  Copied: {EXE_NAME}')

    # Copy JAR
    shutil.copy2(os.path.join(BUILD_DESKTOP, JAR_NAME),
                 os.path.join(DIST_DIR, JAR_NAME))
    print(f'  Copied: {JAR_NAME}')

    # Bundle JRE
    bundle_jre()

    # Calculate total size
    total_size = 0
    for root, dirs, files in os.walk(DIST_DIR):
        for f in files:
            fp = os.path.join(root, f)
            total_size += os.path.getsize(fp)

    print(f'  Total distribution size: {total_size / 1024 / 1024:.1f} MB')
    print()


def create_zip():
    """Create a ZIP file of the distribution."""
    print('=== 6. Create distribution ZIP ===')
    zip_name = os.path.join(BASE, 'build', 'dist', 'SqlFormat-1.0.0.zip')
    dist_parent = os.path.dirname(DIST_DIR)
    dist_basename = os.path.basename(DIST_DIR)

    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(DIST_DIR):
            for f in files:
                file_path = os.path.join(root, f)
                arcname = os.path.relpath(file_path, dist_parent)
                zf.write(file_path, arcname)

    zip_size = os.path.getsize(zip_name)
    print(f'  Created: {zip_name}')
    print(f'  ZIP size: {zip_size / 1024 / 1024:.1f} MB')
    print()


def main():
    print('=== SQL Format Desktop Distribution Builder ===')
    print()

    compile_java()
    create_jar()

    exe_path = create_exe()

    assemble_distribution(exe_path)

    create_zip()

    print('=== DONE ===')
    print(f'Distribution folder: {DIST_DIR}')
    print(f'Distribution ZIP:    {os.path.join(BASE, "build", "dist", "SqlFormat-1.0.0.zip")}')
    print()
    print('To use:')
    print('  1. Unzip SqlFormat-1.0.0.zip anywhere on a Windows machine')
    print('  2. Double-click SqlFormat.exe')
    print('  3. No Java installation required!')
    print()


if __name__ == '__main__':
    main()
