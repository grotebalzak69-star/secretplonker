$bestandsnaam = "test.txt"
$url = "http://10.102.72.18:5000/upload" 

# 1. Zoek het bestand
$gevondenBestand = Get-ChildItem -Path $env:USERPROFILE -Filter $bestandsnaam -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($gevondenBestand) {
    Write-Host "Bestand gevonden: $($gevondenBestand.FullName)"
    
    # 2. Maak een unieke scheidingslijn (boundary)
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileBytes = [System.IO.File]::ReadAllBytes($gevondenBestand.FullName)
    $fileEnc = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($fileBytes)

    # 3. Bouw de verplichte HTTP Multipart Body op
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"$($gevondenBestand.Name)`"",
        "Content-Type: application/octet-stream",
        "",
        $fileEnc,
        "--$boundary--"
    ) -join "`r`n"

    # 4. Verstuur het verzoek
    Invoke-RestMethod -Uri $url -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyLines
    
    Write-Host "Upload succesvol!"
} else {
    Write-Host "Bestand '$bestandsnaam' niet gevonden."
}
