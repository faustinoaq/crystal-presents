## Concurrency primitives and non-blocking IO

```playground
require "http/client"

channel = Channel(String).new

spawn do
  channel.send(HTTP::Client.get("http://example.com").body)
end

spawn do
  channel.send(HTTP::Client.get("http://ruby.org").body)
end

2.times do
  channel.receive
end
```

Note:
TBD: unable to puts channel.receive due to bug in output playground (?)