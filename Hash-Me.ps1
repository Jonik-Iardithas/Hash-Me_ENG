Add-Type -AssemblyName System.Windows.Forms

$HexChar = @(48..57;65..70)
$HexChar = [array]$HexChar.ForEach({$_.ToChar($this)})

$NL = [System.Environment]::NewLine

$Msg = @{
    Abort        = "Abort at user request."
    FileDialog   = "Please select file:"
    Ident        = "The hash total is identical!"
    Invalid      = "Invalid string! Enter `"X`" to exit."
    NoIdent      = "The hash total is NOT identical!"
    Path         = "File path:"
    Prompt       = "Enter SHA256-Hash"
    Quit         = "Press any key to exit..."
    Result       = "Result:"
    SHA256       = "SHA256-Hash:"
    Title        = "Hash-Me (SHA256-Verification Tool)" + $NL
    Verification = "File is being verified..."
}

$Sum    = [string]::Empty
$Result = [string]::Empty

Write-Host $Msg.Title -ForegroundColor Blue -BackgroundColor White

Do  {
        $TryAgain = $false

        $Sum = (Read-Host -Prompt $Msg.Prompt).ToUpper()

        If ($Sum -ceq "X")
            {
                $Result = $Msg.Abort
            }
        ElseIf ($Sum.Length -ne 64)
            {
                $TryAgain = $true
            }
        Else
            {
                $Sum.ToCharArray() | ForEach-Object {If ($_ -notin $HexChar) {$TryAgain = $true}}
            }

        If ($TryAgain)
            {
                Write-Host $Msg.Invalid
            }
    }
Until (-not $TryAgain)

Clear-Host
Write-Host $Msg.SHA256 $Sum

If ($Result -ne $Msg.Abort)
    {
        $File = New-Object -TypeName System.Windows.Forms.OpenFileDialog
        $File.InitialDirectory = $env:USERPROFILE
        $File.Title = $Msg.FileDialog

        If ($File.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
            {
                Write-Host $Msg.Path $File.FileName
                Write-Host $Msg.Verification

                $SHA = New-Object -TypeName System.Security.Cryptography.SHA256Managed
                $Stream = [System.IO.FileStream]::new($File.FileName,[System.IO.FileMode]::Open)
                $Hash = $SHA.ComputeHash($Stream)

                $sHash = [System.BitConverter]::ToString($Hash).Replace("-",[string]::Empty)

                Write-Host $Msg.SHA256 $sHash

                If ($sHash -ceq $Sum)
                    {
                        $Result = $Msg.Ident
                    }
                Else
                    {
                        $Result = $Msg.NoIdent
                    }

                $Stream.Close()
                $Stream.Dispose()
                $SHA.Dispose()
            }
        Else
            {
                $Result = $Msg.Abort
            }
    }

Write-Host $Msg.Result $Result

If ([System.Diagnostics.Process]::GetCurrentProcess().ProcessName -ne "powershell_ise")
    {
        Write-Host $Msg.Quit
        $Host.UI.RawUI.ReadKey()
    }