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

#include <cstdint>
#include <unordered_map>
#include <mutex>
extern "C" {
    #include <blob/blob.h>
}

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

