#!/bin/sh

openssl enc -d -aes-256-cbc -pbkdf2 -iter 30000 -in /bin/mybinary.enc -out /bin/mybinary -k $ENCRYPTIONKEY
chmod +x /bin/mybinary
exec "$@"