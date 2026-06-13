$ErrorActionPreference = "Stop"

function Find-Ruby {
  $ruby = Get-Command ruby -ErrorAction SilentlyContinue
  if ($ruby) {
    return $ruby.Source
  }

  $candidates = @(
    "C:\Ruby40-x64\bin\ruby.exe",
    "C:\Ruby33-x64\bin\ruby.exe",
    "C:\Ruby34-x64\bin\ruby.exe"
  )

  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) {
      return $candidate
    }
  }

  throw "Ruby was not found. Install Ruby from https://rubyinstaller.org and add it to PATH."
}

$rubyPath = Find-Ruby
$setupScript = Join-Path $PSScriptRoot "setup"

& $rubyPath $setupScript @args
