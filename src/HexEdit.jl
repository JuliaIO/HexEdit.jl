module HexEdit

export HexEd, dump!, edit!, find!

mutable struct HexEd
    _fh::IO
    _filesize::Int
    _offset::UInt64

    function HexEd(filename::AbstractString)
        _fh        = open(filename, "r+")
        _filesize  =  filename[1:4]=="\\\\.\\" ? 0 : filesize(filename)
        println("_filesize:", _filesize)
        _offset    = 0x00
        new(_filesize, _fh, _offset)
    end # constructor HexEd
end # type HexEd

#----------
# displays data in hex format
#----------
function dump_line(s::HexEd, line::Array{UInt8})
    llen = length(line)
    plen = llen % 16

    print("$(uppercase(string(s._offset, base=16, pad=8))) | ")
    n = 0
    for byte in line
        # space every 8 bytes
        if n == 8
            print("  ")
        end
        print("$(uppercase(string(byte, base=16, pad=2))) ")
        n = n + 1
    end
    # line up ascii on the last line of dumps
    # if plen != 0
    #     while n < 16
    #         if n % 4 == 0
    #             print("  ")
    #         end
    #         print(" ")
    #         n = n + 1
    #     end
    # end
    print("|")
    # print ascii
    n = 0
    for byte in line
        if byte < 32 || byte > 126
            print(".")
        else
            print(Char(byte))
        end
        n = n + 1
    end
    print("\n")
    s._offset = s._offset + llen
end # function dump_line

#----------
# helper for dump!; iterates buffer and displays data
# by tasking helper dump_line
#----------
function dump_buffer(s::HexEd, buffer::Array{UInt8})
    blen = length(buffer)
    llen = 16
    idx  = 1

    while idx < blen
        if idx + 16 > blen
            llen = blen - idx + 1
        end
        dump_line(s, buffer[idx:idx + llen - 1])
        idx = idx + llen
    end
end # function dump_buffer

#----------
# display data chunk of n size beginning at offset
#----------
function dump!(s::HexEd, start=nothing, n=nothing)
    if n == nothing
        n = s._filesize
    end

    if start != nothing
        s._offset = convert(UInt64, start)
    end
    seek(s._fh, s._offset)

    read_size = 1024
    idx   = 0
    total = 0
    while total < n
        if idx + 1024 > n
            read_size = n - idx
        end

        buffer = read(s._fh, read_size)
        dump_buffer(s, buffer)
        total = total + read_size
    end
end # function dump!

#----------
# converts ASCII string or hexadecimal string to binary byte array
#----------
function hex2bin(rawstr::AbstractString)
    if (match(r"^0x[0-9a-fA-F]+", rawstr) == nothing)  # If it is not a hexadecimal string
        return Array{UInt8}(rawstr)
    end
    m = match(r"0x([0-9a-fA-F]+)", rawstr)
    len = length(m.captures[1])
    if len % 2 != 0
        error("hex string length must be divisible by 2")
    end
    hex2bytes(ascii(m.captures[1]))
end # function hex2bin

#----------
# edit binary file
#----------
function edit!(s::HexEd, datastr::AbstractString, start=nothing)
    if start != nothing
        s._offset = convert(UInt64, start)
    end

    databytes = hex2bin(datastr)
    if s._offset + length(databytes) > s._filesize
        error("cannot write past end of file")
    end
    seek(s._fh, s._offset)
    write(s._fh, databytes)
end # function edit!

#----------
# search for binary signature and return the offset or
# nothing; modify s._offset to point to beginning of
# located signature
#----------
function find!(s::HexEd, sigstr::AbstractString, start=nothing)
    if start != nothing
        s._offset = convert(UInt64, start)
    else
        s._offset = 0
    end
    sigbytes = hex2bin(sigstr)
    seek(s._fh, s._offset)
    siglen = length(sigbytes)
    if siglen > s._filesize
        error("signature length exceeds file size")
    end

    # read to siglen
    total = 0
    buffer = read(s._fh, siglen)
    if buffer == sigbytes
        return s._offset = convert(UInt64, total - siglen)
    end
    total = total + siglen
    
    # read byte by byte
    idx = 0
    while total < s._filesize
        if idx + siglen > s._filesize
             break
        end
        byte = read(s._fh, 1)
        total = total + 1
        buffer = append!(buffer[2:end], byte)
        if buffer == sigbytes
            return s._offset = convert(UInt64, total - siglen)
        end
    end

    nothing
end # function find!

end # module HexEdit
