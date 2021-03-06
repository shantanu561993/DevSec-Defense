
<#
.SYNOPSIS
Outputs the designer of your LinkLayer chipset based on the IEEE Organizationally Unique Identifier (OUI).  


.DESCRIPTION
This script returns the designer of your interface's LinkLayer chipset based on the IEEE Organizationally Unique Identifier (OUI). 
Typically the first 3 bytes of a unicast link layer address form the OUI. 

.PARAMETER ShowHidden
If specified, empty layers and discard layers are included in the
results. The default behavior is to omit these layers from the result
set.

.INPUTS
None

.OUTPUTS
The script outputs test showing the contents of Get-NetIPAddress, but modifed.

.NOTES
Requires Windows 8 or later.

#>


####################################
#Arrays to store and parse interface and organization information
${AD`A`PtErS} = @()
${Or`ganIzA`T`i`oN} = @()
${L`inE} = @()

####################################
#Services we're getting the OUI information from.
${Or`iGIN`sEr`Vi`Ce} = "http://standards.ieee.org/develop/regauth/oui/oui.txt"

####################################
#Detect Internet connectivity
${isCOn`N`E`CtED} = ${f`AlsE}
${c`oNNectiv`ITY} = Get-NetConnectionProfile

####################################
#If($Connectivity.IPv4Connectivity -eq "Internet")
#Using the enum to work-around potential localization 
if(${COn`NE`cT`iv`iTY}.IPv4Connectivity -eq 4)
{
    ${IS`CO`NnECt`Ed} = ${t`RUE}
}


####################################
#Save the cachefile locally      
if(${isc`on`NEc`Ted} -eq ${tR`uE})
{   
	${dOWnLoA`D`ER} = New-Object System.Net.WebClient
    ${sERv`IC`erE`co`Rds} = "http://standards.ieee.org/develop/regauth/oui/oui.txt"
    ${LoC`ALRECO`R`ds} = New-Item "$env:TEMP\oui.txt" -ItemType file -Force
    ${DOw`N`lOADeR}.DownloadFile(${SErvi`c`E`ReCorDs},${LoCa`L`Re`cOR`dS})
}

####################################
#Get and add OUI for each Adapter if cachefile exists
${Is`CacHeD} = Get-ChildItem ${ENv:`T`EMP}
if(${Is`Ca`CHED}.Name -contains "oui.txt")
{
    ${A`DaP`TeRS} = Get-NetAdapter

    if(${adaP`T`ErS})
    {
        foreach (${A`da`PtER} in ${aDAP`T`ERs})
        {
            ${N`Et`wORKAd`Dr`eSs} = ${aDA`pt`Er}.NetworkAddresses
            ${o`Ui} = ${NetWOR`KAd`d`RE`ss}.SubString(0,6)

            if(${o`Ui})
            {
                ${or`g`ANIzAtIon} = Select-String -Pattern ${o`Ui} -Path "$env:TEMP\oui.txt"
        
                if(${Or`Gan`izATION})
                {
                    ${Or`ga`NIZAT`ioN} = [regex]::split(${Or`G`AnIzaT`Ion}, '\t')
                    ${temP`ST`R`ING} = ${O`R`g`ANiZATion}[2]
                }
                else 
                {
                    ####################################
                    #Check a few patterns in the header of the file to ensure no corruption 
                    ${pAT`Te`RN} = Select-String -Pattern "company_id" -Path "$env:TEMP\oui.txt"
                    if(${P`A`TTERN})
                    {
                        ${te`m`pSTri`Ng} = "The OUI is not registered with the IEEE"
                    }
                    else
                    {
                        Write-Error "Failed lookup: Improper cached file."
                    }
                }
                ${a`d`ApTEr} | Add-Member -MemberType NoteProperty -Name "OUI" -Value ${temp`S`T`RIng} 
            }
        }


        ####################################
        #Output all adapters
        ${a`d`Ap`TERs} | Format-Table @{Expression = {${_}.Name};Label = "Name";width = 25},
            @{Expression = {${_}.OUI};Label = "OUI";width = 50}
    }
    else
    {
        Write-Error "Failed lookup: No network adapters are on the system."
    }
}

else
{
    Write-Error "Failed lookup: No connectivity or cached file."
}
