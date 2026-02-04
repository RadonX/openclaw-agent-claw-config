#!/usr/bin/env node
/**
 * tg-topic-ping.mjs
 *
 * Send a probe message to one or more Telegram forum topics (message_thread_id)
 * without relying on OpenClaw sessions.
 *
 * Usage:
 *   TG_TOKEN=xxxx node tg-topic-ping.mjs --chat -100123 --topics 66,80 --text "/status"
 *   TG_TOKEN=xxxx ./tg-topic-ping.mjs --chat -100123 --topics 66 --text "ping" --silent
 *   ./tg-topic-ping.mjs --account <accountId> --chat -100123 --topics 66,80 --text "/status"
 *
 * Notes:
 * - chat_id for supergroups is usually -100...
 * - topic id is Telegram's message_thread_id.
 */

const args = process.argv.slice(2);

function getArg(name, { required = false, defaultValue = undefined } = {}) {
  const i = args.indexOf(name);
  if (i === -1) {
    if (required) throw new Error(`Missing required arg: ${name}`);
    return defaultValue;
  }
  const v = args[i + 1];
  if (!v || v.startsWith('--')) throw new Error(`Missing value for arg: ${name}`);
  return v;
}

function hasFlag(name) {
  return args.includes(name);
}

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

function readDotEnv(dotEnvPath) {
  try {
    const raw = fs.readFileSync(dotEnvPath, 'utf8');
    const out = {};
    for (const line of raw.split(/\r?\n/)) {
      const t = line.trim();
      if (!t || t.startsWith('#')) continue;
      const m = t.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
      if (!m) continue;
      let v = m[2] ?? '';
      // strip surrounding quotes
      if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
        v = v.slice(1, -1);
      }
      out[m[1]] = v;
    }
    return out;
  } catch {
    return null;
  }
}

function tryLoadTokenFromOpenClawConfig({ configPath, accountId }) {
  try {
    const p = configPath
      ? (configPath.startsWith('~') ? path.join(os.homedir(), configPath.slice(1)) : configPath)
      : path.join(os.homedir(), '.openclaw', 'openclaw.json');
    const json = JSON.parse(fs.readFileSync(p, 'utf8'));
    const token = json?.channels?.telegram?.accounts?.[accountId]?.token;
    if (!token) return null;
    return token;
  } catch {
    return null;
  }
}

const dotEnv = readDotEnv(path.join(process.cwd(), '.env')) || {};
const accountId = getArg('--account', { defaultValue: '' });
const configPath = getArg('--openclaw-config', { defaultValue: '' });

let token = process.env.TG_TOKEN || process.env.TELEGRAM_BOT_TOKEN || dotEnv.TG_TOKEN || dotEnv.TELEGRAM_BOT_TOKEN;
if (!token && accountId) {
  token = tryLoadTokenFromOpenClawConfig({ configPath: configPath || null, accountId });
}

if (!token) {
  console.error('ERROR: missing token. Provide one of:');
  console.error('  - env: TG_TOKEN / TELEGRAM_BOT_TOKEN');
  console.error('  - .env: TG_TOKEN / TELEGRAM_BOT_TOKEN (in current dir)');
  console.error('  - or: --account <id> [--openclaw-config <path>] to read from ~/.openclaw/openclaw.json');
  process.exit(2);
}

const chat = getArg('--chat', { required: true });
const topicsRaw = getArg('--topics', { required: true });
const text = getArg('--text', { required: true });

const delayMs = Number(getArg('--delay-ms', { defaultValue: '350' }));
const parseMode = getArg('--parse-mode', { defaultValue: 'MarkdownV2' });
const disableNotification = hasFlag('--silent');

const topics = topicsRaw
  .split(',')
  .map(s => s.trim())
  .filter(Boolean)
  .map(s => Number(s))
  .filter(n => Number.isFinite(n));

if (topics.length === 0) {
  console.error('ERROR: --topics must contain at least one numeric topic id, e.g. 66,80');
  process.exit(2);
}

async function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function sendToTopic(topicId) {
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  const body = {
    chat_id: chat,
    message_thread_id: topicId,
    text,
    // parse_mode is optional; defaulting to MarkdownV2 is usually safe for /status
    parse_mode: parseMode,
    disable_notification: disableNotification,
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });

  const json = await res.json().catch(() => ({}));
  if (!res.ok || json.ok !== true) {
    const desc = json?.description || `HTTP ${res.status}`;
    return { ok: false, topicId, error: desc, raw: json };
  }

  return {
    ok: true,
    topicId,
    messageId: json.result?.message_id,
    date: json.result?.date,
  };
}

(async () => {
  const results = [];
  for (let idx = 0; idx < topics.length; idx++) {
    const t = topics[idx];
    const r = await sendToTopic(t);
    results.push(r);
    const status = r.ok ? 'OK' : 'FAIL';
    const extra = r.ok ? `message_id=${r.messageId}` : r.error;
    console.log(`[${status}] topic=${t} ${extra}`);

    if (idx < topics.length - 1) await sleep(delayMs);
  }

  const failed = results.filter(r => !r.ok);
  if (failed.length) process.exit(1);
})();
