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
