function Get-ZbxClusterDisks {
    # Buscamos recursos que sean del tipo disco físico o CSV
    $disks = Get-ClusterResource | Where-Object { $_.ResourceType -eq "Physical Disk" -or $_.ResourceType -eq "Cluster Shared Volume" } | Select-Object Name, Id

    $result = @()

    $disks | ForEach-Object {
        $result += @{
            '{#DISK_NAME}' = $_.Name
            '{#DISK_ID}'   = $_.Id
        }
    }

    return $result
}

$dataList = Get-ZbxClusterDisks
@{ "data" = @($dataList) } | ConvertTo-Json -Depth 3 -Compress