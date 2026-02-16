# Notify Plugin

Desktop notification when OpenCode goes idle (task complete, waiting for input, etc.).

## What It Does

Listens for the `session.idle` event and fires a `notify-send` notification on Linux.
Useful when you kick off a long-running task and switch to another window.

## Setup

Create `.opencode/plugins/notify.js` in your project (or globally in `~/.config/opencode/plugins/`):

```js
export default function notifyPlugin() {
  return {
    name: "notify",
    subscribe: ["session.idle"],
    async handler(event) {
      const title = "OpenCode";
      const body = event.message ?? "Session is idle";
      const { execFile } = await import("node:child_process");
      execFile("notify-send", [title, body], (err) => {
        if (err) console.error("notify-send failed:", err.message);
      });
    },
  };
}
```

Then add it to your `opencode.json`:

```jsonc
{
  "plugin": ["./plugins/notify.js"]
}
```

## Requirements

- `notify-send` (part of `libnotify-bin`, installed by `bootstrap-system.sh`)
- A running notification daemon (standard on GNOME/KDE)

## macOS Alternative

Replace the `execFile` call with:

```js
execFile("osascript", ["-e", `display notification "${body}" with title "${title}"`]);
```
