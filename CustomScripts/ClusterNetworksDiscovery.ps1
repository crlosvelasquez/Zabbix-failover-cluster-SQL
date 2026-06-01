function Get-ZbxClusterNetworks {
    $networks = Get-ClusterNetwork | Select-Object Name, Id

    $result = @()

    $networks | ForEach-Object {
        $result += @{
            '{#NET_NAME}' = $_.Name
            '{#NET_ID}'   = $_.Id
        }
    }

    return $result
}

$dataList = Get-ZbxClusterNetworks
@{ "data" = @($dataList) } | ConvertTo-Json -Depth 3 -Compress