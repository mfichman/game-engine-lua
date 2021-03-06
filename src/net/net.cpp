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

#ifndef _WIN32
#define __declspec(x)
#endif

#include <stdexcept>
#include <cstdint>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <cerrno>
#include <cstring>

extern "C" {
#include <sys/socket.h>
#include <net/net.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <netdb.h>
}

struct net_Socket {
    net_Socket(int sd) : 
        sd(sd), 
        err(0) {
    }
    ~net_Socket() {
        close(sd);
    }

    int sd;
    int err;
};

/* Create a new non-blocking TCP stream socket, disable SIGPIPE, and set TCP
 * options */
net_Socket* net_Socket_new() {
    int const sd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    int const yes = 1;
    if (fcntl(sd, F_SETFL, O_NONBLOCK) < 0) {
        return 0;
    } 
    if (fcntl(sd, F_SETNOSIGPIPE, &yes) < 0) {
        return 0;
    }
    if (sd < 0) {
        return 0;
    } else {
        return new net_Socket(sd);
    }
}

/* Frees resources associated with the socket */
void net_Socket_del(net_Socket* self) {
    delete self;
}

/* Connect to the given hostname/port. Returns net_OK if connect completed,
 * net_YIELD if the operation didn't complete, and net_DISCONNECT if there was
 * an unrecoverable error. */
net_SocketError net_Socket_connect(net_Socket* self, char const* host, uint16_t port) {
    char serv[128];
    snprintf(serv, sizeof(serv), "%d", port);

    addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_INET;
    hints.ai_socktype = SOCK_STREAM;

    addrinfo* res = 0;
    if (getaddrinfo(host,serv,&hints,&res) < 0) {
        self->err = errno;
        return net_DISCONNECT;
    }    
    if (!res) {
        self->err = errno;
        return net_DISCONNECT;
    }

    sockaddr_in* sin = (sockaddr_in*)res->ai_addr;
    
    int const err = connect(self->sd, res->ai_addr, res->ai_addrlen);
    freeaddrinfo(res);

    if (err < 0) {
        self->err = errno;
        if (EINPROGRESS == errno) {
            return net_OK;
        } else {
            return net_DISCONNECT;
        }
    } else {
        return net_OK;
    }
}

/* Read up to n bytes from the socket into buf. If there's no error, return the
 * number of bytes read. If the read would block the thread, then this function
 * returns net_YIELD.
 */
net_SocketResult net_Socket_read(net_Socket* self, char* buf, uint32_t n) {
    uint32_t bytes = 0;
    while (true) {
        int const ret = recv(self->sd, buf+bytes, n-bytes, 0);
        if (ret<0) {
            self->err = errno;
            if (EAGAIN == errno) {
                return {net_YIELD, bytes};
            } else {
                return {net_DISCONNECT, bytes};
            }
        } else {
            bytes += ret;
            if (bytes == n) {
                self->err = 0;
                return {net_OK, bytes};
            } else {
                /* wait for more data */    
            }
        }
    }
}

/* Write up to bytes from buf into the socket, returning the number of bytes
 * written, and an error code to indicate the error. If the write would block
 * the thread, then this function returns net_YIELD.
 */
net_SocketResult net_Socket_write(net_Socket* self, char const* buf, uint32_t n) {
    uint32_t bytes = 0;
    while (true) {
        int const ret = send(self->sd, buf, n, 0);
        if (ret < 0) {
            self->err = errno;
            if (EAGAIN == errno) {
                return {net_YIELD, bytes};
            } else if(ENOTCONN == errno) {
                return {net_YIELD, bytes};
            } else {
                return {net_DISCONNECT, bytes};
            }
        } else {
            bytes += ret;
            if (bytes == n) {
                self->err = 0;
                return {net_OK, bytes};
            } else {
                /* wait for more data */
            }
        }
    }
}

/* Binds the socket to the given port. */
net_SocketError net_Socket_bind(net_Socket* self, uint16_t port) {
    int const yes = 1;
    if(setsockopt(self->sd, SOL_SOCKET, SO_REUSEPORT, &yes, sizeof(yes))<0) {
        return net_DISCONNECT;
    }
    if(setsockopt(self->sd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes))<0) {
        return net_DISCONNECT;
    }

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_addr.s_addr = 0;
    addr.sin_port = htons(port);
    if(bind(self->sd, (sockaddr*)&addr, sizeof(addr))<0) {
        return net_DISCONNECT;
    } else {
        self->err = 0;
        return net_OK;
    }
}

/* Listens on the bound port for inoming connections. Returns an error if
 * the operation fails. */
net_SocketError net_Socket_listen(net_Socket* self) {
    if(listen(self->sd, 16)<0) {
        return net_DISCONNECT; 
    } else {
        self->err = 0;
        return net_OK;
    }
}

/* Accepts an incoming connection. If no connection is in the queue, then this
 * function returns net_YIELD; otherwise, 'out' is initialized as an endpoint
 * for the new connection.
 */
net_SocketError net_Socket_accept(net_Socket* self, net_Socket* out) {
    sockaddr_in addr;
    socklen_t len = sizeof(addr);
    int const sd = accept(self->sd, (sockaddr*)&addr, &len);
    if(sd<0) {
        if (EWOULDBLOCK == errno) {
            return net_YIELD;
        } else {
            return net_DISCONNECT;
        }
    } else {
        close(out->sd);
        out->sd = sd;
        self->err = 0;
        return net_OK;
    }
}

/* Returns the detailed error code of the last error. */
int net_Socket_errno(net_Socket* self) {
    return self->err;
}

/* Closes the socket */
void net_Socket_close(net_Socket* self) {
    close(self->sd);
    self->sd = -1;
}
