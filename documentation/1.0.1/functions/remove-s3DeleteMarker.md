---
external help file: domainAwsPowershellTools-help.xml
Module Name: domainAwsPowershellTools
online version:
schema: 2.0.0
---

# remove-s3DeleteMarker

## SYNOPSIS
OopsiePerson - 'Help, I broked S3, I accidentally deleted all our stuff'
DevOpsPerson - 'Dont panic, you have versioning enabled'

## SYNTAX

```
remove-s3DeleteMarker [-bucketname] <String> [-prefix] <String> [[-DaysToRewind] <Int32>] [-continue] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
For when somoene accidentally marks an entire bucket with a delete marker
MAKE SURE you have versioning enabled

## EXAMPLES

### EXAMPLE 1
```
remove-s3DeleteMarker -bucketName 'mybucket' -prefix 'my/key/prefix'
```

#### DESCRIPTION
Remove any versions with delete markers within the default DaysToRewind (3)

## PARAMETERS

### -bucketname
Name of the S3 bucket

```yaml
Type: String
Parameter Sets: (All)
Aliases: bucket

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -prefix
The s3 keyprefix to search

```yaml
Type: String
Parameter Sets: (All)
Aliases: keyprefix

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysToRewind
How far back should we look for delete markers.
I.e.
How many days ago did this mistake happen
Required so we don't remove versions that perhaps should be legitimately removed

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -continue
{{Fill continue Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson
Company: Domain Group
Last-Edit-Date: 2018/08/14


Changelog:
    2018/08/14 - AA
        
        - Initial Script
        - Added DaysToRewind after feedback
        - Fixed pagination issue
        - Added continue switch to proceed
    2019-03-15 - AA
        - Rewrote to domainAwsPowershellTools

## RELATED LINKS
