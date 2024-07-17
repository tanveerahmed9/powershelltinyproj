param($Timer)

# Function to generate a random username
function Get-RandomUsername {
    $adjectives = @("Happy", "Sunny", "Clever", "Brave", "Gentle", "Wise", "Kind", "Swift", "Calm", "Bright")
    $nouns = @("Lion", "Eagle", "Dolphin", "Tiger", "Panda", "Wolf", "Bear", "Fox", "Owl", "Hawk")
    $number = Get-Random -Minimum 100 -Maximum 999

    $adjective = Get-Random -InputObject $adjectives
    $noun = Get-Random -InputObject $nouns

    return "$adjective$noun$number"
}

# Generate 5 random users
$users = @()
for ($i = 1; $i -le 5; $i++) {
    $username = Get-RandomUsername 
    $user = @{
        PartitionKey = "Users"
        RowKey       = $username
        Username     = $username
        CreatedDate  = (Get-Date).ToString("o")
    }
    $users += $user
}

# Output the users to the table
try {
    Push-OutputBinding -Name outputTable -Value $users 
}
catch {
    Write-Host "Error while putting users in the table $_"
}

# Log the operation
Write-Host "Added 5 new users to the Users table:"
$users | ForEach-Object { Write-Host $_.Username }