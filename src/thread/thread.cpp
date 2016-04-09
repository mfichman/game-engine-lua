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

extern "C" {
    #include <luajit/lua.h>
    #include <luajit/lualib.h>
    #include <luajit/lauxlib.h>
    #include <thread/thread.h>
}
#include <thread>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <string>
#include <cstdlib>

struct thread_Channel {
    std::queue<thread_Message> message;
    std::mutex mutex;
    std::condition_variable condition;
};

struct thread_Thread {
    std::auto_ptr<std::thread> thread;
    thread_Channel input;  
    thread_Channel output;  
};

#ifdef _WIN32
#define thread_local __declspec(thread)
#else
#define thread_local __thread
#endif
thread_local thread_Thread* current = 0;

thread_Thread* thread_Thread_new(char const* file) {
    std::string const fn(file);
    thread_Thread* const thread = new thread_Thread;
    thread->thread.reset(new std::thread([fn,thread]() {
        current = thread;
        lua_State* const env = luaL_newstate();
        luaL_openlibs(env);
        if(luaL_dofile(env, fn.c_str())) {
            fprintf(stderr, "thread error: %s\n", lua_tostring(env, -1));
            exit(1);
        }
        fflush(stdout);
        fflush(stderr);
        lua_close(env);
    }));
    return thread;
}

thread_ErrorCode thread_Thread_send(thread_Thread* self, thread_Message const* msg) {
    return thread_Channel_send(&self->input, msg);
}

thread_ErrorCode thread_Thread_recv(thread_Thread* self, thread_Message* msg) {
    return thread_Channel_recv(&self->output, msg);
}

thread_ErrorCode thread_Thread_poll(thread_Thread* self, thread_Message* msg) {
    return thread_Channel_poll(&self->output, msg);
}

thread_ErrorCode thread_Thread_join(thread_Thread* self) {
    self->thread->join();
    return thread_ok;
}

thread_Thread* thread_current() {
    return current;
}

thread_ErrorCode thread_send(thread_Message const* msg) {
    return thread_Channel_send(&current->output, msg); 
}

thread_ErrorCode thread_recv(thread_Message* msg) {
    return thread_Channel_recv(&current->input, msg); 
}

thread_ErrorCode thread_Channel_send(thread_Channel* self, thread_Message const* msg) {
    std::unique_lock<std::mutex> lock(self->mutex);
    self->message.push(*msg);
    self->condition.notify_all();
    return thread_ok;
}

thread_ErrorCode thread_Channel_recv(thread_Channel* self, thread_Message* msg) {
    std::unique_lock<std::mutex> lock(self->mutex);
    while (self->message.empty()) {
        self->condition.wait(lock);
    }
    *msg = self->message.front();
    self->message.pop();
    return thread_ok;
}

thread_ErrorCode thread_Channel_poll(thread_Channel* self, thread_Message* msg) {
    std::unique_lock<std::mutex> lock(self->mutex);
    if (self->message.empty()) {
        return thread_empty;
    } else {
        *msg = self->message.front();
        self->message.pop();
        return thread_ok;
    }
}
