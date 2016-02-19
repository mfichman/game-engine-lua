

cpp -I/usr/local/include $@ \
| sed '/^[[:space:]]*$/d' \
| sed 's/[[:space:]]*\#\#[[:space:]]*//g' \
| sed '/\#/d' \
| sed '/^\/\//d' 

#| sed 's/extern __attribute__ ((__visibility__ ("default"))) //g' \

