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

#include <cstdint>
#include <cassert>
extern "C" {
    #include <vec/vec.h>
    #include <physics/physics.h>
}
#include <bullet/btBulletCollisionCommon.h>
#include <bullet/btBulletDynamicsCommon.h>
#include <bullet/BulletCollision/CollisionShapes/btShapeHull.h>

template <typename T, typename V> T convert(V* val);
template <typename T, typename V> T convert(V const& val);

struct MotionState : public btMotionState {
    MotionState(btTransform const& transform) : transform(transform) {}
    virtual void getWorldTransform(btTransform& trans) const { trans = transform; }
    virtual void setWorldTransform(btTransform const& trans) { transform = trans; }
    btTransform transform;
};

struct World : public btDiscreteDynamicsWorld {
    World(btCollisionDispatcher* dispatcher, btDbvtBroadphase* broadphase, btConstraintSolver* solver, btCollisionConfiguration* config) :
        btDiscreteDynamicsWorld(dispatcher, broadphase, solver, config) {}

    /* Interpolate motion states, even though we're using 0 substeps. This
     * avoids the need for registering tick callbacks, which cause problems for
     * LuaJIT. We call bullet's substep API directly, but with a fixed timestep
     * value each time. At the end of the substeps, we call synchronizeMotionStates
     * once to get bullet to go interpolation for rendering.
     */
    void synchronizeMotionStates(btScalar remainder, btScalar fixedTimeStep) {
        m_localTime = remainder;
        m_fixedTimeStep = fixedTimeStep;
        btDiscreteDynamicsWorld::synchronizeMotionStates();
    }
};

template <> inline btVector3 convert<btVector3>(vec_Vec3 const* val) {
    return btVector3(val->x, val->y, val->z);
}

template <> inline btVector3 convert<btVector3>(vec_Vec3* val) {
    return btVector3(val->x, val->y, val->z);
}

template <> inline vec_Vec3 convert<vec_Vec3>(btVector3 const& val) {
    vec_Vec3 ret;
    ret.x = val.getX();
    ret.y = val.getY();
    ret.z = val.getZ();
    return ret;
}

template <> inline btQuaternion convert<btQuaternion>(vec_Quat const* val) {
    return btQuaternion(val->x, val->y, val->z, val->w);
}

template <> inline btQuaternion convert<btQuaternion>(vec_Quat* val) {
    return btQuaternion(val->x, val->y, val->z, val->w);
}

template <> inline vec_Quat convert<vec_Quat>(btQuaternion const& val) {
    vec_Quat ret;
    ret.w = val.getW();
    ret.x = val.getX();
    ret.y = val.getY();
    ret.z = val.getZ();
    return ret;
}

physics_World* physics_World_new() {
    btDefaultCollisionConfiguration* config = new btDefaultCollisionConfiguration;
    btCollisionDispatcher* dispatcher = new btCollisionDispatcher(config);
    btDbvtBroadphase* broadphase = new btDbvtBroadphase();
    btSequentialImpulseConstraintSolver* solver = new btSequentialImpulseConstraintSolver;
    return (physics_World*)new World(dispatcher, broadphase, solver, config);
}

void physics_World_del(physics_World* self) {
    btDiscreteDynamicsWorld* world = (btDiscreteDynamicsWorld*)self;
    btCollisionDispatcher* dispatcher = (btCollisionDispatcher*)world->getDispatcher();
    btCollisionConfiguration* config = dispatcher->getCollisionConfiguration();
    btBroadphaseInterface* broadphase = world->getBroadphase();
    btConstraintSolver* solver = world->getConstraintSolver();
    delete world;
    delete solver;
    delete dispatcher;
    delete config;
    delete broadphase;
}

void physics_World_setGravity(physics_World* self, vec_Vec3 const* gravity) {
    ((btDiscreteDynamicsWorld*)self)->setGravity(convert<btVector3>(gravity));
}

void physics_World_addRigidBody(physics_World* self, physics_RigidBody* body) {
    ((btDiscreteDynamicsWorld*)self)->addRigidBody((btRigidBody*)body);
}

void physics_World_addConstraint(physics_World* self, physics_Constraint* constraint) {
    ((btDiscreteDynamicsWorld*)self)->addConstraint((btTypedConstraint*)constraint);
}

void physics_World_addCollisionObject(physics_World* self, physics_CollisionObject* object) {
    ((btDiscreteDynamicsWorld*)self)->addCollisionObject((btCollisionObject*)object);
}

