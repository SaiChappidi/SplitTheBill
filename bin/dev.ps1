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

function Test-ServerRunning {
  try {
    $connection = Test-NetConnection -ComputerName 127.0.0.1 -Port 3000 -WarningAction SilentlyContinue
    return $connection.TcpTestSucceeded
  } catch {
    return $false
  }
}

function Open-App {
  Write-Host "Opening http://localhost:3000 in your browser..."
  Start-Process "http://localhost:3000"
}

if (Test-ServerRunning) {
  Write-Host "Server is already running at http://localhost:3000"
  Open-App
  exit 0
}

$rubyPath = Find-Ruby
$devScript = Join-Path $PSScriptRoot "dev"

Write-Host "Starting server. Your browser will open once it is ready..."
Start-Job -ScriptBlock {
  Start-Sleep -Seconds 4
  Start-Process "http://localhost:3000"
} | Out-Null

& $rubyPath $devScript @args
