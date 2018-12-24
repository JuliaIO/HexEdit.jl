using HexEdit

# construct type
hexedit = HexEd("test.bin")
# dump whole file
dump!(hexedit, 0x00)
# write foobar beginning at offset 0x04 using hex string as arg
edit!(hexedit, "0x666f6f626172", 4)
# dump 16 bytes beginning at offset 0x04
dump!(hexedit, 4, 16)
# write foobar beginning at offset 0x04 using ascii as arg
edit!(hexedit, "foobar", 0x04)
# dump 16 bytes beginning at offset 0x04
dump!(hexedit, 0x04, 16)
# find foobar
fbl = find!(hexedit, "foobar", 0x00)
if fbl != nothing
    println("found foobar at $(uppercase(string(fbl, base=16, pad=8)))")
end
# find hex signature
fbl = find!(hexedit, "0x07ae0971")
if fbl != nothing
    println("found hex signature at $(uppercase(string(fbl, base=16, pad=8)))")
end

