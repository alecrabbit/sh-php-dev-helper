s:^:.:
h
y/qwertyuiopasdfghjklzxcvbnm/QWERTYUIOPASDFGHJKLZXCVBNM/
G
s:$:\n:
:r
/^.\n.\n/{s:::;p;d}
/^[^[:alpha:]][[:alpha:]]/ {
    s:.\(.\)\(.*\):x\2\1:
    s:\n\(..\):\nx:
    tr
}

/^[[:alpha:]][[:alpha:]]/ {
    s:\n.\(.\)\(.*\)$:\nx\2\1:
    s:..:x:
    tr
}
/^[^\n]/ {
    s:^.\(.\)\(.*\)$:.\2\1:
    s:\n..:\n.:
    tr
}