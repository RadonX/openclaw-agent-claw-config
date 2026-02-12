/**
 * telegram.mjs - Shared Telegram Bot API utilities
 * 
 * Do one thing well: token resolution and API calls.
 */

import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

/**
 * Read .env file and return key-value pairs
 */
export function readDotEnv(dotEnvPath) {
  try {
    const raw = fs.readFileSync(dotEnvPath, 'utf8');
    const out = {};
    for (const line of raw.split(/\r?\n/)) {
      const t = line.trim();
      if (!t || t.startsWith('#')) continue;
      const m = t.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
      if (!m) continue;
      let v = m[2] ?? '';
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.slice(1, -1);
      }
      out[m[1]] = v;
    }
    return out;
  } catch {
    return {};
  }
}

/**
 * Load bot token from OpenClaw config file
 */
export function loadTokenFromOpenClaw({ configPath, accountId }) {
  try {
    const p = configPath
      ? (configPath.startsWith('~') ? path.join(os.homedir(), configPath.slice(1)) : configPath)
      : path.join(os.homedir(), '.openclaw', 'openclaw.json');
    const json = JSON.parse(fs.readFileSync(p, 'utf8'));
    return json?.channels?.telegram?.accounts?.[accountId]?.botToken || null;
  } catch {
    return null;
  }
}

/**
 * Resolve bot token from multiple sources (priority order):
 * 1. Explicit token parameter
 * 2. Environment variables (TG_TOKEN, TELEGRAM_BOT_TOKEN)
 * 3. .env file in cwd
 * 4. OpenClaw config (if accountId provided)
 */
export function resolveToken({ token, accountId, configPath } = {}) {
  if (token) return token;
  
  const dotEnv = readDotEnv(path.join(process.cwd(), '.env'));
  const resolved = process.env.TG_TOKEN 
    || process.env.TELEGRAM_BOT_TOKEN 
    || dotEnv.TG_TOKEN 
    || dotEnv.TELEGRAM_BOT_TOKEN;
  
  if (resolved) return resolved;
  
  if (accountId) {
    return loadTokenFromOpenClaw({ configPath, accountId });
  }
  
  return null;
}

/**
 * Send a message via Telegram Bot API
 */
export async function sendMessage(token, { chatId, text, threadId, parseMode, silent }) {
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  const body = {
    chat_id: chatId,
    text,
    ...(threadId && { message_thread_id: threadId }),
    ...(parseMode && { parse_mode: parseMode }),
    ...(silent && { disable_notification: true }),
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });

  const json = await res.json().catch(() => ({}));
  
  if (!res.ok || json.ok !== true) {
    return { 
      ok: false, 
      error: json?.description || `HTTP ${res.status}`,
      raw: json 
    };
  }

  return {
    ok: true,
    messageId: json.result?.message_id,
    date: json.result?.date,
  };
}

/**
 * Get chat info via Telegram Bot API
 */
export async function getChat(token, chatId) {
  const url = `https://api.telegram.org/bot${token}/getChat`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ chat_id: chatId }),
  });

  const json = await res.json().catch(() => ({}));
  
  if (!res.ok || json.ok !== true) {
    return { 
      ok: false, 
      error: json?.description || `HTTP ${res.status}` 
    };
  }

  return { ok: true, chat: json.result };
}
