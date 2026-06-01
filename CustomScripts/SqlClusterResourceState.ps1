Param (
    [String] $Id
)

# Devuelve el estado del recurso de SQL
(Get-ClusterResource | Where-Object { $_.Id -eq $Id }).State