typedef int sfBool;
typedef signed   char sfInt8;
typedef unsigned char sfUint8;
typedef signed   short sfInt16;
typedef unsigned short sfUint16;
typedef signed   int sfInt32;
typedef unsigned int sfUint32;
    typedef signed   long long sfInt64;
    typedef unsigned long long sfUint64;
typedef struct
{
    sfInt64 microseconds;
} sfTime;
sfTime sfTime_Zero;
float sfTime_asSeconds(sfTime time);
sfInt32 sfTime_asMilliseconds(sfTime time);
sfInt64 sfTime_asMicroseconds(sfTime time);
sfTime sfSeconds(float amount);
sfTime sfMilliseconds(sfInt32 amount);
sfTime sfMicroseconds(sfInt64 amount);
typedef struct sfClock sfClock;
typedef struct sfMutex sfMutex;
typedef struct sfThread sfThread;
sfClock* sfClock_create(void);
sfClock* sfClock_copy(const sfClock* clock);
void sfClock_destroy(sfClock* clock);
sfTime sfClock_getElapsedTime(const sfClock* clock);
sfTime sfClock_restart(sfClock* clock);
