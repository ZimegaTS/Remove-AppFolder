Function Remove-AppFolder {
    <#
    .SYNOPSIS
    Removes multiple folders from multiple system simultaneously 
    .EXAMPLE
    Remove-AppFolder -AppFolder "NameOfAppFolder" -TargetServer Computer1 -LogFile .\MyLog.log
    Checks a TargetServer named Computer1 to see if "NameOfAppFolder" exist and if so, removes it and writes information to log "MyLog.log"
    .EXAMPLE
    Remove-AppFolder -AppFolder "AppFolder1, AppFolder2" -TargetServer Computer1
    Scans Computer1 and check for the presence of AppFolder1 and AppFolder2 and removes them.
    .EXAMPLE
    Remove-AppFolder -AppFolder "AppFolder1, AppFolder2, AppFolder3" -TargetServer (Get-Content .\ServerList.txt)
    
    Gets a list of servers from ServerList.txt and scans each one for "AppFolder1, AppFolder2 and AppFolder3 and removes them.
    .EXAMPLE
    Remove-AppFolder -AppFolder (Get-Content .\Packages.txt) -TargetServer (Get-Content .\ServerList.txt)
    
    Gets a list of servers from ServerList.txt and scans 10 at a time for the folders\packages listed in Packages.txt and and removes them 15 at a time.
    .EXAMPLE
    Remove-AppFolder -AppFolder "AppFolder" -TargetServer Computer1 -Verbose
    Checks a TargetServer named Computer1 to see if "AppFolder" exist and if so, removes it and writes information to console\screen"
    .PARAMETER TargetServer
    Specifies the computer you want to scan for AppFolder.
    .PARAMETER AppFolder
    Specifies the package folder you are looking for
    .DESCRIPTION
    Script written by Frank Straughter Jr.
    Completed on: 2022.09.16
    Last Updated: 2022.09.16
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position = 0)]
        [string[]]$AppFolder,
        [Parameter(Mandatory=$True,Position = 1)]
        [string[]]$TargetServer,
        [Parameter(Mandatory=$False)]
        [string]$LogFile = ''
    )
    Function Write-Log {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$False)]
            [string]$LogFile = '',
            [Parameter(Mandatory=$True)]
            [string]$Message,
            [Parameter(Mandatory=$True)]
            [ValidateSet("INFO","DEBUG","WARNING", "ERROR")]
            [string]$MessageType
        )
    
        If ($LogFile){
                $DateTime = Get-Date -Format "yyyy.MM.dd HH:MM:ss"
                $LogEntry = "{0}  {1}: {2}" -f $DateTime, $MessageType, $Message
                Write-Output $LogEntry | Out-File -FilePath $LogFile -Encoding UTF8 -Append -Force
        
        }
        else {
           Return
        }
    }

    Write-Log -LogFile $LogFile -Message ("Server count is: " + $TargetServer.count) -MessageType INFO
    Write-Verbose -Message ("Server count is: " + $TargetServer.count)
    Write-Log -LogFile $LogFile -Message ("Folder count is: " + $AppFolder.count) -MessageType INFO
    Write-Verbose -Message ("Folder count is: " + $AppFolder.count)
    Foreach ($Server in $TargetServer ) {

        Write-Log -LogFile $LogFile -Message "Testing Connection to $TargetServer" -MessageType INFO
        Write-Verbose -Message "Testing Connection to $TargetServer"
        If (Test-Connection -TargetName $Server){
            
            Write-Log -LogFile $LogFile -Message "Connection to $TargetServer was successful!!" -MessageType INFO
            Write-Verbose -Message "Connection to $TargetServer was successful!!"
            Foreach ($Folder in $AppFolder) {

                $Path = ("\\$TargetServer\InstallPackages$\" + "$Folder")
                Write-Log -LogFile $LogFile -Message "Looking for $Folder on: $TargetServer" -MessageType INFO
                If (Test-Path $Path ) {

                    Write-Log -LogFile $LogFile -Message "Folder $Folder exist on $TargetServer. Attempting to remove......." -MessageType INFO
                    Write-Verbose "Folder $Folder exist on $TargetServer. Attempting to remove......."
                    Try {
                        Remove-Item -Path $Path -Recurse -Force
                        Write-Log -LogFile $LogFile -Message "$Folder has been successfully removed on: $TargetServer" -MessageType INFO
                        Write-Verbose -Message "$Folder has been successfully removed on: $TargetServer"
                    
                    } Catch {
                        Write-Log -LogFile $LogFile "Could not remove $Folder from $TargetServer because of the following error: $_" -MessageType ERROR
                        Write-Error -Message "Could not remove $Folder from $TargetServer because of the following error: $_"
                    }

                }
                else{
                    Write-Log -LogFile $LogFile -Message "Folder $Folder does NOT exist on $TargetServer." -MessageType INFO
                    Write-Verbose "Folder $Folder does NOT exist on $TargetServer."
                }

            }
        }
        Else {
            Write-Log -LogFile $LogFile -Message "Server was unreachable $TargetServer." -MessageType WARNING
            Write-Warning -Message "Server $TargetServer was unreachable."
        }

    }
}
