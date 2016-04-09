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



