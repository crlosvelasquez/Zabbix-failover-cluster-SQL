function Get-ZbxSqlClusterResources {
    # Filtra recursos específicos de SQL Server
    $resources = Get-ClusterResource | Where-Object { $_.ResourceType -like "SQL Server*" } | Select-Object Name, Id, ResourceType

    $result = @()

    $resources | ForEach-Object {
        $result += @{
            '{#RES_NAME}' = $_.Name
            '{#RES_ID}'   = $_.Id
            '{#RES_TYPE}' = $_.ResourceType.toString()
        }
    }

    return $result
}

# Solución para Zabbix: Forzar arreglo y envolver en la propiedad "data"
$dataList = Get-ZbxSqlClusterResources
@{ "data" = @($dataList) } | ConvertTo-Json -Depth 3 -Compress