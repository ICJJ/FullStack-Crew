#!/usr/bin/env pwsh
<#
.SYNOPSIS
    FullStack-Crew Agent 文件健康检查
.DESCRIPTION
    检查所有 .agent.md 文件的 YAML frontmatter 完整性、tools 列表有效性、agents 交叉引用正确性
#>

$ErrorActionPreference = "Stop"
$script:errors = 0
$script:warnings = 0

$agentDir = Split-Path $PSScriptRoot -Parent
$agentFiles = Get-ChildItem -Path $agentDir -Filter "*.agent.md"

Write-Host "=== FullStack-Crew Agent Validator ===" -ForegroundColor Cyan
Write-Host "Scanning: $agentDir"
Write-Host "Found $($agentFiles.Count) agent files`n"

foreach ($file in $agentFiles) {
    $content = Get-Content $file.FullName -Raw
    $name = $file.BaseName -replace '\.agent$', ''
    Write-Host "[$name]" -ForegroundColor Yellow

    # Check YAML frontmatter exists
    if ($content -notmatch '^---\r?\n') {
        Write-Host "  ERROR: Missing YAML frontmatter" -ForegroundColor Red
        $script:errors++
        continue
    }

    # Extract frontmatter
    if ($content -match '(?s)^---\r?\n(.*?)\r?\n---') {
        $frontmatter = $Matches[1]
    } else {
        Write-Host "  ERROR: Malformed YAML frontmatter (missing closing ---)" -ForegroundColor Red
        $script:errors++
        continue
    }

    # Check required fields
    if ($frontmatter -notmatch 'description:') {
        Write-Host "  ERROR: Missing 'description' field" -ForegroundColor Red
        $script:errors++
    } else {
        Write-Host "  OK: description" -ForegroundColor Green
    }

    if ($frontmatter -notmatch 'tools:') {
        Write-Host "  ERROR: Missing 'tools' field" -ForegroundColor Red
        $script:errors++
    } else {
        Write-Host "  OK: tools" -ForegroundColor Green
    }

    # Check agents cross-reference (only for orchestrator)
    if ($name -eq 'orchestrator' -and $frontmatter -match 'agents:\s*\[(.+?)\]') {
        $declaredAgents = $Matches[1] -split ',\s*'
        $crossRefOk = $true
        foreach ($agent in $declaredAgents) {
            $agent = $agent.Trim()
            $agentFile = Join-Path $agentDir "$agent.agent.md"
            if (-not (Test-Path $agentFile)) {
                Write-Host "  ERROR: Referenced agent '$agent' not found ($agent.agent.md)" -ForegroundColor Red
                $script:errors++
                $crossRefOk = $false
            }
        }
        if ($crossRefOk) {
            Write-Host "  OK: agents cross-reference ($($declaredAgents.Count) agents)" -ForegroundColor Green
        }
    }

    # Check Self-Learning Protocol section exists
    if ($content -notmatch '## Self-Learning Protocol') {
        Write-Host "  WARN: Missing '## Self-Learning Protocol' section" -ForegroundColor DarkYellow
        $script:warnings++
    } else {
        Write-Host "  OK: Self-Learning Protocol" -ForegroundColor Green
    }

    # Check Completion Status Protocol
    if ($content -notmatch '(✅ DONE|⚠️ DONE_WITH_CONCERNS|🚫 BLOCKED|❓ NEEDS_CONTEXT)') {
        Write-Host "  WARN: Missing Completion Status Protocol" -ForegroundColor DarkYellow
        $script:warnings++
    } else {
        Write-Host "  OK: Completion Status" -ForegroundColor Green
    }

    Write-Host ""
}

# Check VERSION file
$versionFile = Join-Path $agentDir "VERSION"
if (Test-Path $versionFile) {
    $version = (Get-Content $versionFile -Raw).Trim()
    Write-Host "[VERSION] $version" -ForegroundColor Green
} else {
    Write-Host "[VERSION] WARN: VERSION file not found" -ForegroundColor DarkYellow
    $script:warnings++
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Errors:   $script:errors" -ForegroundColor $(if ($script:errors -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $script:warnings" -ForegroundColor $(if ($script:warnings -gt 0) { "DarkYellow" } else { "Green" })

if ($script:errors -gt 0) {
    Write-Host "`nValidation FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nValidation PASSED" -ForegroundColor Green
    exit 0
}
