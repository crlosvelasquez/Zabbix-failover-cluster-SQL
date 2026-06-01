Param (
    [String] $Id
)

$CleanId = $Id -replace '["'']', ''
$CleanId = $CleanId.Trim()

# Buscamos el disco y extraemos el nombre del nodo que lo posee actualmente
$Resource = Get-ClusterResource | Where-Object { $_.Id -eq $CleanId }

if ($Resource) {
    $Resource.OwnerGroup.OwnerNode.Name
} else {
    "NotFound"
}