$CLIENT_PATH="$env:USERPROFILE/.runelite/logs/client.log"
$LAUNCHER_PATH="$env:USERPROFILE/.runelite/logs/launcher.log"
if (-not(Test-Path -Path "$CLIENT_PATH" -PathType Leaf)) {
	Write-Host "client.log not found."
	exit -1
}

if (-not(Test-Path -Path "$LAUNCHER_PATH" -PathType Leaf)) {
	Write-Host "launcher.log not found"
	exit -1
}

$FORM_BOUNDARY = [System.Guid]::NewGuid().ToString();
$LF = "`r`n"

$CLIENT_B = [System.IO.File]::ReadAllBytes($CLIENT_PATH)
$CLIENT_S = [System.Text.Encoding]::GetEncoding("UTF-8").GetString($CLIENT_B)
$LAUNCHER_B = [System.IO.File]::ReadAllBytes($LAUNCHER_PATH)
$LAUNCHER_S = [System.Text.Encoding]::GetEncoding("UTF-8").GetString($LAUNCHER_B)

$BODY = (
	"--$FORM_BOUNDARY",
	"Content-Disposition: form-data; name=`"file[0]`"; filename=`"client.log`"",
	"Content-Type: application/octet-stream$LF",
	$CLIENT_S,
	"--$FORM_BOUNDARY",
	"Content-Disposition: form-data; name=`"file[1]`"; filename=`"launcher.log`"",
	"Content-Type: application/octet-stream$LF",
	$LAUNCHER_S,
	"--$FORM_BOUNDARY--$LF"
) -join $LF
Write-Host "$BODY"

$WEBHOOK = "https://api.runelite.net/autologs"
Invoke-RestMethod -Uri $WEBHOOK -Method Post -ContentType "multipart/form-data; boundary=`"$FORM_BOUNDARY`"" -Body $BODY
