if($cred -eq $null){$cred = Get-Credential} # Highly advise you create an account in CUCM with AXL previliges

function getDeviceProfile {
   param ([Parameter(Mandatory)][String]$udp)
   [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$TRUE}


try{
   <#Removing Device Profile#>
   
$axl =@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/12.5">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:removeDeviceProfile sequence="?">
         <!--You have a CHOICE of the next 2 items at this level-->
         <name>$udp</name>
         <!--<uuid>?</uuid>-->
      </ns:removeDeviceProfile>
   </soapenv:Body>
</soapenv:Envelope>
"@
$Result = Invoke-WebRequest -ContentType "text/xml;charset=UTF-8" -Headers @{SOAPAction="CUCM:DB ver=12.5"; Accept="Accept: text/*"} -Body $axl -Uri https://CUCM_IP_ADDRESS:8443/axl/ -Method Post -Credential $cred
$content = [xml]$Result.Content
$devices = $content.Envelope.body.getDeviceProfileResponse.return.deviceProfile.name
$deleted = $user + " - DELETED"
write-host "****" + $deleted + "*****"

} catch{
write-host "$devices not deleted"
}

}



#You'll need to create a CSV with username property to target (you can do this with a text file too, just make sure you change the syntax)

$file = Import-Csv -Path "Your seed file location" | select -ExpandProperty username

foreach($profile in $file){
<#
# Target the user device profile you need to delete --> This is assuming you have an standard on building these
# line 46 assumes you standardized naming convention by username_8865 for a Cisco 8865 IP phone, you can delete other device profiles in your environment too
#>
$udp = $profile + "_8865"
getDeviceProfile -user $udp

    
}
