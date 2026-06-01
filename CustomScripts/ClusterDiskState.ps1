Param (
    [String] $Id
)

$CleanId = $Id -replace '["'']', ''
$CleanId = $CleanId.Trim()

$Resource = Get-ClusterResource | Where-Object { $_.Id -eq $CleanId }

if ($Resource) {
    $Resource.State.ToString()
} else {
    "NotFound"
}