#!/usr/bin/env bash
# Get Windows ZScaler root certificate and write it to standard output.
# Should work under MinGW/Git Bash and WSL.
#
# Get the latest version at https://github.com/fardaniqbal/misc-utils/.

# Check host OS.
host_is_windows=false
case "$(printf '%s' "$(uname -s)" | tr [A-Z] [a-z])" in
  win*|mingw*|msys*|cygwin*) host_is_windows=true;;
esac
host_is_wsl=false
command -v wslinfo >/dev/null && host_is_wsl=true

# Try to be helpful if we're not running on a supported OS.
if ! $host_is_windows && ! $host_is_wsl; then
  cat >&2 <<EOF
ERROR: OS not supported.
Please open an issue at https://github.com/fardaniqbal/misc-utils/.
Pull requests welcome!
EOF
  exit 1
fi

# Make sure Windows .exe interop is enabled if running in WSL.
if $host_is_wsl && ! cmd.exe /c 'exit 0' >/dev/null 2>&1; then
  cat >&2 <<EOF
ERROR: you're running in WSL, but Windows .exe interop is not enabled.
See https://wsl.dev/technical-documentation/interop/ for instructions on
how to enable Windows .exe interop.
EOF
  exit 1
fi

set -Eeuo pipefail
powershell.exe \
  -NoProfile -ExecutionPolicy Bypass -Command 2>/dev/null "$(cat <<'EOF'
# Find the Zscaler Root CA in the Local Machine Trusted Root store.
$certs = Get-ChildItem "Cert:\LocalMachine\Root" |
  Where-Object { $_.Subject -like "*Zscaler*" }

# Export each cert to Base64 (PEM) format.
$pemCert = ""
foreach ($cert in $certs) {
  # Convert cert to raw Base64.
  $base64 = [System.Convert]::ToBase64String($cert.Export(
      [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert
  ))
  # Wrap Base64 text to 64-char lines.
  $base64 = ($base64 -split "(.{64})") |
      Where-Object { $_ } | ForEach-Object { $_ } | Out-String
  # Add header and footer.
  $pemCert +=
      "-----BEGIN CERTIFICATE-----`n" +
      $base64 +
      "-----END CERTIFICATE-----`n"
}
# Dump the PEM-format certificates to standard output.
$pemCert.TrimEnd()
EOF
)" | tr -d $'\r'
