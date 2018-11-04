#!/bin/bash
echo Putting $1/$2 to the server...
ftp -n ftp.kponet.fi <<END_SCRIPT
quote USER kpomatt74
quote PASS gap195wbm
bin
lcd $1
put $2
quit
END_SCRIPT
