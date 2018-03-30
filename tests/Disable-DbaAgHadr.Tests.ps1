$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag "UnitTests" {
    Context "Validate parameters" {
        $paramCount = 4
        <#
            Get commands, Default count = 11
            Commands with SupportShouldProcess = 13
        #>
        $defaultParamCount = 13
        [object[]]$params = (Get-ChildItem function:\Disable-DbaAgHadr).Parameters.Keys
        $knownParameters = 'SqlInstance', 'Credential', 'Force', 'EnableException'
        It "Should contian our specifc parameters" {
            ((Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}

Describe "$commandname Integration Tests" -Tag "IntegrationTests" {
    BeforeAll {
        $current = Get-DbaAgHadr -SqlInstance $script:instance3 # for appveyor $script:instance2
        Enable-DbaAgHadr -SqlInstance $script:instance3 -Confirm:$false -WarningAction SilentlyContinue
    }
    AfterAll {
        if ($current.IsHadrEnabled) {
            Enable-DbaAgHadr -SqlInstance $script:instance3 -Confirm:$false -WarningAction SilentlyContinue
        }
    }
    
    $results = Disable-DbaAgHadr -SqlInstance $script:instance3 -Confirm:$false -WarningAction SilentlyContinue -WarningVariable warn
    
    It "disables hadr and returns a warning to restart" {
        $warn | Should -Not -Be $null
        $results.IsHadrEnabled | Should -Be $false
    }
}