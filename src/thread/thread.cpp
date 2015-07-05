/* ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== */

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
