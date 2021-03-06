## Desc: Simple Test-Connection Script - pings hosts in servers.txt file - stUpDown
## Auth: Drew D. Lenhart
## http://www.drewlenhart.com
## 08/04/15

##Declare file##
$ServerListFile = "servers.txt"   
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
$LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Outputreport = "" 

##EMAIL function##

function sendMail($datestamp){
    ##Use GMAILs free smtp services, must use port 587
    $smtpServer = "smtp.gmail.com" 
    $srvPort = 587
    $smtpFrom = "youremail@gmail.com" 
    $smtpTo = "to email address" 
    $messageSubject = "Ping Script Results - $datestamp"
    $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
    $message.Subject = $messageSubject 
    $message.IsBodyHTML = $true 
    $message.Body = "<html><head></head><body>" 
    $message.Body += Get-Content Logs\updown.htm
    $message.Body += "</body></html>"
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $srvPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential("gmail username without @gmail.com", "gmail password") 
    ##Send message
    $smtp.Send($message)
}

##Update Database through API

function run_api($server, $stat, $time){
    $curl = curl --data "server=$server&status=$stat&time=$time" http://localhost/api/
    ##Dont forget to change the url to match your configuration!
}

##Iterate through each hostname in servers.txt#

$failCount = 0

$Outputreport = "<h3>Ping Stats:</h3>"
$Outputreport += "<table><tr style='background-color: grey; color: white'><td>Hostname</td><td>Status</td></tr>"

foreach ($Server in $ServerList) { 
    if (test-Connection -ComputerName $Server -Count 2 -Quiet ) {  
        #show some status in console
        echo "$Server is pingable"
        run_api $server "yes" $LogTime
        $Outputreport += "<tr><td>$Server</td><td style='background-color: green; color: white'>ONLINE</td></tr>"
    } else { 
        #show some status in console
        echo "$Server seems dead Jim"
        run_api $server "no" $LogTime
        $Outputreport += "<tr><td>$Server</td><td style='background-color: red'>OFFLINE</td></tr>"
        $failCount = $failCount + 1
    }     
} 

$Outputreport += "</table>"
##Save results to .html file for e-mail
$Outputreport | out-file Logs\updown.htm


##If the counter is greater than 1, send failure email

if ($failCount -ge 1) {
    sendMail "$LogTime"
}