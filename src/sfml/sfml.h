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
typedef sfInt64 (*sfInputStreamReadFunc)(void* data, sfInt64 size, void* userData);
typedef sfInt64 (*sfInputStreamSeekFunc)(sfInt64 position, void* userData);
typedef sfInt64 (*sfInputStreamTellFunc)(void* userData);
typedef sfInt64 (*sfInputStreamGetSizeFunc)(void* userData);
typedef struct sfInputStream
{
    sfInputStreamReadFunc    read;     ///< Function to read data from the stream
    sfInputStreamSeekFunc    seek;     ///< Function to set the current read position
    sfInputStreamTellFunc    tell;     ///< Function to get the current read position
    sfInputStreamGetSizeFunc getSize;  ///< Function to get the total number of bytes in the stream
    void*                    userData; ///< User data that will be passed to the callbacks
} sfInputStream;
sfMutex* sfMutex_create(void);
void sfMutex_destroy(sfMutex* mutex);
void sfMutex_lock(sfMutex* mutex);
void sfMutex_unlock(sfMutex* mutex);
void sfSleep(sfTime duration);
sfThread* sfThread_create(void (*function)(void*), void* userData);
void sfThread_destroy(sfThread* thread);
void sfThread_launch(sfThread* thread);
void sfThread_wait(sfThread* thread);
void sfThread_terminate(sfThread* thread);
typedef struct
{
    int x;
    int y;
} sfVector2i;
typedef struct
{
    unsigned int x;
    unsigned int y;
} sfVector2u;
typedef struct
{
    float x;
    float y;
} sfVector2f;
typedef struct
{
    float x;
    float y;
    float z;
} sfVector3f;
typedef struct sfContext sfContext;
typedef struct sfWindow sfWindow;
sfContext* sfContext_create(void);
void sfContext_destroy(sfContext* context);
void sfContext_setActive(sfContext* context, sfBool active);
enum
{
    sfJoystickCount       = 8,  ///< Maximum number of supported joysticks
    sfJoystickButtonCount = 32, ///< Maximum number of supported buttons
    sfJoystickAxisCount   = 8   ///< Maximum number of supported axes
};
typedef enum
{
    sfJoystickX,    ///< The X axis
    sfJoystickY,    ///< The Y axis
    sfJoystickZ,    ///< The Z axis
    sfJoystickR,    ///< The R axis
    sfJoystickU,    ///< The U axis
    sfJoystickV,    ///< The V axis
    sfJoystickPovX, ///< The X axis of the point-of-view hat
    sfJoystickPovY  ///< The Y axis of the point-of-view hat
} sfJoystickAxis;
sfBool sfJoystick_isConnected(unsigned int joystick);
unsigned int sfJoystick_getButtonCount(unsigned int joystick);
sfBool sfJoystick_hasAxis(unsigned int joystick, sfJoystickAxis axis);
sfBool sfJoystick_isButtonPressed(unsigned int joystick, unsigned int button);
float sfJoystick_getAxisPosition(unsigned int joystick, sfJoystickAxis axis);
void sfJoystick_update(void);
typedef enum
{
    sfKeyUnknown = -1, ///< Unhandled key
    sfKeyA,            ///< The A key
    sfKeyB,            ///< The B key
    sfKeyC,            ///< The C key
    sfKeyD,            ///< The D key
    sfKeyE,            ///< The E key
    sfKeyF,            ///< The F key
    sfKeyG,            ///< The G key
    sfKeyH,            ///< The H key
    sfKeyI,            ///< The I key
    sfKeyJ,            ///< The J key
    sfKeyK,            ///< The K key
    sfKeyL,            ///< The L key
    sfKeyM,            ///< The M key
    sfKeyN,            ///< The N key
    sfKeyO,            ///< The O key
    sfKeyP,            ///< The P key
    sfKeyQ,            ///< The Q key
    sfKeyR,            ///< The R key
    sfKeyS,            ///< The S key
    sfKeyT,            ///< The T key
    sfKeyU,            ///< The U key
    sfKeyV,            ///< The V key
    sfKeyW,            ///< The W key
    sfKeyX,            ///< The X key
    sfKeyY,            ///< The Y key
    sfKeyZ,            ///< The Z key
    sfKeyNum0,         ///< The 0 key
    sfKeyNum1,         ///< The 1 key
    sfKeyNum2,         ///< The 2 key
    sfKeyNum3,         ///< The 3 key
    sfKeyNum4,         ///< The 4 key
    sfKeyNum5,         ///< The 5 key
    sfKeyNum6,         ///< The 6 key
    sfKeyNum7,         ///< The 7 key
    sfKeyNum8,         ///< The 8 key
    sfKeyNum9,         ///< The 9 key
    sfKeyEscape,       ///< The Escape key
    sfKeyLControl,     ///< The left Control key
    sfKeyLShift,       ///< The left Shift key
    sfKeyLAlt,         ///< The left Alt key
    sfKeyLSystem,      ///< The left OS specific key: window (Windows and Linux), apple (MacOS X), ...
    sfKeyRControl,     ///< The right Control key
    sfKeyRShift,       ///< The right Shift key
    sfKeyRAlt,         ///< The right Alt key
    sfKeyRSystem,      ///< The right OS specific key: window (Windows and Linux), apple (MacOS X), ...
    sfKeyMenu,         ///< The Menu key
    sfKeyLBracket,     ///< The [ key
    sfKeyRBracket,     ///< The ] key
    sfKeySemiColon,    ///< The ; key
    sfKeyComma,        ///< The , key
    sfKeyPeriod,       ///< The . key
    sfKeyQuote,        ///< The ' key
    sfKeySlash,        ///< The / key
    sfKeyBackSlash,    ///< The \ key
    sfKeyTilde,        ///< The ~ key
    sfKeyEqual,        ///< The = key
    sfKeyDash,         ///< The - key
    sfKeySpace,        ///< The Space key
    sfKeyReturn,       ///< The Return key
    sfKeyBack,         ///< The Backspace key
    sfKeyTab,          ///< The Tabulation key
    sfKeyPageUp,       ///< The Page up key
    sfKeyPageDown,     ///< The Page down key
    sfKeyEnd,          ///< The End key
    sfKeyHome,         ///< The Home key
    sfKeyInsert,       ///< The Insert key
    sfKeyDelete,       ///< The Delete key
    sfKeyAdd,          ///< +
    sfKeySubtract,     ///< -
    sfKeyMultiply,     ///< *
    sfKeyDivide,       ///< /
    sfKeyLeft,         ///< Left arrow
    sfKeyRight,        ///< Right arrow
    sfKeyUp,           ///< Up arrow
    sfKeyDown,         ///< Down arrow
    sfKeyNumpad0,      ///< The numpad 0 key
    sfKeyNumpad1,      ///< The numpad 1 key
    sfKeyNumpad2,      ///< The numpad 2 key
    sfKeyNumpad3,      ///< The numpad 3 key
    sfKeyNumpad4,      ///< The numpad 4 key
    sfKeyNumpad5,      ///< The numpad 5 key
    sfKeyNumpad6,      ///< The numpad 6 key
    sfKeyNumpad7,      ///< The numpad 7 key
    sfKeyNumpad8,      ///< The numpad 8 key
    sfKeyNumpad9,      ///< The numpad 9 key
    sfKeyF1,           ///< The F1 key
    sfKeyF2,           ///< The F2 key
    sfKeyF3,           ///< The F3 key
    sfKeyF4,           ///< The F4 key
    sfKeyF5,           ///< The F5 key
    sfKeyF6,           ///< The F6 key
    sfKeyF7,           ///< The F7 key
    sfKeyF8,           ///< The F8 key
    sfKeyF9,           ///< The F8 key
    sfKeyF10,          ///< The F10 key
    sfKeyF11,          ///< The F11 key
    sfKeyF12,          ///< The F12 key
    sfKeyF13,          ///< The F13 key
    sfKeyF14,          ///< The F14 key
    sfKeyF15,          ///< The F15 key
    sfKeyPause,        ///< The Pause key
    sfKeyCount      ///< Keep last -- the total number of keyboard keys
} sfKeyCode;
sfBool sfKeyboard_isKeyPressed(sfKeyCode key);
typedef enum
{
    sfMouseLeft,       ///< The left mouse button
    sfMouseRight,      ///< The right mouse button
    sfMouseMiddle,     ///< The middle (wheel) mouse button
    sfMouseXButton1,   ///< The first extra mouse button
    sfMouseXButton2,   ///< The second extra mouse button
    sfMouseButtonCount ///< Keep last -- the total number of mouse buttons
} sfMouseButton;
sfBool sfMouse_isButtonPressed(sfMouseButton button);
sfVector2i sfMouse_getPosition(const sfWindow* relativeTo);
void sfMouse_setPosition(sfVector2i position, const sfWindow* relativeTo);
typedef enum
{
    sfEvtClosed,
    sfEvtResized,
    sfEvtLostFocus,
    sfEvtGainedFocus,
    sfEvtTextEntered,
    sfEvtKeyPressed,
    sfEvtKeyReleased,
    sfEvtMouseWheelMoved,
    sfEvtMouseButtonPressed,
    sfEvtMouseButtonReleased,
    sfEvtMouseMoved,
    sfEvtMouseEntered,
    sfEvtMouseLeft,
    sfEvtJoystickButtonPressed,
    sfEvtJoystickButtonReleased,
    sfEvtJoystickMoved,
    sfEvtJoystickConnected,
    sfEvtJoystickDisconnected
} sfEventType;
typedef struct
{
    sfEventType type;
    sfKeyCode   code;
    sfBool      alt;
    sfBool      control;
    sfBool      shift;
    sfBool      system;
} sfKeyEvent;
typedef struct
{
    sfEventType type;
    sfUint32    unicode;
} sfTextEvent;
typedef struct
{
    sfEventType type;
    int         x;
    int         y;
} sfMouseMoveEvent;
typedef struct
{
    sfEventType   type;
    sfMouseButton button;
    int           x;
    int           y;
} sfMouseButtonEvent;
typedef struct
{
    sfEventType type;
    int         delta;
    int         x;
    int         y;
} sfMouseWheelEvent;
typedef struct
{
    sfEventType    type;
    unsigned int   joystickId;
    sfJoystickAxis axis;
    float          position;
} sfJoystickMoveEvent;
typedef struct
{
    sfEventType  type;
    unsigned int joystickId;
    unsigned int button;
} sfJoystickButtonEvent;
typedef struct
{
    sfEventType  type;
    unsigned int joystickId;
} sfJoystickConnectEvent;
typedef struct
{
    sfEventType  type;
    unsigned int width;
    unsigned int height;
} sfSizeEvent;
typedef union
{
    ////////////////////////////////////////////////////////////
    // Member data
    ////////////////////////////////////////////////////////////
    sfEventType            type; ///< Type of the event
    sfSizeEvent            size;
    sfKeyEvent             key;
    sfTextEvent            text;
    sfMouseMoveEvent       mouseMove;
    sfMouseButtonEvent     mouseButton;
    sfMouseWheelEvent      mouseWheel;
    sfJoystickMoveEvent    joystickMove;
    sfJoystickButtonEvent  joystickButton;
    sfJoystickConnectEvent joystickConnect;
} sfEvent;
typedef long int ptrdiff_t;
typedef long unsigned int size_t;
typedef int wchar_t;
typedef struct
{
    unsigned int width;        ///< Video mode width, in pixels
    unsigned int height;       ///< Video mode height, in pixels
    unsigned int bitsPerPixel; ///< Video mode pixel depth, in bits per pixels
} sfVideoMode;
sfVideoMode sfVideoMode_getDesktopMode(void);
const sfVideoMode* sfVideoMode_getFullscreenModes(size_t* Count);
sfBool sfVideoMode_isValid(sfVideoMode mode);
    // Window handle is NSWindow (void*) on Mac OS X - Cocoa
	typedef void* sfWindowHandle;
