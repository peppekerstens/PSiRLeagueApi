#class based

class League {
    # Properties
    [int]$id   #:15
    [bool]$isInitialized          #: True
    [array]$seasonIds              #: {58, 59}
    [string]$subscriptionStatus     #: Unknown
    [datetime]$createdOn              #: 13-8-2023 07:30:42
    [datetime]$lastModifiedOn         #: 17-8-2023 16:03:24
    [string]$createdByUserId        #: 64ce61ed-8f99-4fec-9d5e-e36e576bd1be
    [string]$lastModifiedByUserId   #: 64ce61ed-8f99-4fec-9d5e-e36e576bd1be
    [string]$createdByUserName      #: peppekerstens
    [string]$lastModifiedByUserName #: peppekerstens
    [string]$name                   #: pec
    [string]$nameFull               #: Platinum Endurance Championship
    [string]$description            #:
    [string]$descriptionPlain       #:
    [bool]$enableProtests         #: True
    [timespan]$protestCoolDownPeriod  #: 00:00:00.00000
    [timespan]$protestsClosedAfter    #: 01.00:00:00.00000
    [string]$protestsPublic         #: Hidden
    [string]$leaguePublic           #: PublicListed

    # Constructors
    League()
    {
    
}


class irLeagueApi {
    # Properties
    $baseURI = 'https://irleaguemanager.net/api' 

    # Constructors
    irLeagueApi()
    {
    }

    #Methods
    [string]login([])
    {
        return $this.Id.Split('/')[2]
    }

    [void] AddVirtualMachines([PSObject]$AzVm,[string]$NtlmNameReplace,[string]$VMSearchTemplate){
        $vms = $this.SessionHosts.GetVirtualMachine($AzVm,$NtlmNameReplace,$VMSearchTemplate)
        foreach ($vm in $vms){
            if ($this.VirtalMachines.VmId -notcontains $vm.VmId){ 
                $this.VirtualMachines += [PSVirtualMachine]::new($vm.Id,$vm.VmId,$vm.name,$vm.NumberOfCores,$vm.PowerState)
            }
        }
    }



    [string]GetResourceGroup()
    {
        return $this.Id.Split('/')[4]
    }

    [string]GetProvider()
    {
        return $this.Id.Split('/')[6]
    }

    [String]ToString()
    {
        return $this.Id
    }

    #Gets cores to start in the depthfirst modus 
    #in this modus, only a session reserve of one host total is in place. when below this threshlod, a new host is started/undrained
    [void]DepthFirstCoresToStart() {
        $SessionReserve = $this.GetMaxSessionLimit() *  (1 / $this.SessionThreshold)
        $HostActiveSessionReserve = $this.GetActiveSessionReserve()
        if ($HostActiveSessionReserve -lt $SessionReserve){
            $this.CoresToStart = [math]::Ceiling($this.GetMaxSessionLimit() / $this.SessionThresholdPerCPU) #just start one host
        }Else{
            $this.CoresToStart = 0
        }
    }
}