
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