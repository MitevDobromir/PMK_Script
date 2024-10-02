# Define installation command for Python
$installPython = 'winget install Python --accept-source-agreements --silent'

# Function to install Python
function Install-Python {
    # Log the download process
    Write-Host "Downloading Python..."

    # Execute the install command and pass 'Y' for any prompt
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c echo Y | $installPython" -Wait -WindowStyle Hidden

    # Verify if Python is installed
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host "Python installation successful." -ForegroundColor Green
    } else {
        Write-Host "Python installation failed." -ForegroundColor Red
    }
}

# Function to install Python libraries
function Install-PythonLibraries {
    param (
        [string[]]$libraries
    )

    foreach ($library in $libraries) {
        # Split library name and version (if provided)
        $libraryParts = $library -split '=='
        $libraryName = $libraryParts[0]
        $libraryVersion = if ($libraryParts.Length -gt 1) { $libraryParts[1] } else { $null }

        # Check if the library is already installed using pip
        $libraryInstalled = & pip show $libraryName 2>$null
        
        if ($libraryInstalled) {
            Write-Host "$libraryName is already installed." -ForegroundColor Yellow

            # If a version was specified, check if the installed version matches
            if ($libraryVersion) {
                $installedVersion = (& pip show $libraryName | Select-String -Pattern 'Version: (\d+\.\d+\.\d+)').Matches.Groups[1].Value
                
                if ($installedVersion -ne $libraryVersion) {
                    Write-Host "$libraryName version $installedVersion is installed, but $libraryVersion is required. Installing the correct version..." -ForegroundColor Yellow
                    $installResult = & pip install "$libraryName==$libraryVersion" 2>&1
                    if ($installResult -match "Successfully installed") {
                        Write-Host "$libraryName version $libraryVersion installation successful." -ForegroundColor Green
                    } else {
                        Write-Host "$libraryName installation failed. Error: $installResult" -ForegroundColor Red
                    }
                }
            }
        } else {
            Write-Host "Installing library: $library..."
            $installResult = & pip install $library 2>&1
            
            if ($installResult -match "Successfully installed") {
                Write-Host "$library installation successful." -ForegroundColor Green
            } else {
                Write-Host "$library installation failed. Error: $installResult" -ForegroundColor Red
            }
        }
    }
}

# Log the start of the script
Write-Host "Start of script"

# Step 1: Check if Python is already installed
$pythonInstalled = Get-Command python -ErrorAction SilentlyContinue

if ($pythonInstalled) {
    # Get the installed version of Python
    $pythonVersion = & python --version 2>&1

    # Extract the version numbers using a regular expression
    if ($pythonVersion -match '(\d+)\.(\d+)\.(\d+)') {
        $majorVersion = [int]$matches[1]
        $minorVersion = [int]$matches[2]
        $patchVersion = [int]$matches[3]

        # Display the version
        Write-Host "Python is already installed. Version: $majorVersion.$minorVersion.$patchVersion" -ForegroundColor Yellow

        # Check if the version is below 3.9
        if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 9)) {
            Write-Host "The installed version is below 3.9. You may want to update it." -ForegroundColor Red
            Install-Python
        }
    } else {
        Write-Host "Could not determine the installed Python version. Attempting to install Python..." -ForegroundColor Red
        Install-Python
    }
} else {
    # Step 3: If Python is not installed, call the function to install Python
    Write-Host "Python is not installed. Proceeding to install Python..." -ForegroundColor Yellow
    Install-Python
}

# Step 4: Install Python libraries
$librariesToInstall = @("mlagents", "torch", "torchvision", "torchaudio", "protobuf==3.20.3")  # Specify the desired libraries here
Install-PythonLibraries -libraries $librariesToInstall

Write-Host "End of script"
