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

/* C wrapper for physics engines (including Bullet) */

typedef struct physics_World physics_World;
typedef struct physics_Shape physics_Shape;
typedef struct physics_RigidBody physics_RigidBody;
typedef struct physics_Constraint physics_Constraint;
typedef struct physics_CollisionObject physics_CollisionObject;

typedef struct physics_RigidBodyDesc {
    vec_Scalar mass;
    vec_Transform transform;
    physics_Shape* shape;
    vec_Scalar friction;
    vec_Scalar restitution;
} physics_RigidBodyDesc;

__declspec(dllexport) physics_World* physics_World_new();
__declspec(dllexport) void physics_World_del(physics_World* self);
__declspec(dllexport) void physics_World_setGravity(physics_World* self, vec_Vec3 const* gravity);
__declspec(dllexport) vec_Vec3 physics_World_getGravity(physics_World* self);
__declspec(dllexport) void physics_World_addRigidBody(physics_World* self, physics_RigidBody* body);
__declspec(dllexport) void physics_World_addConstraint(physics_World* self, physics_Constraint* constraint);
__declspec(dllexport) void physics_World_addCollisionObject(physics_World* self, physics_CollisionObject* object);
__declspec(dllexport) void physics_World_removeRigidBody(physics_World* self, physics_RigidBody* body);
__declspec(dllexport) void physics_World_removeConstraint(physics_World* self, physics_Constraint* constraint);
__declspec(dllexport) void physics_World_removeCollisionObject(physics_World* self, physics_CollisionObject* object);
__declspec(dllexport) void physics_World_stepSimulation(physics_World* self, vec_Scalar timeStep, int maxSubSteps, vec_Scalar fixedTimeStep);

__declspec(dllexport) physics_Shape* physics_SphereShape_new(vec_Scalar radius);
__declspec(dllexport) physics_Shape* physics_ConvexHullShape_new(uint32_t* index, uint32_t indexCount, vec_Vec3* vertex, uint32_t vertexCount, uint32_t vertexStride);
__declspec(dllexport) physics_Shape* physics_CompoundShape_new();
__declspec(dllexport) void physics_Shape_addChildShape(physics_Shape* self, vec_Transform* transform, physics_Shape* child);
__declspec(dllexport) void physics_Shape_del(physics_Shape* self);

__declspec(dllexport) physics_Constraint* physics_HingeConstraint_new(physics_RigidBody* b1, physics_RigidBody* b2, vec_Vec3* pivot1, vec_Vec3* pivot2, vec_Vec3* axis1, vec_Vec3* axis2);
__declspec(dllexport) void physics_Constraint_del(physics_Constraint* self);

__declspec(dllexport) physics_RigidBody* physics_RigidBody_new(physics_RigidBodyDesc* desc);
__declspec(dllexport) void physics_RigidBody_del(physics_RigidBody* self);
__declspec(dllexport) void physics_RigidBody_applyCentralForce(physics_RigidBody* self, vec_Vec3 const* force);
__declspec(dllexport) void physics_RigidBody_applyCentralImpulse(physics_RigidBody* self, vec_Vec3 const* impulse);
__declspec(dllexport) void physics_RigidBody_applyTorque(physics_RigidBody* self, vec_Vec3 const* torque);
__declspec(dllexport) void physics_RigidBody_applyImpulse(physics_RigidBody* self, vec_Vec3 const* impulse, vec_Vec3 const* pos);
__declspec(dllexport) void physics_RigidBody_applyForce(physics_RigidBody* self, vec_Vec3 const* force, vec_Vec3 const* pos);
__declspec(dllexport) physics_Shape* physics_RigidBody_getShape(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getTotalForce(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 phsyics_RigidBody_getTotalTorque(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getPosition(physics_RigidBody* self);
__declspec(dllexport) vec_Quat physics_RigidBody_getRotation(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getLinearVelocity(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getAngularVelocity(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getLinearFactor(physics_RigidBody* self);
__declspec(dllexport) vec_Vec3 physics_RigidBody_getAngularFactor(physics_RigidBody* self);
__declspec(dllexport) void* physics_RigidBody_getUserPointer(physics_RigidBody* self, void* data);
__declspec(dllexport) void physics_RigidBody_setLinearVelocity(physics_RigidBody* self, vec_Vec3 const* velocity);
__declspec(dllexport) void physics_RigidBody_setAngularVelocity(physics_RigidBody* self, vec_Vec3 const* velocity);
__declspec(dllexport) void physics_RigidBody_setAngularFactor(physics_RigidBody* self, vec_Vec3 const* factor);
__declspec(dllexport) void physics_RigidBody_setLinearFactor(physics_RigidBody* self, vec_Vec3 const* factor);
__declspec(dllexport) void physics_RigidBody_setUserPointer(physics_RigidBody* self, void* data);



