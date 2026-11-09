param([string] $Dist = '')
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
if (-not $Dist) { $Dist = Join-Path $BlogRoot 'dist' }
$failures = [Collections.Generic.List[string]]::new()
function Expect([bool] $ok, [string] $what) { if (-not $ok) { $failures.Add($what) } }
function Read-Page([string] $relative) { $p = Join-Path $Dist $relative; if (Test-Path -LiteralPath $p) { [IO.File]::ReadAllText($p) } else { $null } }

$entries = foreach ($post in Get-ChildItem (Join-Path $BlogRoot 'posts') -Filter *.spi -File) {
    $text = [IO.File]::ReadAllText($post.FullName)
    foreach ($m in [regex]::Matches($text, '(?s)slug = "([^"]+)".*?title = "([^"]+)".*?kind = page\.(\w+)')) {
        [pscustomobject]@{ Slug = $m.Groups[1].Value; Title = $m.Groups[2].Value; Kind = $m.Groups[3].Value; Post = $post.Name }
    }
}
Expect ($entries.Count -gt 0) "no entries found in posts/*.spi"
$fixed = 'index.html', 'style.css', 'rss.xml', 'articles/index.html', 'releases/index.html'
$expected = @($fixed) + @($entries | ForEach-Object { "$($_.Slug)/index.html" })
foreach ($page in $expected) { Expect (Test-Path -LiteralPath (Join-Path $Dist $page)) "missing $page" }
$present = @(Get-ChildItem $Dist -Recurse -File -Include *.html, *.xml, *.css | ForEach-Object { $_.FullName.Substring($Dist.Length + 1).Replace('\', '/') })
foreach ($page in $present | Where-Object { $_ -notin $expected -and $_ -ne 'tree.html' }) { Expect $false "unexpected $page (no post generates it; a stale file from an earlier build?)" }
foreach ($page in $expected | Where-Object { $_.EndsWith('.html') }) {
    $html = Read-Page $page
    if ($null -eq $html) { continue }
    Expect ($html.StartsWith('<!doctype html>') -and $html.EndsWith('</main></body></html>')) "$page lacks the shared layout"
}
$index = Read-Page 'index.html'; $articles = Read-Page 'articles/index.html'; $releases = Read-Page 'releases/index.html'
foreach ($e in $entries) {
    $shown = [Net.WebUtility]::HtmlEncode($e.Title)
    Expect ($index -and $index.Contains($shown)) "index.html does not list '$($e.Title)'"
    Expect ($articles -and ($articles.Contains($shown) -eq ($e.Kind -eq 'Article'))) "articles/index.html $(if ($e.Kind -eq 'Article') { 'misses' } else { 'wrongly lists' }) '$($e.Title)' ($($e.Kind))"
    Expect ($releases -and ($releases.Contains($shown) -eq ($e.Kind -eq 'Release'))) "releases/index.html $(if ($e.Kind -eq 'Release') { 'misses' } else { 'wrongly lists' }) '$($e.Title)' ($($e.Kind))"
}
$rss = Read-Page 'rss.xml'
$items = if ($rss) { ([regex]::Matches($rss, '<item>')).Count } else { 0 }
Expect ($items -eq $entries.Count) "rss.xml has $items items for $($entries.Count) entries"
if ($failures.Count) { $failures | ForEach-Object { "E2E-FAIL $_" }; throw "e2e.ps1 / $($failures.Count) check(s) failed over $Dist" }
"E2E-OK $($entries.Count) entries, $($expected.Count) pages, rss items $items"
