function get-dynamoDbQueryResult
{

    <#
        .SYNOPSIS
            Execute a query against DynamoDB
            
        .DESCRIPTION
            Run a DynamoDB Query
            Return some results
            
        .PARAMETER Tablename
            Name of the DynamoDB Table

        .PARAMETER key
            Name of the table key to look at


        .PARAMETER awsRegion
            Name of the awsRegion to use

        .PARAMETER value
            The value of the key we are looking for
        
        .PARAMETER items
            Number of items

        .EXAMPLE
            get-dynamoDbQueryResult -table my-dynamodb-table -key my-dynamodb-reference -value what-value-do-i-want -items 1
                   
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-09-05
            
            
            Changelog:
                2018-09-05 - AA
                    - Initial Script
                    - This was a fun crash course in DynamoDB
                    - Reverse-Engineered Mostafa's provided query to use the dotNet class objects over the AWS CLI


                2019-03-15 - AA
                    - Rewrote to domainAwsPowershellTools
                    
                    
                    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string]$Tablename,
        [Parameter(Mandatory=$true)]
        [string]$key,
        [Parameter(Mandatory=$true)]
        [string]$awsRegion,
        [Parameter(Mandatory=$true)]
        [string]$value,
        [Parameter(Mandatory=$false)]
        [int]$items = 5

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"


        $regionName = $awsRegion
        
        $region = [Amazon.RegionEndpoint]::GetBySystemName($regionName)

        $dbClient = New-Object Amazon.DynamoDBv2.AmazonDynamoDBClient($region)
    }
    
    process{
        $req = New-object Amazon.DynamoDBv2.Model.QueryRequest
        $req.tableName = $tableName
        write-verbose "Invoking against table: $table"
        $req.KeyConditionExpression = "$key = :anything"
        $keyAttrObj = new-object Amazon.DynamoDBv2.Model.AttributeValue
        $keyAttrObj.S = $value
        write-verbose "Searching for value $($keyAttrObj.S)"
        $req.expressionAttributeValues = new-object 'System.Collections.Generic.Dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]'
        $req.expressionAttributeValues.add(':anything',$keyAttrObj.s)
        $req.limit = $items
        write-verbose "Limiting to $items resultCount"
        write-verbose "Executing the query"
        $qResult = $dbClient.query($req)
        $qItems = $qResult.items
        write-verbose "Found $($qItems.count) results"
        $i = 0
        foreach($result in $qItems)
        {
            $ht = @{}
            write-verbose "Parsing result for item $i"
            foreach($key in $result.keys)
            {
                $rValue = $result."$key"
                if($rValue.S)
                {
                    $ht."$key" = $rValue.S

                }elseIf($rValue.N){
                    $ht."$key" = $rValue.N
                }
            }
            $obj = [pscustomobject]$ht
            $obj
            write-verbose "Finished parsing value for item $i"
            $i++
            remove-item ht,obj,rValue -errorAction ignore
        }
        
    }
    
}