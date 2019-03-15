@{
  ModuleVersion = '1.0.1'
  RootModule = 'domainAwsPowershellTools.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('get-dynamoDbQueryResult','get-instanceAmiDetails','remove-s3DeleteMarker')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    builtBy = 'Adrian.Andersson'
    moduleRevision = '1.0.0.2'
    builtOn = '2019-03-15T12:08:27'
    PSData = @{
      
    }
    bartenderCopyright = '2019 Domain Group'
    pester = @{
      time = '00:00:00.9411480'
      codecoverage = 0
      passed = '100 %'
    }
    bartenderVersion = '6.1.22'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
  }
  GUID = 'ee86c040-17b9-4f8d-8b2c-c375eea6ba88'
  Description = 'Bunch of scripts to help with Aws Powershell'
  Copyright = '2019 Domain Group'
  CompanyName = 'Domain Group'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
