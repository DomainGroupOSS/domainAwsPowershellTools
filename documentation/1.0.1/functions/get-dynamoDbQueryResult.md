---
external help file: domainAwsPowershellTools-help.xml
Module Name: domainAwsPowershellTools
online version:
schema: 2.0.0
---

# get-dynamoDbQueryResult

## SYNOPSIS
Execute a query against DynamoDB

## SYNTAX

```
get-dynamoDbQueryResult [-Tablename] <String> [-key] <String> [-awsRegion] <String> [-value] <String>
 [[-items] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Run a DynamoDB Query
Return some results

## EXAMPLES

### EXAMPLE 1
```
get-dynamoDbQueryResult -table my-dynamodb-table -key my-dynamodb-reference -value what-value-do-i-want -items 1
```

## PARAMETERS

### -Tablename
Name of the DynamoDB Table

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -key
Name of the table key to look at

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -awsRegion
Name of the awsRegion to use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -value
The value of the key we are looking for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -items
Number of items

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 5
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
Last-Edit-Date: 2018-09-05


Changelog:
    2018-09-05 - AA
        - Initial Script
        - This was a fun crash course in DynamoDB
        - Reverse-Engineered Mostafa's provided query to use the dotNet class objects over the AWS CLI
    2019-03-15 - AA
        - Rewrote to domainAwsPowershellTools

## RELATED LINKS
