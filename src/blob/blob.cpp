/*
 * Copyright (c) 2014 Matt Fichman
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

extern "C" {
    #include <blob/blob.h>
}
#include <unordered_map>
#include <mutex>
#include <atomic>

typedef struct blob_Ref {
    std::string name;
    void* data = 0;
    std::atomic<uint32_t> refs = 1;
} blob_Ref;

std::unordered_map<std::string,blob_Ref*> blob;
std::mutex mutex;

/* Creates a new blob, and returns it (if the blob doesn't exist already) */
blob_Ref* blob_Ref_new(char const* name) {
    std::unique_lock<std::mutex> lock(mutex);
    blob_Ref* const ref = blob[name];
    if (ref) {
        std::atomic_fetch_add_explicit(&ref->refs, 1u, std::memory_order_relaxed);
        return ref;
    } else {
        blob_Ref* const ref = new blob_Ref;
        ref->name = name;
        blob[name] = ref;
        return ref;
    }
}

/* Finds a blob by name, and increments the reference count by one */
blob_Ref* blob_Ref_find(char const* name) {
    std::unique_lock<std::mutex> lock(mutex);
    blob_Ref* const ref = blob[name];
    if (ref) {
        std::atomic_fetch_add_explicit(&ref->refs, 1u, std::memory_order_relaxed);
    }
    return ref;
}

/* Allocates or reallocates storage for the blob */
void blob_Ref_alloc(blob_Ref* ref, size_t len) {
    ref->data = realloc(ref->data, len);
}

/* Deletes the blob */
void blob_Ref_del(blob_Ref* ref) {
    if (!ref) {
        // Null pointer 
    } else if (std::atomic_fetch_sub_explicit(&ref->refs, 1u, std::memory_order_release) == 1) {
        std::atomic_thread_fence(std::memory_order_acquire);
        std::unique_lock<std::mutex> lock(mutex);
        blob.erase(ref->name);
        delete ref;
    }
}