enum
{
    sfNone         = 0,      ///< No border / title bar (this flag and all others are mutually exclusive)
    sfTitlebar     = 1 << 0, ///< Title bar + fixed border
    sfResize       = 1 << 1, ///< Titlebar + resizable border + maximize button
    sfClose        = 1 << 2, ///< Titlebar + close button
    sfFullscreen   = 1 << 3, ///< Fullscreen mode (this flag and all others are mutually exclusive)
    sfDefaultStyle = sfTitlebar | sfResize | sfClose ///< Default window style
};
typedef struct
{
    unsigned int depthBits;         ///< Bits of the depth buffer
    unsigned int stencilBits;       ///< Bits of the stencil buffer
    unsigned int antialiasingLevel; ///< Level of antialiasing
    unsigned int majorVersion;      ///< Major number of the context version to create
    unsigned int minorVersion;      ///< Minor number of the context version to create
} sfContextSettings;
sfWindow* sfWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
sfWindow* sfWindow_createUnicode(sfVideoMode mode, const sfUint32* title, sfUint32 style, const sfContextSettings* settings);
sfWindow* sfWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
void sfWindow_destroy(sfWindow* window);
void sfWindow_close(sfWindow* window);
sfBool sfWindow_isOpen(const sfWindow* window);
sfContextSettings sfWindow_getSettings(const sfWindow* window);
sfBool sfWindow_pollEvent(sfWindow* window, sfEvent* event);
sfBool sfWindow_waitEvent(sfWindow* window, sfEvent* event);
sfVector2i sfWindow_getPosition(const sfWindow* window);
void sfWindow_setPosition(sfWindow* window, sfVector2i position);
sfVector2u sfWindow_getSize(const sfWindow* window);
void sfWindow_setSize(sfWindow* window, sfVector2u size);
void sfWindow_setTitle(sfWindow* window, const char* title);
void sfWindow_setUnicodeTitle(sfWindow* window, const sfUint32* title);
void sfWindow_setIcon(sfWindow* window, unsigned int width, unsigned int height, const sfUint8* pixels);
void sfWindow_setVisible(sfWindow* window, sfBool visible);
void sfWindow_setMouseCursorVisible(sfWindow* window, sfBool visible);
void sfWindow_setVerticalSyncEnabled(sfWindow* window, sfBool enabled);
void sfWindow_setKeyRepeatEnabled(sfWindow* window, sfBool enabled);
sfBool sfWindow_setActive(sfWindow* window, sfBool active);
void sfWindow_display(sfWindow* window);
void sfWindow_setFramerateLimit(sfWindow* window, unsigned int limit);
void sfWindow_setJoystickThreshold(sfWindow* window, float threshold);
sfWindowHandle sfWindow_getSystemHandle(const sfWindow* window);
