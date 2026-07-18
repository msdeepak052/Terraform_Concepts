<#
  clean-terraform-cache.ps1

  Recursively finds and deletes every ".terraform" folder under
  Terraform_Practise (the provider-plugin cache Terraform regenerates
  automatically on the next `terraform init`). Run this after a workshop
  to reclaim disk space -- these folders can be large across many
  practice directories and never need to be kept around.

  Safe to re-run any time; if no .terraform folders exist, it just says so.
#>

$root = "D:\Study\Terraform2\Terraform_Practise"

if (-not (Test-Path $root)) {
    Write-Host "Root folder not found: $root" -ForegroundColor Yellow
    exit 1
}

Write-Host "Scanning for .terraform folders under $root ..." -ForegroundColor Cyan
$targets = Get-ChildItem -Path $root -Directory -Recurse -Force -Filter ".terraform" -ErrorAction SilentlyContinue

if (-not $targets -or $targets.Count -eq 0) {
    Write-Host "No .terraform folders found. Nothing to clean." -ForegroundColor Green
    exit 0
}

$totalBytes = 0
foreach ($dir in $targets) {
    $size = (Get-ChildItem -Path $dir.FullName -Recurse -Force -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum
    if (-not $size) { $size = 0 }
    $totalBytes += $size
    $sizeMB = [math]::Round($size / 1MB, 2)

    Write-Host "Deleting: $($dir.FullName)  ($sizeMB MB)"
    Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

$totalMB = [math]::Round($totalBytes / 1MB, 2)
Write-Host ""
Write-Host "Done. Removed $($targets.Count) .terraform folder(s), freed approximately $totalMB MB." -ForegroundColor Cyan
