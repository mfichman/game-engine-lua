

cpp -DSFML_SFML_WINDOW_H < $1 \
| sed '/^\s*$/d' \
| sed '/\#/d' \
| sed 's/extern __attribute__ ((__visibility__ ("default"))) //g' \
| sed '/^\/\//d' \
| sed 's/\r//g'


