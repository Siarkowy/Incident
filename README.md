# Incident

Compact event dumper. Usage: `/!` [Wow 2.4.3]


## Synopsis

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


## Handler function `fn`

Event registration in form of `/! +<event>$ fn $` allows you to bind short
snippets of code that run when a specific event occurs in-game.

The following predefined locals are available in the event handler:

```
    self                Incident object itself.
    _                   Dummy variable.
    A ... Z             Consecutive event parameters.
```

## Installation

- Find the latest [release](https://github.com/SiarkowyDevKit/Incident/releases),
  download ZIP file from assets below & open the archive.
- Extract all folders from `Incident-<version>\` into your `Interface\AddOns\`.
- Restart WoW client & confirm the addon(s) are shown in character login screen.
