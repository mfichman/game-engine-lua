/* 
 * Copyright (c) 2016 Matt Fichman
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#ifndef WIN32
#define __declspec(x)
#endif

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


