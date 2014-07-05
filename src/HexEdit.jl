module HexEdit

export HexEd,
       dump!,
       edit!

type HexEd # :)
    _filesize::Int
    _fh::IO
    _offset::Uint64

    ############################################################
    # HexEd
    # -----
    # constructor/initializer for HexEd type
    ############################################################

    function HexEd(filename::ASCIIString)
        self = new()
        self._filesize  = filesize(filename)
        self._fh        = open(filename, "r+")
        self._offset    = 0
        self
    end # constructor HexEd
end # type HexEd

############################################################
# _open_fh
# --------
# open file in specified mode
############################################################

function _open_fh(filename::ASCIIString, mode::ASCIIString)
    fh::IO
    try
        fh = open(filename, mode)
    catch
        error("file failed to open")
    end
    fh
end # function _open_fh

############################################################
# _dump_line
# ------------
# displays data in hex format
############################################################

function _dump_line(self::HexEd, line::Array{Uint8})
    llen = length(line)
    plen = llen % 16

    # print offset
    print("$(hex(self._offset, 8)) ")
    # print hex
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
    self._offset = self._offset + llen
end

############################################################
# _dump_buffer
# ------------
# helper for dump!; iterates buffer and displays data
# by tasking helper _dump_line
############################################################

function _dump_buffer(self::HexEd, buffer::Array{Uint8})
    blen::Int  = length(buffer)
    llen::Int  = 16
    idx::Int   = 1
    while idx< blen
        if idx+ 16 > blen
            llen = blen - idx+ 1
        end
        _dump_line(self, buffer[idx:idx+ llen - 1])
        idx= idx+ llen
    end
end # function _dump_buffer

############################################################
# dump!
# -----
# display data chunk of n size beginning at offset
############################################################

function dump!(self::HexEd, offset = 0, n::Int = -1)
    # if size of bytes to dump is unspecified, set number of bytes to filesize
    if n < 0
        n = self._filesize
    end

    # set offset index
    self._offset = convert(Uint64, offset)

    # jump to entry offset
    seek(self._fh, self._offset)

    # read chunk by chunk
    read_size::Int = 1024
    idx::Int       = 0
    total::Int     = 0
    while total < n
        # set read_size to size of last chunk
        if idx + 1024 > n
            read_size = n - idx
        end

        # read bytes
        buffer = readbytes(self._fh, read_size)
        _dump_buffer(self, buffer)

        # increment total
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
    # return if ASCII
    if (!ismatch(r"^0x[0-9a-fA-F]+", rawstr))
        return convert(Array{Uint8}, rawstr)
    end
    # remove 0x
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

function edit!(self::HexEd, datastr::String, offset = 0)
    self._offset = convert(Uint64, offset)
    # if rawdata is a hex string, convert to binary
    databytes::Array{Uint8} = _hex2bin(datastr)
    if offset + length(databytes) > self._filesize
        error("cannot write past end of file")
    end
    # jump to entry offset
    seek(self._fh, self._offset)
    # modify the file
    write(self._fh, databytes)
end # function edit!

end # module HexEdit
