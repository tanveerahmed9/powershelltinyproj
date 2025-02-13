using namespace System.Net

param($Request, $TriggerMetadata)

# Enable detailed error view
$ErrorActionPreference = "Stop"

# Function to generate a random username
function Get-RandomUsername {
    $adjectives = @("Happy", "Sunny", "Clever", "Brave", "Gentle", "Wise", "Kind", "Swift", "Calm", "Bright")
    $nouns = @("Lion", "Eagle", "Dolphin", "Tiger", "Panda", "Wolf", "Bear", "Fox", "Owl", "Hawk")
    $number = Get-Random -Minimum 100 -Maximum 999

    $adjective = Get-Random -InputObject $adjectives
    $noun = Get-Random -InputObject $nouns

    return "$adjective$noun$number"
}

try {
    Write-Host "Function started execution"
    
    # Generate 5 random users
    $users = @()
    for ($i = 1; $i -le 5; $i++) {
        $username = Get-RandomUsername
        $users += $username
        Write-Host "Generated user: $username"
    }

    # Output the users to the queue
    Write-Host "Attempting to push users to queue"
    $users | ForEach-Object {
        Push-OutputBinding -Name outputQueue -Value $_
    }

    # Log the operation
    Write-Host "Successfully added 5 new users to the queue:"
    $usernames = $users | ForEach-Object { $_.Username }

    # Prepare the response
    $body = "Successfully added 5 new users to the queue: $($usernames -join ', ')"
    
    # Return the HTTP response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $body
        })
}
catch {
    # Log any errors
    Write-Error "An error occurred: $_"
    Write-Error $_.ScriptStackTrace

    # Return an error response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::InternalServerError
            Body       = "An error occurred while processing the request: $_"
        })
}

# Return the response