#!/bin/sh

cat >/etc/snmp/snmptrapd.conf << EOF
disableAuthorization yes
authCommunity log,execute,net public
format execute \$a %a\n\$A %A\n\$s %s\n\$b %b\n\$B %B\n\$x %#y-%#02m-%#02l\n\$X %#02.2h:%#02.2j:%#02.2k\n\$N %N\n\$q %q\n\$P %P\n\$t %t\n\$T %T\n\$w %w\n\$W %W\n%V~\%~%v\n
traphandle default alerta-snmptrap
EOF

