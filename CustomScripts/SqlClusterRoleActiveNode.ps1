Param (
    [String] $RoleId
)

# Devuelve el nombre del nodo propietario actual (OwnerNode)
(Get-ClusterGroup | Where-Object { $_.Id -eq $RoleId }).OwnerNode.Name