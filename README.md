# Shellpress

A PowerShell-based static site generator that converts markdown files into a simple HTML website.

## Features

- Converts markdown files to HTML using Pandoc
- Generates an index page with links to all articles
- Shows article titles and last modified dates
- Optional statistics page showing total articles and word count
- Simple and lightweight

## Prerequisites

- PowerShell
- Pandoc (must be installed and accessible in your PATH)

## Usage

Basic usage to convert all markdown files in the current directory:

```powershell
.\shellpress.ps1
```

Convert specific markdown files:

```powershell
.\shellpress.ps1 article1.markdown article2.markdown
```

Generate with statistics page:

```powershell
.\shellpress.ps1 -Statistics
```

## Output

The script creates a `site` directory containing:

- Generated HTML files from your markdown
- An index.html file listing all articles
- A stats.html file (if -Statistics switch is used)

## Notes

- Markdown files should have a title in the format `# Title` at the start
- If no title is found, the filename will be used instead
- The site directory is created in the current working directory
