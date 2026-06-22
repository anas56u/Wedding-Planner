$ErrorActionPreference = "Continue"

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
$modCount = 0

foreach ($file in $dartFiles) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
    $newLines = New-Object System.Collections.Generic.List[string]
    $changed = $false
    $inBlock = $false
    
    foreach ($rawLine in $lines) {
        if ($inBlock) {
            $newLines.Add($rawLine)
            if ($rawLine.Contains("*/")) { $inBlock = $false }
            continue
        }
        if ($rawLine.Contains("/*") -and -not $rawLine.Contains("*/")) {
            $inBlock = $true
            $newLines.Add($rawLine)
            continue
        }
        
        $trimLine = $rawLine.TrimStart()
        
        # Preserve doc comments
        if ($trimLine.StartsWith("///")) {
            $newLines.Add($rawLine)
            continue
        }
        
        # Find // outside of strings
        $insideStr = $false
        $strCh = [char]0
        $esc = $false
        $foundAt = -1
        
        $chars = $rawLine.ToCharArray()
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $c = $chars[$i]
            
            if ($esc) { $esc = $false; continue }
            
            if ($insideStr -and $c -eq [char]"\") {
                $esc = $true
                continue
            }
            
            if (-not $insideStr) {
                if ($c -eq [char]"'" -or $c -eq [char]'"') {
                    $insideStr = $true
                    $strCh = $c
                    continue
                }
                if ($c -eq [char]"/" -and ($i + 1) -lt $chars.Length -and $chars[$i+1] -eq [char]"/") {
                    if (($i + 2) -lt $chars.Length -and $chars[$i+2] -eq [char]"/") {
                        break  # doc comment
                    }
                    $foundAt = $i
                    break
                }
            } else {
                if ($c -eq $strCh) {
                    $insideStr = $false
                }
            }
        }
        
        if ($foundAt -ge 0) {
            $before = $rawLine.Substring(0, $foundAt).TrimEnd()
            if ($before.Length -eq 0) {
                $changed = $true
                continue  # skip whole comment line
            } else {
                $newLines.Add($before)
                $changed = $true
                continue
            }
        }
        
        $newLines.Add($rawLine)
    }
    
    if ($changed) {
        # Remove excess blank lines (3+ consecutive)
        $result = New-Object System.Collections.Generic.List[string]
        $bc = 0
        foreach ($l in $newLines) {
            if ([string]::IsNullOrWhiteSpace($l)) {
                $bc++
                if ($bc -le 2) { $result.Add($l) }
            } else {
                $bc = 0
                $result.Add($l)
            }
        }
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllLines($file.FullName, $result.ToArray(), $utf8NoBom)
        $modCount++
        Write-Output "MODIFIED: $($file.Name)"
    }
}

Write-Output "Done. Modified $modCount files."
