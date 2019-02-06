## HexEdit [![Build Status](https://travis-ci.org/zznop/HexEdit.jl.svg?branch=master)](https://travis-ci.org/zznop/HexEdit.jl)

HexEdit is a package for editing and displaying data in binary files in
hexadecimal format.

In **v0.7+**/**v1.0+**, please type `]` in the REPL to use the package mode, then type this command:

```julia
pkg> add https://github.com/JuliaIO/HexEdit.jl.git
```

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
```
```
00000000 | 5D 00 00 80 66 6F 6F 62   61 72 FF FF FF 00 7F E1 |]...foobar......
00000010 | 90 E6 67 83 93 40 93 22   A0 1B AB 50 6E A1 93 54 |..g..@."...Pn..T
00000020 | 3A 7F FD A3 D9 C0 60 29   AF B6 94 96 3E AA 5C 38 |:.....`)....>.\8
00000030 | 1C 05 02 31 7D 74 72 0D   40 3C 22 DA EF FA CA 80 |...1}tr.@<".....
00000040 | DF F8 E2 7B CC 65 09 29   64 C3 15 DE E6 39 B7 7E |...{.e.)d....9.~
00000050 | D5 8C AA 91 F0 28 37 E1   5D AD C0 37 74 16 CE C1 |.....(7.]..7t...
00000060 | 75 94 1E EA DD 64 D6 B5   A1 2E 54 3D 62 4B 72 30 |u....d....T=bKr0
00000070 | 5A 35 B8 5D 42 A2 24 A1   C6 22 6A BE C6 58 07 E5 |Z5.]B.$.."j..X..
00000080 | 4F F1 E3 FC 53 14 70 AA   AE 58 FA E3 D8 C4 3A DB |O...S.p..X....:.
00000090 | D2 81 CF 99 24 10 4C C1   53 76 98 BC 16 E9 C2 7E |....$.L.Sv.....~
000000A0 | 2C 6F 23 D6 F7 32 AB 81   7E 74 FD B6 FE B2 E7 15 |,o#..2..~t......
000000B0 | 83 7D 45 96 44 A8 D9 CF   B2 B8 AD 37 73 0E 15 AD |.}E.D......7s...
and so on...
```
### Chunk Hexdump

Dump 16 bytes beginning at offset 0x04
```julia
hexedit = HexEd("test.bin")
dump!(hexedit, 0x04, 16)
```
```
00000004 | 66 6F 6F 62 61 72 FF FF   FF 00 7F E1 90 E6 67 83 |foobar........g.
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
