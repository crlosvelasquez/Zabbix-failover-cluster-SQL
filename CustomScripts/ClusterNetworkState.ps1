Param (
    [String] $Id
)

$CleanId = $Id -replace '["'']', ''
$CleanId = $CleanId.Trim()

$Network = Get-ClusterNetwork | Where-Object { $_.Id -eq $CleanId }

if ($Network) {
    $Network.State.ToString()
} else {
    "NotFound"
}