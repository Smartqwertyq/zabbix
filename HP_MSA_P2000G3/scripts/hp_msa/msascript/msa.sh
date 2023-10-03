#!/bin/bash

###########VAR
login='zabbix'
pwd='PASSWORD'
mgmt_host1=ip_addres_controller1
mgmt_host2=ip_addres_controller2
logdir='/usr/lib/zabbix/externalscripts/hp_msa/msalog'
tempfile='/usr/lib/zabbix/externalscripts/hp_msa/msalog/msa_temp.log'


############Precheck
if nc -z $mgmt_host1 22 2>/dev/null; then
host=$mgmt_host1
else
if nc -z $mgmt_host2 22 2>/dev/null; then
host=$mgmt_host2
fi
fi


############Enclosures (FAN/PSU/Tempeture/Voltage)
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show enclosure-status
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msafan.log
date +'%d.%m.%y %H:%M:%S'>$logdir/msapsu.log
date +'%d.%m.%y %H:%M:%S'>$logdir/msatemperature.log
date +'%d.%m.%y %H:%M:%S'>$logdir/msavolt.log

cat $tempfile |
grep -P 'FAN' |
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g' >>$logdir/msafan.log

cat $tempfile |
grep -P 'PSU'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g' >> $logdir/msapsu.log

cat $tempfile |
grep -P 'Temp'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g' >>$logdir/msatemperature.log

cat $tempfile |
grep -P 'Voltage'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g' >>$logdir/msavolt.log

cat /dev/null > $logdir/msa_temp.log

#################HDD
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show disks
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msahdd.log
cat $tempfile |
grep -a -C1 -P 'GB' |
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -d '-'|tr -d '-'|sed '/^$/d'| tr -s '  ' ' '|
xargs -n2 -d'\n'|
sed 's/^[ ]*//g' >> $logdir/msahdd.log

cat /dev/null > $logdir/msa_temp.log

################VDISKs
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show vdisks
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msavdisk.log
cat $tempfile |
grep -a -C2 -P 'TB' |
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
sed  '1d'|sed '1d'|
tr -d '\b'| tr -d '-'|
tr -s '  ' ' '|
sed 's/^[ ]*//g'|
xargs -n3 -d'\n' >>$logdir/msavdisk.log

cat /dev/null > $logdir/msa_temp.log


#############EVENTS
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show events error last 10
echo 'ok'
exit
EOF

cat $tempfile|
grep -a -P 'P2000'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed '1d' >>$logdir/msaevents.log

cat /dev/null > $logdir/msa_temp.log

############CONTROLLERS
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show controllers
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msacontr.log
cat $tempfile|
grep -a -P 'Controller ID|Health:|Status:'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g'|
xargs -n4 -d'\n'  >>$logdir/msacontr.log

cat /dev/null > $logdir/msa_temp.log

############PORTS
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show ports
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msaport.log
cat $tempfile|
grep -a -P 'A1|A2|B1|B2|A3|B3'|
sed {s/'Press any key to continue (Q to quit)//'} | #sed 's/OK/Fault/g'| #TEST
tr -d '\b'|
tr -s '  ' ' '|
sed 's/^[ ]*//g' >>$logdir/msaport.log

cat /dev/null > $logdir/msa_temp.log


################Volumes
sshpass -p $pwd ssh -o hostkeyalgorithms=+ssh-dss $login@$host << EOF
show volumes
echo 'ok'
exit
EOF

date +'%d.%m.%y %H:%M:%S'>$logdir/msavol.log
cat $tempfile|
grep -a -C3 -P 'TB'| # sed 's/OK/Fault/g'| #TEST
tr -d '-'|sed '1,2d'|
tr -s '  ' ' '|sed '1d'|sed '/^$/d'|
xargs -n5 -d'\n' >>$logdir/msavol.log

cat /dev/null > $logdir/msa_temp.log
