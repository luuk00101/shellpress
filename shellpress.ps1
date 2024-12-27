[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Statistics,
    
    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
    [string[]]$MarkdownFiles
)

function Create-Index {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SitePath,
        [Parameter(Mandatory=$true)]
        [array]$MarkdownFiles
    )
    
    $indexContent = "<html><head><title>Articles Index</title></head><body><h1>Articles</h1><ul>"
    
    foreach ($file in $MarkdownFiles) {
        $content = Get-Content $file.FullName -Raw
        $title = if ($content -match "^#\s+(.+)$") { $matches[1] } else { $file.BaseName }
        $date = $file.LastWriteTime.ToString("yyyy-MM-dd")
        $htmlFile = [System.IO.Path]::ChangeExtension($file.Name, "html")
        
        $indexContent += "<li><a href='$htmlFile'>$title</a> ($date)</li>"
    }
    
    $indexContent += "</ul></body></html>"
    $indexContent | Out-File -FilePath (Join-Path $SitePath "index.html") -Encoding UTF8
}

function Create-Stats {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SitePath,
        [Parameter(Mandatory=$true)]
        [array]$MarkdownFiles
    )
    
    $totalArticles = $MarkdownFiles.Count
    $totalWords = 0
    
    foreach ($file in $MarkdownFiles) {
        $content = Get-Content $file.FullName -Raw
        $words = ($content -split '\s+').Count
        $totalWords += $words
    }
    
    $statsContent = @"
<html>
<head><title>Site Statistics</title></head>
<body>
<h1>Site Statistics</h1>
<ul>
    <li>Total Articles: $totalArticles</li>
    <li>Total Words: $totalWords</li>
</ul>
</body>
</html>
"@
    
    $statsContent | Out-File -FilePath (Join-Path $SitePath "stats.html") -Encoding UTF8
}

function Convert-Markdown {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )
    
    $outputFile = Join-Path $OutputPath ([System.IO.Path]::ChangeExtension([System.IO.Path]::GetFileName($InputFile), "html"))
    
    try {
        & pandoc $InputFile -f markdown -t html -s -o $outputFile
        return $true
    }
    catch {
        Write-Error "Failed to convert $InputFile $_"
        return $false
    }
}


function Publish-Portal {
    [CmdletBinding()]
    param()
    
    # Create site directory if it doesn't exist
    $siteDir = Join-Path $PWD "site"
    if (-not (Test-Path $siteDir)) {
        New-Item -ItemType Directory -Path $siteDir | Out-Null
    }
    
    # Get markdown files
    if ($MarkdownFiles.Count -eq 0) {
        $mdFiles = Get-ChildItem -Filter "*.markdown"
    }
    else {
        $mdFiles = $MarkdownFiles | ForEach-Object { Get-Item $_ }
    }
    
    if ($mdFiles.Count -eq 0) {
        Write-Error "No markdown files found!"
        return
    }
    
    # Convert all markdown files
    foreach ($file in $mdFiles) {
        Write-Verbose "Converting $($file.Name)"
        Convert-Markdown -InputFile $file.FullName -OutputPath $siteDir
    }
    
    # Create index
    Write-Verbose "Creating index.html"
    Create-Index -SitePath $siteDir -MarkdownFiles $mdFiles
    
    # Create statistics if requested
    if ($Statistics) {
        Write-Verbose "Generating statistics"
        Create-Stats -SitePath $siteDir -MarkdownFiles $mdFiles
    }
    
    Write-Output "Portal generation completed successfully!"
}

Publish-Portal
