param(
  [string]$Project = "geral",
  [string]$Title = "task",
  [string]$Summary = ""
)

$vault = "SecoundBrain"
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH-mm"
$slug = ($Title.ToLower() -replace '[^a-z0-9\- ]', '' -replace '\s+', '-')
$path = "projects/$Project/$date-$time-$slug.md"

$content = @"
---
title: $Title
type: worklog
project: $Project
tags:
  - cursor
  - memory
  - $Project
created: $date
updated: $date
---

# $Title

## Summary
$Summary

## Related
- [[index-$Project]]
"@

obsidian vault="$vault" create path="$path" content="$content"
obsidian vault="$vault" append path="indexes/index-$Project.md" content="`n- [[$date-$time-$slug]]"