    // MacOS
        // GCC 4 has special keywords for showing/hidding symbols,
        // the same keyword is used for both importing and exporting
typedef int sfBool;
typedef signed   char sfInt8;
typedef unsigned char sfUint8;
typedef signed   short sfInt16;
typedef unsigned short sfUint16;
typedef signed   int sfInt32;
typedef unsigned int sfUint32;
    typedef signed   long long sfInt64;
    typedef unsigned long long sfUint64;
typedef enum 
{
    sfBlendAlpha,    ///< Pixel = Src * a + Dest * (1 - a)
    sfBlendAdd,      ///< Pixel = Src + Dest
    sfBlendMultiply, ///< Pixel = Src * Dest
    sfBlendNone      ///< No blending
} sfBlendMode;
typedef struct
{
    sfUint8 r;
    sfUint8 g;
    sfUint8 b;
    sfUint8 a;
} sfColor;
sfColor sfBlack;       ///< Black predefined color
sfColor sfWhite;       ///< White predefined color
sfColor sfRed;         ///< Red predefined color
sfColor sfGreen;       ///< Green predefined color
sfColor sfBlue;        ///< Blue predefined color
sfColor sfYellow;      ///< Yellow predefined color
sfColor sfMagenta;     ///< Magenta predefined color
sfColor sfCyan;        ///< Cyan predefined color
sfColor sfTransparent; ///< Transparent (black) predefined color
sfColor sfColor_fromRGB(sfUint8 red, sfUint8 green, sfUint8 blue);
sfColor sfColor_fromRGBA(sfUint8 red, sfUint8 green, sfUint8 blue, sfUint8 alpha);
sfColor sfColor_add(sfColor color1, sfColor color2);
sfColor sfColor_modulate(sfColor color1, sfColor color2);
typedef struct
{
    float left;
    float top;
    float width;
    float height;
} sfFloatRect;
typedef struct
{
    int left;
    int top;
    int width;
    int height;
} sfIntRect;
sfBool sfFloatRect_contains(const sfFloatRect* rect, float x, float y);
sfBool sfIntRect_contains(const sfIntRect* rect, int x, int y);
sfBool sfFloatRect_intersects(const sfFloatRect* rect1, const sfFloatRect* rect2, sfFloatRect* intersection);
sfBool sfIntRect_intersects(const sfIntRect* rect1, const sfIntRect* rect2, sfIntRect* intersection);
typedef struct sfCircleShape sfCircleShape;
typedef struct sfConvexShape sfConvexShape;
typedef struct sfFont sfFont;
typedef struct sfImage sfImage;
typedef struct sfShader sfShader;
typedef struct sfRectangleShape sfRectangleShape;
typedef struct sfRenderTexture sfRenderTexture;
typedef struct sfRenderWindow sfRenderWindow;
typedef struct sfShape sfShape;
typedef struct sfSprite sfSprite;
typedef struct sfText sfText;
typedef struct sfTexture sfTexture;
typedef struct sfTransformable sfTransformable;
typedef struct sfVertexArray sfVertexArray;
typedef struct sfView sfView;
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
    float matrix[9];
} sfTransform;
const sfTransform sfTransform_Identity;
sfTransform sfTransform_fromMatrix(float a00, float a01, float a02,
                                                      float a10, float a11, float a12,
                                                      float a20, float a21, float a22);
