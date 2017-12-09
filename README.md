## HexEdit [![Build Status](https://travis-ci.org/zznop/HexEdit.jl.svg?branch=master)](https://travis-ci.org/zznop/HexEdit.jl)

HexEdit is a package for editing and displaying data in binary files in
hexadecimal format.

### Synopsis

#### dump!(self::HexEd, offset = 0, n::Int = -1)
Displays binary file data beginning at offset and ending at offset + n.
- offset defaults to 0
- n defaults to file size - n.

#### edit!(self::HexEd, datastr::String, offset = 0)
Edits targeted binary file by overwriting data beginning at offset.
- offset defaults to 0
- datastr can be in ASCII or hexadecimal format (ie. "foobar" or "0x666f6f626172")

### Examples

### Complete File Hexdump

```julia
hexedit = HexEd("test.bin")
dump!(hexedit, 0x00)

# 00000000   5d 00 00 80   00 ff ff ff   ff ff ff ff   ff 00 7f e1   ]...............
# 00000010   90 e6 67 83   93 40 93 22   a0 1b ab 50   6e a1 93 54   ..g..@."...Pn..T
# 00000020   3a 7f fd a3   d9 c0 60 29   af b6 94 96   3e aa 5c 38   :.....`)....>.\8
# 00000030   1c 05 02 31   7d 74 72 0d   40 3c 22 da   ef fa ca 80   ...1}tr.@<".....
# 00000040   df f8 e2 7b   cc 65 09 29   64 c3 15 de   e6 39 b7 7e   ...{.e.)d....9.~
# 00000050   d5 8c aa 91   f0 28 37 e1   5d ad c0 37   74 16 ce c1   .....(7.]..7t...
# 00000060   75 94 1e ea   dd 64 d6 b5   a1 2e 54 3d   62 4b 72 30   u....d....T=bKr0
# 00000070   5a 35 b8 5d   42 a2 24 a1   c6 22 6a be   c6 58 07 e5   Z5.]B.$.."j..X..
# 00000080   4f f1 e3 fc   53 14 70 aa   ae 58 fa e3   d8 c4 3a db   O...S.p..X....:.
# 00000090   d2 81 cf 99   24 10 4c c1   53 76 98 bc   16 e9 c2 7e   ....$.L.Sv.....~
# 000000a0   2c 6f 23 d6   f7 32 ab 81   7e 74 fd b6   fe b2 e7 15   ,o#..2..~t......
# 000000b0   83 7d 45 96   44 a8 d9 cf   b2 b8 ad 37   73 0e 15 ad   .}E.D......7s...
# 000000c0   2f 55 1c 33   e7 86 4a 3a   71 39 fd 40   4f f8 94 7c   /U.3..J:q9.@O..|
# 000000d0   b4 8f 2c fa   f2 fa 20 43   fc e5 09 1e   cb 6e ac c4   ..,... C.....n..
# and so on...
```
### Chunk Hexdump

Dump 16 bytes beginning at offset 0x04
```julia
hexedit = HexEd("test.bin")
dump!(hexedit, 0x04, 16)

# 00000004   66 6f 6f 62   61 72 ff ff   ff 00 7f e1   90 e6 67 83   foobar........g.
```

### Hexadecimal Editing (Hex String)

Write foobar to test.bin beginning at offset 0x04
```julia
hexedit = HexEd("test.bin")
edit!(hexedit, "0x666f6f626172", 0x04)
```

### Hexadecimal Editing (ASCII string)

Write foobar to test.bin beginning at offset 0x04
```julia
hexedit = HexEd("test.bin")
edit!(hexedit, "foobar", 0x04)
```

### Binary Singature Location

Return offset of the start of the hexadecimal signature "b77e"
```julia
hexedit = HexEd("test.bin")
offset = find!(hexedit, "0xb77e")
```
