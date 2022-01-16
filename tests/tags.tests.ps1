<#
.SYNOPSIS
    Pester test to see if tags are applied in Bicep template
.DESCRIPTION
    Tests if tags are applied in Bicep template
    Works for Bicep files that use modules, for example main.bicep
    When a tag is not applied to one of the resources, the test will fail
.EXAMPLE
    $Data = @{
        TemplatePath     = '.\main.bicep'
        MandatoryTags    = @(
            'Owner'
            'CostCenter'
            'Environment'
            'DeploymentDate'
        )
        TagParameterName = 'tags'
        TagModuleName    = 'tagging'
    }

    $container = New-PesterContainer -Path '.\tests\tags.tests.ps1' -Data $Data
    Invoke-Pester -Container $container -Output Detailed

    ====
    Run locally to test the resources in main.bicep and
    see if the tags Owner, CostCenter, Environment and DeploymentDate are applied
.PARAMETER TemplatePath
    Path to the Bicep template to test
.PARAMETER MandatoryTags
    Array of tags that must be applied to the resources in the template
.PARAMETER TagParameterName
    Name of the parameter in the Bicep file that contains the tags
.PARAMETER TagModuleName
    Name of the module that contains the tag functions
.PARAMETER isRunningInteractive
    Set to true when running interactively (so outside of CICD)
    It will include Az bicep build and remove the JSON afterwards
.NOTES
    If a main.json file is present in the same directory as main.bicep,
    it will be deleted at the end of the script
    Works both locally as in Azure DevOps and GitHub Actions
    Created by Barbara Forbes
    @ba4bes
    https://4bes.nl
#>
param (
    [parameter(Mandatory=$true)]
    [string]$TemplatePath,
    [parameter(Mandatory=$true)]
    [array]$MandatoryTags,
    [parameter(Mandatory=$true)]
    [string]$TagParameterName,
    [parameter(Mandatory=$false)]
    [string]$TagModuleName,
    [parameter(Mandatory=$false)]
    [switch]$isRunningInteractive
    )
BeforeDiscovery {
    if ($isRunningInteractive){
        az Bicep build --file $TemplatePath --outfile $TemplatePath.Replace('.bicep', '.json')
    }
    $TemplatePath = $TemplatePath.Replace('.bicep', '.json')
    $maintemplate = Get-Content -Path $TemplatePath | ConvertFrom-Json
    $Resources = $maintemplate.resources

    if ($TagModuleName) {
        $TaggingResource = $Resources | Where-Object { $_.name -eq $TagModuleName }
    }
    # Collect all resources to be checked
    $ResourcesToCheck = New-Object System.Collections.ArrayList
    foreach ($Resource in $Resources) {
        # SubResources are searched because when using module, the default resource is a deployment.
        foreach ($SubResource in $Resource.properties.template.resources) {
            # Get the correct values if a parameter is used
            if ($SubResource.tags -eq "[parameters('$TagParameterName')]" ) {
                $SubResource.tags = $Resource.properties.parameters.$TagParameterName.value
            }
            # Get The correct values if a variable was used
            if ($SubResource.tags -eq "[variables('$TagParameterName')]" ) {
                $SubResource.tags = $maintemplate.variables.tags
            }
            # Get the correct values if a tagging module was used
            if ($SubResource.tags -like "*.outputs.Tags.value*" ) {
                $SubResource.tags = @{}

                foreach ($tag in ($TaggingResource.properties.template.parameters | Get-Member -Type NoteProperty)) {
                    $tagName = $tag.Name
                    if ($TaggingResource.properties.template.parameters.$tagName.defaultValue) {
                        $SubResource.tags.add($tagName, $TaggingResource.properties.template.parameters.$tagName.defaultValue)
                    }
                    else {
                        $SubResource.tags.add($tagName, $TaggingResource.properties.parameters.$tagName.value)
                    }
                }
            }
            $ResourcesToCheck.Add($SubResource)
        }
    }
    $ResourcesToCheckArray = $ResourcesToCheck.ToArray()
    # }
}

Describe 'Tags for <_.type>' -ForEach $ResourcesToCheckArray {
    BeforeDiscovery {
        $Resource = $_
    }
    Context "Start" -ForEach @{ Resource = $Resource } {
        It 'checking for tag <_>' -TestCases $MandatoryTags {

            $Resource.tags.$_ | Should -not -BeNullOrEmpty

        }

    }

}
AfterAll {
    if ($isRunningInteractive){
    Remove-Item $TemplatePath.Replace('.bicep', '.json')
    }

}