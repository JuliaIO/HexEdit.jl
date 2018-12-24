## HexEdit [![Build Status](https://travis-ci.org/zznop/HexEdit.jl.svg?branch=master)](https://travis-ci.org/zznop/HexEdit.jl)

HexEdit is a package for editing and displaying data in binary files in
hexadecimal format.

In **v0.7+**/**v1.0+**, please type `]` in the REPL to use the package mode, then type this command:

```julia
pkg> add https://github.com/zsz00/HexEdit.jl.git
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

00000000 |  5d000080  666f6f62  6172ffff  ff007fe1 | ]   foobar
00000010 |  90e66783  93409322  a01bab50  6ea19354 |   g  @ "   Pn  T
00000020 |  3a7ffda3  d9c06029  afb69496  3eaa5c38 | :     `)    > \8
00000030 |  1c050231  7d74720d  403c22da  effaca80 |    1}tr @<"
00000040 |  dff8e27b  cc650929  64c315de  e639b77e |    { e )d    9 ~
00000050 |  d58caa91  f02837e1  5dadc037  7416cec1 |      (7 ]  7t
00000060 |  75941eea  dd64d6b5  a12e543d  624b7230 | u    d   .T=bKr0
00000070 |  5a35b85d  42a224a1  c6226abe  c65807e5 | Z5 ]B $  "j  X
00000080 |  4ff1e3fc  531470aa  ae58fae3  d8c43adb | O   S p  X    :
00000090 |  d281cf99  24104cc1  537698bc  16e9c27e |     $ L Sv     ~
000000a0 |  2c6f23d6  f732ab81  7e74fdb6  feb2e715 | ,o#  2  ~t
000000b0 |  837d4596  44a8d9cf  b2b8ad37  730e15ad |  }E D      7s
000000c0 |  2f551c33  e7864a3a  7139fd40  4ff8947c | /U 3  J:q9 @O  |
000000d0 |  b48f2cfa  f2fa2043  fce5091e  cb6eacc4 |   ,    C     n
and so on...
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