void physics_World_removeRigidBody(physics_World* self, physics_RigidBody* body) {
    ((btDiscreteDynamicsWorld*)self)->removeRigidBody((btRigidBody*)body);
}

void physics_World_removeConstraint(physics_World* self, physics_Constraint* constraint) {
    ((btDiscreteDynamicsWorld*)self)->removeConstraint((btTypedConstraint*)constraint);
}

void physics_World_removeCollisionObject(physics_World* self, physics_CollisionObject* object) {
    ((btDiscreteDynamicsWorld*)self)->removeCollisionObject((btCollisionObject*)object);
}

void physics_World_stepSimulation(physics_World* self, vec_Scalar timeStep, int maxSubSteps, vec_Scalar fixedTimeStep) { 
    ((btDiscreteDynamicsWorld*)self)->stepSimulation(timeStep, maxSubSteps, fixedTimeStep); 
}

void physics_World_synchronizeMotionStates(physics_World* self, vec_Scalar remainder, vec_Scalar fixedTimeStep) {
    ((World*)self)->synchronizeMotionStates(remainder, fixedTimeStep);
}

vec_Vec3 physics_World_getGravity(physics_World* self) {
    return convert<vec_Vec3>(((btDiscreteDynamicsWorld*)self)->getGravity());
}

physics_Shape* physics_SphereShape_new(vec_Scalar radius) {
    return (physics_Shape*)new btSphereShape(radius);
}

physics_Shape* physics_ConvexHullShape_new(uint32_t* index, uint32_t indexCount, vec_Vec3* vertex, uint32_t vertexCount, uint32_t vertexStride) {
    btTriangleIndexVertexArray vertexArray;
    btIndexedMesh indexedMesh;

    indexedMesh.m_numTriangles = indexCount/3;
    indexedMesh.m_triangleIndexBase = (uint8_t const*)index;
    indexedMesh.m_triangleIndexStride = sizeof(uint32_t)*3;
    indexedMesh.m_numVertices = vertexCount;
    indexedMesh.m_vertexBase = (uint8_t const*)vertex;
    indexedMesh.m_vertexStride = vertexStride;
    vertexArray.addIndexedMesh(indexedMesh);

    btConvexTriangleMeshShape tempShape(&vertexArray);
    btShapeHull shapeHull(&tempShape);
    shapeHull.buildHull(tempShape.getMargin());

    btConvexHullShape* shape = new btConvexHullShape;
    for (int i = 0; i < shapeHull.numVertices(); ++i) {
        shape->addPoint(shapeHull.getVertexPointer()[i]);
    }
    return (physics_Shape*)shape;
}

physics_Shape* physics_CompoundShape_new() {
    return (physics_Shape*)new btCompoundShape;
}

void physics_Shape_addChildShape(physics_Shape* self, vec_Transform* tx, physics_Shape* child) {
    btTransform transform(convert<btQuaternion>(&tx->rotation), convert<btVector3>(&tx->origin));
    btCollisionShape* shape = (btCollisionShape*)self;
    btCompoundShape* compoundShape = dynamic_cast<btCompoundShape*>(shape);
    assert(compoundShape);
    compoundShape->addChildShape(transform, (btCollisionShape*)child);
}

void physics_Shape_del(physics_Shape* self) {
    delete (btCollisionShape*)self;
}

physics_Constraint* physics_HingeConstraint_new(physics_RigidBody* b1, physics_RigidBody* b2, vec_Vec3* pivot1, vec_Vec3* pivot2, vec_Vec3* axis1, vec_Vec3* axis2) {
    return (physics_Constraint*)new btHingeConstraint(*(btRigidBody*)b1, *(btRigidBody*)b2, convert<btVector3>(pivot1), convert<btVector3>(pivot2), convert<btVector3>(axis1), convert<btVector3>(axis2));
}

void physics_Constraint_del(physics_Constraint* self) {
    delete (btTypedConstraint*)self;
}


physics_RigidBody* physics_RigidBody_new(physics_RigidBodyDesc* desc) {
    vec_Quat* const r = &desc->transform.rotation;
    vec_Vec3* const o = &desc->transform.origin;
    
    btRigidBody::btRigidBodyConstructionInfo info(0, 0, 0);
    info.m_motionState = new MotionState(btTransform(convert<btQuaternion>(r), convert<btVector3>(o)));
    info.m_collisionShape = (btCollisionShape*)desc->shape;
    info.m_friction = desc->friction;
    info.m_restitution = desc->restitution;
    info.m_mass = desc->mass;

    if (info.m_collisionShape) {
        info.m_collisionShape->calculateLocalInertia(info.m_mass, info.m_localInertia);
    }
    btQuaternion quat = info.m_startWorldTransform.getRotation();
    
    btRigidBody* body = new btRigidBody(info);
    body->setSleepingThresholds(0.03f, 0.01f);
    body->setActivationState(DISABLE_DEACTIVATION);
    return (physics_RigidBody*)body;
}

