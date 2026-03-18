#!/usr/bin/env python3
"""
Fetch a URL via Cloudflare Browser Rendering and extract readable text.

Usage:
  python3 fetch_and_extract.py <url> [--markdown]

Environment variables:
  CLOUDFLARE_ACCOUNT_ID
  CLOUDFLARE_BR_TOKEN

Options:
  --markdown   Use /markdown endpoint instead of /content (returns Markdown directly)
"""

import sys
import os
import re
import json
import urllib.request
import urllib.error


def get_credentials():
    account_id = os.environ.get("CLOUDFLARE_ACCOUNT_ID")
    token = os.environ.get("CLOUDFLARE_BR_TOKEN")
    if not account_id or not token:
        print("Error: Set CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_BR_TOKEN environment variables.", file=sys.stderr)
        sys.exit(1)
    return account_id, token


def fetch(url: str, use_markdown: bool = False) -> str:
    account_id, token = get_credentials()
    endpoint = "markdown" if use_markdown else "content"
    api_url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/browser-rendering/{endpoint}"

    payload = json.dumps({
        "url": url,
        "rejectResourceTypes": ["image", "media", "font"]
    }).encode("utf-8")

    req = urllib.request.Request(
        api_url,
        data=payload,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    if not data.get("success"):
        print("API error:", data, file=sys.stderr)
        sys.exit(1)

    return data.get("result", "")


def extract_text(html: str) -> str:
    """Extract readable text from rendered HTML."""
    # Try WeChat article content area first
    match = re.search(r'id="js_content"[^>]*>(.*?)</div>', html, re.DOTALL)
    if match:
        raw = re.sub(r'<[^>]+>', '', match.group(1))
        return re.sub(r'\s+', ' ', raw).strip()

    # Fall back: extract all paragraph text
    paras = re.findall(r'<p[^>]*>(.*?)</p>', html, re.DOTALL)
    texts = []
    for p in paras:
        t = re.sub(r'<[^>]+>', '', p).strip()
        if len(t) > 20:
            texts.append(t)
    return "\n\n".join(texts)


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(1)

    url = args[0]
    use_markdown = "--markdown" in args

    result = fetch(url, use_markdown=use_markdown)

    if use_markdown:
        print(result)
    else:
        print(extract_text(result))


if __name__ == "__main__":
    main()
