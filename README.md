Incident
========

Compact event dumper. Usage: `/!` [Wow 2.4.3]

Syntax
------

```
/!
    +<event>            Registers <event>.
    +<event>$ fn $      Registers <event> with handler function fn. Read more below.
    -<event>            Unregisters <event>.
    +all                Registers all events.
    -all                Unregisters all events.
    filter <string>     Sets filter to <string>.
    output <no>         Sets output to ChatFrame<no>. 0 for quiet mode.
    start <name>        Starts event capture with optional <name>.
    stop                Stops event capture.
    toggle              Toggles suspend mode on or off.
    list                List saved captures.
    purge               Drop all saved event captures.
```

Handler function `fn`
---------------------

The handler will have predefined locals:

- `self` — Incident,
- `_` — dummy variable,
- `A, B, C` through `Z` — consecutive event parameters.