void physics_RigidBody_del(physics_RigidBody* self) {
    delete ((btRigidBody*)self)->getMotionState();
    delete (btRigidBody*)self;
}

void physics_RigidBody_applyCentralForce(physics_RigidBody* self, vec_Vec3 const* force) {
    ((btRigidBody*)self)->applyCentralForce(convert<btVector3>(force));
}

void physics_RigidBody_applyCentralImpulse(physics_RigidBody* self, vec_Vec3 const* impulse) {
    ((btRigidBody*)self)->applyCentralImpulse(convert<btVector3>(impulse));
}

void physics_RigidBody_applyTorque(physics_RigidBody* self, vec_Vec3 const* torque) {
    ((btRigidBody*)self)->applyTorque(convert<btVector3>(torque));
}

void physics_RigidBody_applyImpulse(physics_RigidBody* self, vec_Vec3 const* impulse, vec_Vec3 const* pos) {
    ((btRigidBody*)self)->applyImpulse(convert<btVector3>(impulse), convert<btVector3>(pos));
}

void physics_RigidBody_applyForce(physics_RigidBody* self, vec_Vec3 const* force, vec_Vec3 const* pos) {
    ((btRigidBody*)self)->applyForce(convert<btVector3>(force), convert<btVector3>(pos));
}

physics_Shape* physics_RigidBody_getShape(physics_RigidBody* self) {
    return (physics_Shape*)((btRigidBody*)self)->getCollisionShape();
}

vec_Vec3 physics_RigidBody_getTotalForce(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getTotalForce());
}

vec_Vec3 phsyics_RigidBody_getTotalTorque(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getTotalTorque());
}

vec_Vec3 physics_RigidBody_getPosition(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getCenterOfMassPosition());
}

vec_Quat physics_RigidBody_getRotation(physics_RigidBody* self) {
    return convert<vec_Quat>(((btRigidBody*)self)->getOrientation());
}

vec_Vec3 physics_RigidBody_getPredictedPosition(physics_RigidBody* self) {
    MotionState* ms = (MotionState*)((btRigidBody*)self)->getMotionState();
    return convert<vec_Vec3>(ms->transform.getOrigin());
}

vec_Quat physics_RigidBody_getPredictedRotation(physics_RigidBody* self) {
    MotionState* ms = (MotionState*)((btRigidBody*)self)->getMotionState();
    return convert<vec_Quat>(ms->transform.getRotation());
}

vec_Vec3 physics_RigidBody_getLinearVelocity(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getLinearVelocity());
}

vec_Vec3 physics_RigidBody_getAngularVelocity(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getAngularVelocity());
}

vec_Vec3 physics_RigidBody_getLinearFactor(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getLinearFactor());
}

vec_Vec3 physics_RigidBody_getAngularFactor(physics_RigidBody* self) {
    return convert<vec_Vec3>(((btRigidBody*)self)->getAngularFactor());
}

void* physics_RigidBody_getUserPointer(physics_RigidBody* self, void* data) {
    return ((btRigidBody*)self)->getUserPointer();
}

void physics_RigidBody_setLinearVelocity(physics_RigidBody* self, vec_Vec3 const* velocity) {
    ((btRigidBody*)self)->setLinearVelocity(convert<btVector3>(velocity));
}

void physics_RigidBody_setAngularVelocity(physics_RigidBody* self, vec_Vec3 const* velocity) {
    ((btRigidBody*)self)->setAngularVelocity(convert<btVector3>(velocity));
}

void physics_RigidBody_setAngularFactor(physics_RigidBody* self, vec_Vec3 const* factor) {
    ((btRigidBody*)self)->setAngularFactor(convert<btVector3>(factor));
}

void physics_RigidBody_setLinearFactor(physics_RigidBody* self, vec_Vec3 const* factor) {
    ((btRigidBody*)self)->setLinearFactor(convert<btVector3>(factor));
}

void physics_RigidBody_setUserPointer(physics_RigidBody* self, void* data) {
    ((btRigidBody*)self)->setUserPointer(data);
}

