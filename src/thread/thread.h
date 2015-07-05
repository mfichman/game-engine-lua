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

/* Wrapper for std::thread with primitives for passing data via a channel */

typedef struct thread_Thread thread_Thread;
typedef struct thread_Channel thread_Channel;

typedef enum thread_ErrorCode {
    thread_ok,
    thread_empty,
    thread_error,
} thread_ErrorCode;

typedef struct thread_Message {
    size_t len;
    char buffer[512];
} thread_Message;

__declspec(dllexport) thread_Thread* thread_Thread_new(char const* file);
__declspec(dllexport) thread_ErrorCode thread_Thread_send(thread_Thread* self, thread_Message const* msg);
__declspec(dllexport) thread_ErrorCode thread_Thread_recv(thread_Thread* self, thread_Message* msg);
__declspec(dllexport) thread_ErrorCode thread_Thread_poll(thread_Thread* self, thread_Message* msg);
__declspec(dllexport) thread_ErrorCode thread_Thread_join(thread_Thread* self);
__declspec(dllexport) thread_Thread* thread_current();
__declspec(dllexport) thread_ErrorCode thread_send(thread_Message const* msg);
__declspec(dllexport) thread_ErrorCode thread_recv(thread_Message* msg);

__declspec(dllexport) thread_ErrorCode thread_Channel_send(thread_Channel* self, thread_Message const* msg);
__declspec(dllexport) thread_ErrorCode thread_Channel_recv(thread_Channel* self, thread_Message* msg);
__declspec(dllexport) thread_ErrorCode thread_Channel_poll(thread_Channel* self, thread_Message* msg);



