<#
Module Mixed by BarTender
	A Framework for making PowerShell Modules
	Version: 6.1.22
	Author: Adrian.Andersson
	Copyright: 2019 Domain Group

Module Details:
	Module: domainAwsPowershellTools
	Description: Bunch of scripts to help with Aws Powershell
	Revision: 1.0.0.1
	Author: Adrian.Andersson
	Company: Domain Group

Check Manifest for more details
#>

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

function get-instanceAmiDetails
{
    <#
        .SYNOPSIS
            get an ec2 instance image details
            
        .DESCRIPTION
            Get ec2 instance and ami details
            return an object
            
        .PARAMETER instanceId
            what instance do you need
            
        ------------
        .EXAMPLE
            get-instanceAmiDetails i-abc123456,i-xyz654321
        
        .EXAMPLE
            $instanceIds = @(
                'i-abc123456',
                'i-xyz654321'
            )
            get-instanceAmiDetails $instanceIds
            
      .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-15
            Created On Request
            
            
            Changelog:
                2019-03-15 - AA
                    - Initial Script
                    
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$instanceId
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $awsOwnerIds = @('801119661308')
        
    }   
    
    process{
        foreach($instId in $instanceId)
        {   
            try{
                $instance = $(Get-EC2Instance $instId -ErrorAction Stop).instances[0]
            }catch{
                $null
            }
            
            if($instance)
            {
            
                $image = Get-EC2Image -ImageId $instance.imageId
                $hash = @{
                    instanceId = $instance.InstanceId
                    instanceIsWindows = if($instance.Platform.Value){$true}else{$false}
                    instanceType = $instance.instanceType.Value
                    instanceLaunchDate = $(get-date $instance.LaunchTime)
                }
                if($image)
                {
                    $hash.amiName = $image.name
                    $hash.amiState = $image.state.value
                    $hash.amiAwsOwned = $(if($image.ownerid -in $awsOwnerIds){$true}else{$false})
                    $hash.amiCreationDate = $(get-date $image.creationdate)
                }else{
                    $hash.amiName = 'Unknown'
                    $hash.amiState = 'Unknown'
                    $hash.amiAwsOwned = 'Unknown'
                    $hash.amiCreationDate = 'Unknown'
                }
                [psCustomObject]$hash
            }else{
                write-warning "InstanceId: $instId not found"
            }
        }
        
    }
    
}

function remove-s3DeleteMarker
{
    <#
        .SYNOPSIS
            OopsiePerson - 'Help, I broked S3, I accidentally deleted all our stuff'
            DevOpsPerson - 'Dont panic, you have versioning enabled'
            
        .DESCRIPTION
            For when somoene accidentally marks an entire bucket with a delete marker
            MAKE SURE you have versioning enabled           
            
        .PARAMETER bucketname
            Name of the S3 bucket
        .PARAMETER prefix
            The s3 keyprefix to search
        .PARAMETER DaysToRewind
            How far back should we look for delete markers.
            I.e. How many days ago did this mistake happen
            Required so we don't remove versions that perhaps should be legitimately removed
        .EXAMPLE
            remove-s3DeleteMarker -bucketName 'mybucket' -prefix 'my/key/prefix'
            
            #### DESCRIPTION
            Remove any versions with delete markers within the default DaysToRewind (3)
            
        .NOTES
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
                    
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    PARAM(
        [Parameter(Mandatory=$true)]
        [Alias("bucket")]
        [string]$bucketname,
        [Parameter(Mandatory=$true)]
        [Alias("keyprefix")]
        [string]$prefix,
        [ValidateRange(1,180)]
        [int]$DaysToRewind = 3,
        [switch]$continue
        
    )
    begin{
        #Flip the days
        
        $days = 0 - $daysToRewind
        $backDate = $(get-date).AddDays( $days)
        write-verbose "Date to remove deleteMarker from : $($backdate)"
        write-verbose 'Getting S3 Version Data'
        #Get a subset of the data to validate the bucket is ok
        $versionData = Get-S3Version -BucketName $bucketName -Prefix $Prefix -MaxKey 2
        if(!($versiondata) -or (!$versiondata.versions) -or ($versiondata.versions.count -lt 1))
        {
            throw 'Unable to retrieve version info. Bucket could be wrong or versions unavailable'
        }
        $keymarker = $null
        $more = $True
        $page = 0
        $versions = @{}
        while($more -eq $true)
        {
            write-verbose "Getting versions from page:$page"
            $versionData = Get-S3Version -BucketName $bucketName -Prefix $Prefix -KeyMarker $keyMarker
            
            $versions."$page" = $versionData.Versions
            if($versionData.NextKeyMarker)
            {
                write-verbose 'More data, incrementing Page'
                $page++
                $keyMarker=$versionData.NextKeyMarker
            }else{
                write-verbose 'No more data'
                $more = $false
            }
            
        }
        $allVersions = $($versions.Values|ForEach-Object{$_})
        write-verbose "Found data for $($allVersions.count) versions"
        $Deleted = $allVersions | where-object{$_.IsDeleteMarker -eq $true -and $_.LastModified -gt $backDate}
        write-verbose "Found data for $($Deleted.count) versions with delete markers"
        if($allVersions.count -eq $Deleted.count)
        {
            throw 'Number of versions is equal to number of deletes. Does this bucket have versioning?'
        }
        
    }
    
    process{
        write-warning "$($deleted.count) items of $($allversions.count) total items will be deleted)"
        if(!$continue)
        {
            $confirmRead = read-host 'Are you sure about this? (y)'
            if($confirmRead -eq 'y')
            {
                $continue = $true
            }else{
                return
            }
            
        }
        if($continue)        
        {
            foreach($file in $deleted)
            {
                if ($PSCmdlet.ShouldProcess("Remove key: $($file.Key) `tVersion: $($file.versionId) ")) {
                    remove-S3Object -bucketName $file.bucketName -Key $file.Key -VersionId $file.versionId -Confirm:$false
                }
            }
        }
    }
}

