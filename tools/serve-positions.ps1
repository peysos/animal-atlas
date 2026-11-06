$root = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:8766/')
$listener.Start()
$utf8 = New-Object System.Text.UTF8Encoding($false)
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $ctx.Response.Headers.Add('Access-Control-Allow-Origin', '*')
    if ($ctx.Request.HttpMethod -eq 'POST' -and $ctx.Request.Url.AbsolutePath -eq '/positions') {
      $reader = New-Object System.IO.StreamReader($ctx.Request.InputStream, [System.Text.Encoding]::UTF8)
      $body = $reader.ReadToEnd()
      $reader.Close()
      [System.IO.File]::WriteAllText((Join-Path $root 'positions.json'), $body, $utf8)
      $bytes = [System.Text.Encoding]::UTF8.GetBytes('ok')
      $ctx.Response.ContentType = 'text/plain'
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $rel = $ctx.Request.Url.AbsolutePath.TrimStart('/')
      if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'full-animal-tree.html' }
      $path = Join-Path $root $rel
      if (Test-Path $path -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $ctx.Response.ContentType = 'text/html; charset=utf-8'
        $ctx.Response.ContentLength64 = $bytes.Length
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $ctx.Response.StatusCode = 404
      }
    }
    $ctx.Response.OutputStream.Close()
  } catch {
    break
  }
}
