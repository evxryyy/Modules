# Buffer

a more simple way to write numbers/string/array/booleans, calling Read for any type without passing a offset value will return the last read:

```lua
  local Buffer = require(somewhere.Buffer)
  local ClassOfBuffer = Buffer.new() -> nil = 0 (auto allocate if out of bounds)
  Buffer:WriteI8(65)
  Buffer:WriteI8(65)
  Buffer:WriteI8(20)
  Buffer:WriteI8(65)
  Buffer:WriteI8(60)
  print(Buffer:ReadI8()) -> 60 (last inserted number)
  print(Buffer:ReadI8(2)) -> 20
```
