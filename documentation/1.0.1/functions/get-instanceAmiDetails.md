---
external help file: domainAwsPowershellTools-help.xml
Module Name: domainAwsPowershellTools
online version:
schema: 2.0.0
---

# get-instanceAmiDetails

## SYNOPSIS
get an ec2 instance image details

## SYNTAX

```
get-instanceAmiDetails [-instanceId] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Get ec2 instance and ami details
return an object

## EXAMPLES

### EXAMPLE 1
```
get-instanceAmiDetails i-abc123456,i-xyz654321
```

### EXAMPLE 2
```
$instanceIds = @(
```

'i-abc123456',
    'i-xyz654321'
)
get-instanceAmiDetails $instanceIds

## PARAMETERS

### -instanceId
what instance do you need

------------

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2019-03-15
Created On Request


Changelog:
    2019-03-15 - AA
        - Initial Script

## RELATED LINKS
