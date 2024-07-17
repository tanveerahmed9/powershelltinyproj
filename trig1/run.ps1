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
        $user = @{
            PartitionKey = "Users"
            RowKey = $username
            Username = $username
            CreatedDate = (Get-Date).ToString("o")
        }
        $users += $user
        Write-Host "Generated user: $username"
    }

    # Output the users to the table
    Write-Host "Attempting to push users to table"
    Push-OutputBinding -Name outputTable -Value $users

    # Log the operation
    Write-Host "Successfully added 5 new users to the Users table:"
    $usernames = $users | ForEach-Object { $_.Username }

    # Prepare the response
    $body = "Successfully added 5 new users to the Users table: $($usernames -join ', ')"
    
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $body
    })
}
catch {
    # Log any errors
    Write-Error "An error occurred: $_"
    Write-Error $_.ScriptStackTrace

    # Return an error response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = "An error occurred while processing the request: $_"
    })
}