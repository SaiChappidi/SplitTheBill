# Split The Bill

## Overview
This project is a Ruby on Rails application for organizing trips and splitting shared expenses among participants. The website lets users create trips, add expenses, choose who shares each expense, and review balances and settlement suggestions. This project was created in CSE 3901 by Sai, Charishma, Cynthia, Syah, Sindhu.

## Features
- Create and manage trips with participants
- Add, edit, and delete shared expenses
- Split expenses across all participants or only selected participants
- Enter custom amounts per person for each expense
- View expense totals, balances, and settlement suggestions
- Filter and search expenses on the trip page

## File Structure
```text
.
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── assets/
│   └── javascript/
├── config/
├── db/
├── test/
├── bin/
├── Gemfile
└── README.md
```

## Ruby Version
- Ruby `3.3.5`

## System Dependencies
- Ruby on Rails `8.1.3`
- Node.js and npm for frontend 

## Configuration
Install the Ruby gems:
```bash
bundle install
```

On Windows, if `bundle install` fails while building `psych`, install the Ruby DevKit dependency:
```powershell
C:\Ruby40-x64\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm mingw-w64-ucrt-x86_64-libyaml"
```

## How to Run

### macOS / Linux
Start the app in development with:
```bash
bin/dev
```

First-time setup:
```bash
bin/setup
```

### Windows
From PowerShell in the project folder:
```powershell
cd E:\splithebill\SplitTheBill
.\bin\dev.ps1
```

First-time setup:
```powershell
.\bin\setup.ps1 --skip-server
```

You can also use the batch wrappers:
```powershell
.\bin\dev.bat
.\bin\setup.bat --skip-server
```

If Ruby is on your PATH, these also work:
```powershell
ruby .\bin\dev
ruby .\bin\setup --skip-server
```

Open **http://localhost:3000** after the server starts.

### All platforms
You can also run the Rails server directly:
```bash
bin/rails server
```

## Services
This project uses built-in Rails services for background jobs and caching.

## Deployment Instructions
The application is configured for Docker deployment.

To build the production image:
```bash
docker build -t nosindawoo_final_project .
```

To run it in production, provide `RAILS_MASTER_KEY` and start the container as described in the `Dockerfile`.
