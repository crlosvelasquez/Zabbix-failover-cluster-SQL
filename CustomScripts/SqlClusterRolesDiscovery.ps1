function Get-ZbxSqlClusterRoles {
    # Identificar los nombres de los grupos que tienen recursos de SQL Server
    $sqlGroupNames = (Get-ClusterResource | Where-Object { $_.ResourceType -like "SQL Server*" }).OwnerGroup.Name | Select-Object -Unique
    
    # Obtener los objetos de esos grupos
    $sqlGroups = Get-ClusterGroup | Where-Object { $sqlGroupNames -contains $_.Name } | Select-Object Name, Id
    
    $result = @()

    $sqlGroups | ForEach-Object {
        $result += @{
            '{#ROLE_NAME}' = $_.Name
            '{#ROLE_ID}'   = $_.Id
        }
    }
    
    return $result
}

# Solución para Zabbix: Forzar arreglo y envolver en la propiedad "data"
$dataList = Get-ZbxSqlClusterRoles
@{ "data" = @($dataList) } | ConvertTo-Json -Depth 3 -Compress