Get Buffer: [Buffer](https://create.roblox.com/store/asset/89352568093372/Buffer)

A better Buffer Writer/Reader Module

Learn more about Buffer: [buffer-library](https://create.roblox.com/docs/fr-fr/reference/engine/libraries/buffer)

Allowed Type:

-   Strings
-   Numbers
-   Booleans
-   Array (String,Numbers,Booleans only)

## Get Started

=== "Code"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local BufferModule = require(ReplicatedStorage.Buffer)

        local _buffer = BufferModule.new(0) --> (auto allocate is allowed in this module)
        _buffer:WriteF64(math.huge) -- will automaticly allocate 8 byts
        print(_buffer:ReadF64(0)) -- return inf
    ```

## Writing array

=== "Code"
    ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local BufferModule = require(ReplicatedStorage.Buffer)

        local _buffer = BufferModule.new(0) --> (auto allocate is allowed in this module)

        --[[
            :WriteArray()
            the first argument is a table of value that want to be written
            and the second argument is a table of all types in order ex
            25 = I8,
            "hi" = String,
            math.huge = "F64"
        ]]
        _buffer:WriteArray({25,"Hi",math.huge},{"I8","String","F64"})
        --[[
            To read values you need to call the exact Readable Type:
            exemple:
                ReadI8()
                ReadString()
                ReadF64()
        ]]
    ```

## Writing/Reading Booleans

=== "Code"
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local BufferModule = require(ReplicatedStorage.Buffer)

    local _buffer = BufferModule.new(0) --> (auto allocate is allowed in this module)
    _buffer:WriteBool1({true,1,false,false,workspace.Baseplate,"hi",true,false}) -- min value 8 max value 8
    print(_buffer:ReadBool1(8)) -- {Array of booleans}
    ```

## Properties of buffer

.Buffer -> return the current buffer who write values and read them

.Offset -> return the current offset of the buffer

## Info

This module is still not finished but this is the first version of it

## Version

VERSION : 1.0