-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local Socket = {}; Socket.__index = Socket

function Socket.new()
end

-- Attempts to read at most 'n' characters from the socket. If no character can
-- be read, then this function returns nil.
function Socket:read(n)
end

-- Writes list of strings to the socket.
function Socket:write(str...)
end

return Socket.new