void sfTransform_getMatrix(const sfTransform* transform, float* matrix);
sfTransform sfTransform_getInverse(const sfTransform* transform);
sfVector2f sfTransform_transformPoint(const sfTransform* transform, sfVector2f point);
sfFloatRect sfTransform_transformRect(const sfTransform* transform, sfFloatRect rectangle);
void sfTransform_combine(sfTransform* transform, const sfTransform* other);
void sfTransform_translate(sfTransform* transform, float x, float y);
void sfTransform_rotate(sfTransform* transform, float angle);
void sfTransform_rotateWithCenter(sfTransform* transform, float angle, float centerX, float centerY);
void sfTransform_scale(sfTransform* transform, float scaleX, float scaleY);
void sfTransform_scaleWithCenter(sfTransform* transform, float scaleX, float scaleY, float centerX, float centerY);
sfCircleShape* sfCircleShape_create(void);
sfCircleShape* sfCircleShape_copy(const sfCircleShape* shape);
void sfCircleShape_destroy(sfCircleShape* shape);
void sfCircleShape_setPosition(sfCircleShape* shape, sfVector2f position);
void sfCircleShape_setRotation(sfCircleShape* shape, float angle);
void sfCircleShape_setScale(sfCircleShape* shape, sfVector2f scale);
void sfCircleShape_setOrigin(sfCircleShape* shape, sfVector2f origin);
sfVector2f sfCircleShape_getPosition(const sfCircleShape* shape);
float sfCircleShape_getRotation(const sfCircleShape* shape);
sfVector2f sfCircleShape_getScale(const sfCircleShape* shape);
sfVector2f sfCircleShape_getOrigin(const sfCircleShape* shape);
void sfCircleShape_move(sfCircleShape* shape, sfVector2f offset);
void sfCircleShape_rotate(sfCircleShape* shape, float angle);
void sfCircleShape_scale(sfCircleShape* shape, sfVector2f factors);
sfTransform sfCircleShape_getTransform(const sfCircleShape* shape);
sfTransform sfCircleShape_getInverseTransform(const sfCircleShape* shape);
void sfCircleShape_setTexture(sfCircleShape* shape, const sfTexture* texture, sfBool resetRect);
void sfCircleShape_setTextureRect(sfCircleShape* shape, sfIntRect rect);
void sfCircleShape_setFillColor(sfCircleShape* shape, sfColor color);
void sfCircleShape_setOutlineColor(sfCircleShape* shape, sfColor color);
void sfCircleShape_setOutlineThickness(sfCircleShape* shape, float thickness);
const sfTexture* sfCircleShape_getTexture(const sfCircleShape* shape);
sfIntRect sfCircleShape_getTextureRect(const sfCircleShape* shape);
sfColor sfCircleShape_getFillColor(const sfCircleShape* shape);
sfColor sfCircleShape_getOutlineColor(const sfCircleShape* shape);
float sfCircleShape_getOutlineThickness(const sfCircleShape* shape);
unsigned int sfCircleShape_getPointCount(const sfCircleShape* shape);
sfVector2f sfCircleShape_getPoint(const sfCircleShape* shape, unsigned int index);
void sfCircleShape_setRadius(sfCircleShape* shape, float radius);
float sfCircleShape_getRadius(const sfCircleShape* shape);
void sfCircleShape_setPointCount(sfCircleShape* shape, unsigned int count);
sfFloatRect sfCircleShape_getLocalBounds(const sfCircleShape* shape);
sfFloatRect sfCircleShape_getGlobalBounds(const sfCircleShape* shape);
sfConvexShape* sfConvexShape_create(void);
sfConvexShape* sfConvexShape_copy(const sfConvexShape* shape);
void sfConvexShape_destroy(sfConvexShape* shape);
void sfConvexShape_setPosition(sfConvexShape* shape, sfVector2f position);
void sfConvexShape_setRotation(sfConvexShape* shape, float angle);
void sfConvexShape_setScale(sfConvexShape* shape, sfVector2f scale);
void sfConvexShape_setOrigin(sfConvexShape* shape, sfVector2f origin);
sfVector2f sfConvexShape_getPosition(const sfConvexShape* shape);
float sfConvexShape_getRotation(const sfConvexShape* shape);
sfVector2f sfConvexShape_getScale(const sfConvexShape* shape);
sfVector2f sfConvexShape_getOrigin(const sfConvexShape* shape);
void sfConvexShape_move(sfConvexShape* shape, sfVector2f offset);
void sfConvexShape_rotate(sfConvexShape* shape, float angle);
void sfConvexShape_scale(sfConvexShape* shape, sfVector2f factors);
sfTransform sfConvexShape_getTransform(const sfConvexShape* shape);
sfTransform sfConvexShape_getInverseTransform(const sfConvexShape* shape);
void sfConvexShape_setTexture(sfConvexShape* shape, const sfTexture* texture, sfBool resetRect);
void sfConvexShape_setTextureRect(sfConvexShape* shape, sfIntRect rect);
void sfConvexShape_setFillColor(sfConvexShape* shape, sfColor color);
void sfConvexShape_setOutlineColor(sfConvexShape* shape, sfColor color);
void sfConvexShape_setOutlineThickness(sfConvexShape* shape, float thickness);
const sfTexture* sfConvexShape_getTexture(const sfConvexShape* shape);
sfIntRect sfConvexShape_getTextureRect(const sfConvexShape* shape);
sfColor sfConvexShape_getFillColor(const sfConvexShape* shape);
sfColor sfConvexShape_getOutlineColor(const sfConvexShape* shape);
float sfConvexShape_getOutlineThickness(const sfConvexShape* shape);
unsigned int sfConvexShape_getPointCount(const sfConvexShape* shape);
sfVector2f sfConvexShape_getPoint(const sfConvexShape* shape, unsigned int index);
void sfConvexShape_setPointCount(sfConvexShape* shape, unsigned int count);
void sfConvexShape_setPoint(sfConvexShape* shape, unsigned int index, sfVector2f point);
sfFloatRect sfConvexShape_getLocalBounds(const sfConvexShape* shape);
sfFloatRect sfConvexShape_getGlobalBounds(const sfConvexShape* shape);
typedef struct
{
    int       advance;     ///< Offset to move horizontically to the next character
    sfIntRect bounds;      ///< Bounding rectangle of the glyph, in coordinates relative to the baseline
    sfIntRect textureRect; ///< Texture coordinates of the glyph inside the font's image
} sfGlyph;
sfFont* sfFont_createFromFile(const char* filename);
sfFont* sfFont_createFromMemory(const void* data, size_t sizeInBytes);
sfFont* sfFont_createFromStream(sfInputStream* stream);
sfFont* sfFont_copy(const sfFont* font);
void sfFont_destroy(sfFont* font);
sfGlyph sfFont_getGlyph(sfFont* font, sfUint32 codePoint, unsigned int characterSize, sfBool bold);
int sfFont_getKerning(sfFont* font, sfUint32 first, sfUint32 second, unsigned int characterSize);
int sfFont_getLineSpacing(sfFont* font, unsigned int characterSize);
const sfTexture* sfFont_getTexture(sfFont* font, unsigned int characterSize);
sfImage* sfImage_create(unsigned int width, unsigned int height);
sfImage* sfImage_createFromColor(unsigned int width, unsigned int height, sfColor color);
sfImage* sfImage_createFromPixels(unsigned int width, unsigned int height, const sfUint8* pixels);
sfImage* sfImage_createFromFile(const char* filename);
sfImage* sfImage_createFromMemory(const void* data, size_t size);
sfImage* sfImage_createFromStream(sfInputStream* stream);
sfImage* sfImage_copy(const sfImage* image);
void sfImage_destroy(sfImage* image);
sfBool sfImage_saveToFile(const sfImage* image, const char* filename);
sfVector2u sfImage_getSize(const sfImage* image);
void sfImage_createMaskFromColor(sfImage* image, sfColor color, sfUint8 alpha);
void sfImage_copyImage(sfImage* image, const sfImage* source, unsigned int destX, unsigned int destY, sfIntRect sourceRect, sfBool applyAlpha);
void sfImage_setPixel(sfImage* image, unsigned int x, unsigned int y, sfColor color);
sfColor sfImage_getPixel(const sfImage* image, unsigned int x, unsigned int y);
const sfUint8* sfImage_getPixelsPtr(const sfImage* image);
void sfImage_flipHorizontally(sfImage* image);
void sfImage_flipVertically(sfImage* image);
typedef enum 
{
    sfPoints,         ///< List of individual points
    sfLines,          ///< List of individual lines
    sfLinesStrip,     ///< List of connected lines, a point uses the previous point to form a line
    sfTriangles,      ///< List of individual triangles
    sfTrianglesStrip, ///< List of connected triangles, a point uses the two previous points to form a triangle
    sfTrianglesFan,   ///< List of connected triangles, a point uses the common center and the previous point to form a triangle
    sfQuads           ///< List of individual quads
} sfPrimitiveType;
sfRectangleShape* sfRectangleShape_create(void);
sfRectangleShape* sfRectangleShape_copy(const sfRectangleShape* shape);
void sfRectangleShape_destroy(sfRectangleShape* shape);
void sfRectangleShape_setPosition(sfRectangleShape* shape, sfVector2f position);
void sfRectangleShape_setRotation(sfRectangleShape* shape, float angle);
void sfRectangleShape_setScale(sfRectangleShape* shape, sfVector2f scale);
void sfRectangleShape_setOrigin(sfRectangleShape* shape, sfVector2f origin);
sfVector2f sfRectangleShape_getPosition(const sfRectangleShape* shape);
float sfRectangleShape_getRotation(const sfRectangleShape* shape);
sfVector2f sfRectangleShape_getScale(const sfRectangleShape* shape);
sfVector2f sfRectangleShape_getOrigin(const sfRectangleShape* shape);
void sfRectangleShape_move(sfRectangleShape* shape, sfVector2f offset);
void sfRectangleShape_rotate(sfRectangleShape* shape, float angle);
void sfRectangleShape_scale(sfRectangleShape* shape, sfVector2f factors);
sfTransform sfRectangleShape_getTransform(const sfRectangleShape* shape);
sfTransform sfRectangleShape_getInverseTransform(const sfRectangleShape* shape);
void sfRectangleShape_setTexture(sfRectangleShape* shape, const sfTexture* texture, sfBool resetRect);
void sfRectangleShape_setTextureRect(sfRectangleShape* shape, sfIntRect rect);
void sfRectangleShape_setFillColor(sfRectangleShape* shape, sfColor color);
void sfRectangleShape_setOutlineColor(sfRectangleShape* shape, sfColor color);
void sfRectangleShape_setOutlineThickness(sfRectangleShape* shape, float thickness);
const sfTexture* sfRectangleShape_getTexture(const sfRectangleShape* shape);
sfIntRect sfRectangleShape_getTextureRect(const sfRectangleShape* shape);
sfColor sfRectangleShape_getFillColor(const sfRectangleShape* shape);
sfColor sfRectangleShape_getOutlineColor(const sfRectangleShape* shape);
float sfRectangleShape_getOutlineThickness(const sfRectangleShape* shape);
unsigned int sfRectangleShape_getPointCount(const sfRectangleShape* shape);
sfVector2f sfRectangleShape_getPoint(const sfRectangleShape* shape, unsigned int index);
void sfRectangleShape_setSize(sfRectangleShape* shape, sfVector2f size);
sfVector2f sfRectangleShape_getSize(const sfRectangleShape* shape);
sfFloatRect sfRectangleShape_getLocalBounds(const sfRectangleShape* shape);
sfFloatRect sfRectangleShape_getGlobalBounds(const sfRectangleShape* shape);
typedef struct
{
    sfBlendMode      blendMode; ///< Blending mode
    sfTransform      transform; ///< Transform
    const sfTexture* texture;   ///< Texture
    const sfShader*  shader;    ///< Shader
} sfRenderStates;
typedef struct
{
    sfVector2f position;  ///< Position of the vertex
    sfColor    color;     ///< Color of the vertex
    sfVector2f texCoords; ///< Coordinates of the texture's pixel to map to the vertex
} sfVertex;
