/* ========================================================================== --
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
-- ========================================================================== */


typedef struct net_Socket net_Socket;

typedef enum net_SocketError {
    net_OK,
    net_YIELD,
    net_DISCONNECT, 
    net_USAGE,
} net_SocketError;

typedef struct net_SocketResult {
    net_SocketError err;
    uint32_t bytes;
} net_SocketResult;

__declspec(dllexport) net_Socket* net_Socket_new();
__declspec(dllexport) void net_Socket_del(net_Socket* self);
__declspec(dllexport) net_SocketError net_Socket_connect(net_Socket* self, char const* host, uint16_t port);
__declspec(dllexport) net_SocketResult net_Socket_read(net_Socket* self, char* buf, uint32_t n);
__declspec(dllexport) net_SocketResult net_Socket_write(net_Socket* self, char const* buf, uint32_t n);
__declspec(dllexport) net_SocketError net_Socket_listen(net_Socket* self);
__declspec(dllexport) net_SocketError net_Socket_accept(net_Socket* self, net_Socket* out);
__declspec(dllexport) net_SocketError net_Socket_bind(net_Socket* self, uint16_t port);
__declspec(dllexport) void net_Socket_close(net_Socket* self);
__declspec(dllexport) int net_Socket_errno(net_Socket* self);


