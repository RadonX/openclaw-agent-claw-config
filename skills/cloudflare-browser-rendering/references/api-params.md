# Cloudflare Browser Rendering — API Parameter Reference

## Common Parameters (all endpoints)

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | string (required) | Page URL to render |
| `rejectResourceTypes` | array | Resource types to block: `"image"`, `"media"`, `"font"`, `"stylesheet"`, `"script"` |
| `cookies` | array of objects | Inject cookies: `[{name, value, domain, path?, secure?, httpOnly?}]` |
| `headers` | object | Extra HTTP headers to send with the page request |
| `viewport` | object | `{width, height}` — default 1280×720 |
| `userAgent` | string | Override User-Agent string |

> ⚠️ `waitFor` is NOT a supported parameter. Omit it.

## Endpoint-Specific Parameters

### `/content`
Returns full rendered HTML as a string in `result`.

### `/markdown`
Returns Markdown-formatted content in `result`. Good for LLM ingestion — cleaner than parsing HTML.

### `/screenshot`
Returns base64-encoded PNG in `result`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `screenshotOptions` | object | `{fullPage: bool, clip: {x,y,width,height}}` |

### `/pdf`
Returns base64-encoded PDF in `result`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `pdfOptions` | object | `{format: "A4", printBackground: bool, margin: {top,bottom,left,right}}` |

### `/links`
Returns array of `{href, text}` objects in `result`.

## Response Format

```json
{
  "success": true,
  "result": "<content>",
  "errors": [],
  "messages": []
}
```

On error, `success` is `false` and `errors` contains details.

## Performance Tips

- Block unnecessary resources with `rejectResourceTypes: ["image", "media", "font"]` to speed up fetches
- Use `/markdown` over `/content` when you only need readable text — avoids HTML parsing
- Cloudflare edge nodes are globally distributed; latency is generally low
