from __future__ import annotations

import json
from urllib import request, parse
from typing import Any, Dict, Optional


def bot_api_post(*, token: str, method: str, data: Dict[str, Any]) -> Dict[str, Any]:
    url = f"https://api.telegram.org/bot{token}/{method}"
    body = parse.urlencode({k: v for k, v in data.items() if v is not None}).encode("utf-8")
    req = request.Request(url, data=body, method="POST")
    with request.urlopen(req, timeout=30) as resp:
        raw = resp.read().decode("utf-8")
    j = json.loads(raw)
    if not j.get("ok"):
        raise RuntimeError(j)
    return j["result"]


def create_forum_topic(*, token: str, chat_id: str, name: str, icon_color: Optional[int] = None) -> Dict[str, Any]:
    return bot_api_post(token=token, method="createForumTopic", data={
        "chat_id": chat_id,
        "name": name,
        "icon_color": icon_color,
    })


def send_message(*, token: str, chat_id: str, text: str, message_thread_id: Optional[int] = None) -> Dict[str, Any]:
    return bot_api_post(token=token, method="sendMessage", data={
        "chat_id": chat_id,
        "text": text,
        "message_thread_id": message_thread_id,
        "disable_web_page_preview": True,
    })
