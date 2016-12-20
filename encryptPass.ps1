$KeyFile = "<Full Path to folder>\AES.key"
$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$PasswordFile = "<Full Path to folder>\Password.txt"
$Key = Get-Content $KeyFile
$Password = "<Password>" | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile