Incident
========

Compact event dumper. Usage: `/!` [Wow 2.4.3]

Syntax
------

```
/!
    +<event>
    +<event>$ fn $
    -<event>
    +all
    -all
    filter <string>
    output <no>
    start <name>
    stop
    toggle
```

- `+<event>` — Registers `<event>`.
- `+<event>$ body $` — Registers `<event>` with handler function.

> The handler will have predefined locals: `self` (=Incident), `_` (=dummy) and `A, B, C` through `Z`, which stand for consecutive event parameters.

- `-<event>` — Unregisters `<event>`.
- `+all` — Registers all events.
- `-all` — Unregisters all events.
- `filter <string>` — Sets filter to `<string>`.
- `output <no>` — Sets output to `ChatFrame<no>`.
- `start <name>` — Starts event capture with optional `<name>`.
- `stop` — Stops event capture.
- `toggle` — Toggles suspend mode on or off.
