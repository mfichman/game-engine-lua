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

#include <cstdint>
#include <unordered_map>
#include <mutex>
extern "C" {
    #include <blob/blob.h>
}
#include <cstdlib>

typedef struct blob_Ref {
    blob_Id id;     
    uint32_t refs; 
    char data[];
} blob_Ref;

static std::mutex mutex;
static std::unordered_map<blob_Id,blob_Ref*> blob;
static blob_Id nextId = 0;

/* Creates a new blob of the given size, and returns it */
void* blob_Ref_new(size_t len) {
    std::unique_lock<std::mutex> lock(mutex);
    blob_Ref* const ref = (blob_Ref*)malloc(sizeof(blob_Ref)+len);
    ref->id = ++nextId;
    ref->refs = 1;
    blob[ref->id] = ref;
    return ref->data;
}

/* Finds a blob by id, and increments the reference count by one */
void* blob_Ref_find(blob_Id id) {
    std::unique_lock<std::mutex> lock(mutex);
    auto i = blob.find(id);
    if (i == blob.end()) {
        return 0;
    } else {
        i->second->refs++;
        return i->second->data;
    }
}

/* Finds the ID for a blob */
blob_Id blob_Ref_id(void* self) {
    return (((blob_Ref*)self)-1)->id;
}

/* Deletes a reference to a blob */
void blob_Ref_del(void* self) {
    if (!self) { return; }

    blob_Ref* const ref = (((blob_Ref*)self)-1);
    std::unique_lock<std::mutex> lock(mutex);
    ref->refs--;
    if (ref->refs == 0) {
        blob.erase(ref->id);
        delete ref;
    }
}

