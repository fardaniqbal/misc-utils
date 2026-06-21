#!/usr/bin/env -S powershell -NoProfile -ExecutionPolicy Bypass
#
# Get the Zscaler Root CA from Windows' trusted root store and write it to
# standard output.  Runs under Windows' built-in Powershell, and DOES NOT
# require administrator privileges.
#
# Latest version available at https://github.com/fardaniqbal/misc-utils

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
