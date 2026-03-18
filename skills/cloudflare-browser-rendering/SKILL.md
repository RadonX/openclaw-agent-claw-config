---
name: cloudflare-browser-rendering
description: Fetch fully JS-rendered web page content via Cloudflare Browser Rendering API (headless Chromium on Cloudflare edge). Use when you need to read pages that require JavaScript execution to render content — including WeChat Official Account articles (mp.weixin.qq.com), SPAs, and other JS-heavy sites that plain HTTP fetch cannot handle. Supports: full HTML content, markdown extraction, screenshots, PDF generation, and link extraction. Requires a Cloudflare account with Browser Rendering enabled and a valid API token stored in SECRETS.md.
---

# Cloudflare Browser Rendering

Cloudflare Browser Rendering runs a headless Chromium instance on Cloudflare edge nodes and returns fully rendered page content.

## Credentials

Load from `SECRETS.md`:
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_BR_TOKEN` (Browser Rendering API token, requires `Browser Rendering:Edit` permission)

## Endpoints

Base URL: `https://api.cloudflare.com/client/v4/accounts/{account_id}/browser-rendering/`

| Endpoint | Returns |
|----------|---------|
| `POST /content` | Full rendered HTML |
| `POST /markdown` | Markdown-formatted page content |
| `POST /screenshot` | PNG screenshot (base64) |
| `POST /pdf` | PDF (base64) |
| `POST /links` | Array of all links on the page |

## Basic Usage

```bash
curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/browser-rendering/content" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://mp.weixin.qq.com/s/ARTICLE_ID",
    "rejectResourceTypes": ["image", "media", "font"]
  }'
```

Use `rejectResourceTypes` to skip images/media for faster responses when only text is needed.

> **Note:** `waitFor` is not a supported parameter and will cause a 400 error.

## Extracting Article Text

After fetching HTML from `/content`, parse with Python:

```python
import json, re

with open('response.json') as f:
    data = json.load(f)

html = data.get('result', '')

# Extract main content
match = re.search(r'id="js_content"[^>]*>(.*?)</div>', html, re.DOTALL)
if match:
    text = re.sub(r'<[^>]+>', '', match.group(1))
    text = re.sub(r'\s+', ' ', text).strip()
    print(text)
```

See `scripts/fetch_and_extract.py` for a ready-to-use script.

## Use Cases

- **WeChat articles**: Works — headless Chromium executes JS and loads `cgiData` ✅
- **SPAs / React apps**: Works — JS rendering is fully executed
- **Login-required pages**: Pass cookies via `cookies` parameter (array of `{name, value, domain}`)
- **Screenshots for visual snapshots**: Use `/screenshot` endpoint

## Cookies (for login-gated pages)

```json
{
  "url": "https://example.com/protected",
  "cookies": [
    {"name": "session", "value": "abc123", "domain": "example.com"}
  ]
}
```

## References

- `references/api-params.md` — Full parameter reference for all endpoints
