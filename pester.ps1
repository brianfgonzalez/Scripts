Describe 'Disk health checks' {
    It 'Has at least 10% of free space' {
        $diskInfo = Get-WmiObject win32_logicaldisk | ? DeviceId -eq 'C:'

        $diskSize = $diskInfo.Size

        $expectedFreeSpace = $diskSize * 0.1  #10% of the total size
        $expectedFreeSpaceInGigabytes = [Math]::Round($expectedFreeSpace / 1GB, 2)

        $freeSpace = $diskInfo.FreeSpace
        $freeSpaceInGigabytes = [Math]::Round($freeSpace / 1GB, 2)

        $freeSpaceInGigabytes | Should -BeGreaterThan $expectedFreeSpaceInGigabytes
        
    }
}