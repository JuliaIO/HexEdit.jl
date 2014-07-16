module HexEdit

export HexEd,
       dump!,
       edit!,
       find!

type HexEd # :)
    _filesize::Int
    _fh::IO
    _offset::Uint64

    ############################################################
    # HexEd
    # -----
    # constructor/initializer for HexEd type
    ############################################################

    function HexEd(filename)
        _filesize  = filesize(filename)
        _fh        = open(filename, "r+")
        _offset    = 0x00
        new(_filesize, _fh, _offset)
    end # constructor HexEd
end # type HexEd

############################################################
# _dump_line
# ------------
# displays data in hex format
############################################################

function _dump_line(s::HexEd, line::Array{Uint8})
    llen = length(line)
    plen = llen % 16

    print("$(hex(s._offset, 8)) ")
    n::Int = 0
    for byte::Uint8 = line
        # space every 4 bytes
        if n % 4 == 0
            print("  ")
        end
        print("$(hex(byte, 2)) ")
        n = n + 1
    end
    # line up ascii on the last line of dumps
    if plen != 0
        while n < 16
            if n % 4 == 0
                print("  ")
            end
            print("   ")
            n = n + 1
        end
    end
    print("  ")
    # print ascii
    n = 0
    for byte::Uint8 = line
        if byte < 32 || byte > 126
            print(".")
        else
            print(char(byte))
        end
        n = n + 1
    end
    print("\n")
    s._offset = s._offset + llen
end # function _dump_line

############################################################
# _dump_buffer
# ------------
# helper for dump!; iterates buffer and displays data
# by tasking helper _dump_line
############################################################

function _dump_buffer(s::HexEd, buffer::Array{Uint8})
    blen::Int  = length(buffer)
    llen::Int  = 16
    idx::Int   = 1
    while idx< blen
        if idx+ 16 > blen
            llen = blen - idx+ 1
        end
        _dump_line(s, buffer[idx:idx+ llen - 1])
        idx= idx+ llen
    end
end # function _dump_buffer

############################################################
# dump!
# -----
# display data chunk of n size beginning at offset
############################################################

function dump!(s::HexEd, start = nothing, n = nothing)
    if n == nothing
        n = s._filesize
    end

    if start != nothing
        s._offset = convert(Uint64, start)
    end
    seek(s._fh, s._offset)

    read_size::Int = 1024
    idx::Int       = 0
    total::Int     = 0
    while total < n
        if idx + 1024 > n
            read_size = n - idx
        end

        buffer = readbytes(s._fh, read_size)
        _dump_buffer(s, buffer)
        total = total + read_size
    end
end # function dump!

############################################################
# _hex2bin
# --------
# converts ASCII string or hexadecimal string to binary byte
# array
############################################################

function _hex2bin(rawstr::String)
    if (!ismatch(r"^0x[0-9a-fA-F]+", rawstr))
        return convert(Array{Uint8}, rawstr)
    end
    m = match(r"0x([0-9a-fA-F]+)", rawstr)
    len::Int = length(m.captures[1])
    if len % 2 != 0
        error("hex string length must be divisible by 2")
    end
    hex2bytes(ascii(m.captures[1]))
end # function _hex2bin

############################################################
# edit!
# -----
# edit binary file
############################################################

function edit!(s::HexEd, datastr::String, start = nothing)
    if start != nothing
        s._offset = convert(Uint64, start)
    end

    databytes::Array{Uint8} = _hex2bin(datastr)
    if s._offset + length(databytes) > s._filesize
        error("cannot write past end of file")
    end
    seek(s._fh, s._offset)
    write(s._fh, databytes)
end # function edit!

############################################################
# find!
# -----
# search for binary signature and return the offset or
# nothing; modify s._offset to point to beginning of
# located signature
############################################################

function find!(s::HexEd, sigstr::String, start = nothing)
    if start != nothing
        s._offset = convert(Uint64, start)
    end
    sigbytes::Array{Uint8} = _hex2bin(sigstr)
    seek(s._fh, s._offset)
    siglen::Int = length(sigbytes)
    if siglen > s._filesize
        error("signature length exceeds file size")
    end

    # read to siglen
    total::Int = 0
    buffer = readbytes(s._fh, siglen)
    if buffer == sigbytes
        return s._offset = convert(Uint64, total - siglen)
    end
    total = total + siglen
    
    # read byte by byte
    idx::Int = 0
    while total < s._filesize
        if idx + siglen > s._filesize
             break
        end
        byte   = readbytes(s._fh, 1)
        total = total + 1
        buffer = append!(buffer[2:end], byte)
        if buffer == sigbytes
            return s._offset = convert(Uint64, total - siglen)
        end
    end

    nothing
end # function find!

end # module HexEdit
