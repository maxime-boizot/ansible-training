#!/bin/bash
FOLDER="/root/host_deploy"
RSA_KEY="$FOLDER/admin_rsa"

echo "====START===="

if [ "$1" = "PROXMOX" ]
        then
                echo "====Dump_performance for proxmox===="
                for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/dump_performance_promox.sh root@$i:/usr/sbin/dump_performance.sh; done
        else
                echo "====Dump_performance for ALL===="
                for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/dump_performance.sh root@$i:/usr/sbin/; done
fi

echo "====bash.bashrc===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/bash.bashrc root@$i:/etc; done
echo "====shared===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/shared.common_bashrc_path  root@$i:/etc; done
echo "====bashrc===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/bashrc root@$i:/root/.basrc; done
echo "====vimrc===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/vimrc root@$i:/root/.vimrc; done
echo "====toprc===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/toprc root@$i:/root/.toprc; done
echo "====ubiwan.bashrc===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/ubiwan.bashrc root@$i:/etc; done
echo "====rsyslog===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/rsyslog_ubiwan.conf root@$i:/etc/rsyslog.d/ubiwan.conf; done
echo "====logrotate===="
for i in $(cat $FOLDER/$1); do echo $i && scp -i $RSA_KEY $FOLDER/logrotate_ubiwan.conf root@$i:/etc/logrotate.d/ubiwan.conf; done
#echo "====mkdir /run/sshd===="
#for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "mkdir /run/sshd"; done

if [ "$2" = "NEW" ]
        then
                echo "====mkdir /var/log/dump_perf/===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "mkdir -p /var/log/dump_perf/"; done
                if [[ -z $(ssh -i $RSA_KEY root@$i "grep -iR 'dump_performance' /etc/crontab") ]]
                        then
                                echo "====echo crontab===="
                                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "echo '*/5 * * * *   root    /usr/sbin/dump_performance.sh >/dev/null 2>&1' >> /etc/crontab"; done
                                #for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "echo '*/5 * * * *   root    /usr/sbin/dump_performance.sh > /var/log/dump_perf/cron.log 2> /var/log/dump_perf/cron.errors.log' >> /etc/crontab"; done
                        else
                                echo "====CRONTAB already exist===="
                fi
                echo "====Uncomment en_US in locale.gen===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen"; done
                echo "====Generate locale-gen===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "/usr/sbin/locale-gen"; done
                echo "====Timedatectl===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "timedatectl set-timezone \"Europe/Paris\""; done
                echo "====Log SNMPD===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/-Lsd/-LS0-4d/g' /lib/systemd/system/snmpd.service"; done
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/-LOw/-LS0-4d/g' /lib/systemd/system/snmpd.service"; done
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/-LS4d/-LS0-4d/g' /lib/systemd/system/snmpd.service"; done
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/-Ls4d/-LS0-4d/g' /lib/systemd/system/snmpd.service"; done
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "systemctl daemon-reload"; done
                echo "====Yes to X11Forwardin in SSHD===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/X11Forwarding no/X11Forwarding yes/g' /etc/ssh/sshd_config"; done
                echo "====Uncomment X11Forwardin in SSHD===="
                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "sed -i 's/\#       X11Forwarding/       X11Forwarding/g' /etc/ssh/sshd_config"; done
                if [[ -z $(ssh -i $RSA_KEY root@$i "grep -iR '@rsyslog\|Escape8BitCharactersOnReceive' /etc/rsyslog.conf") ]]
                        then
                                echo "====rsyslog===="
                                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "echo '*.* @rsyslog.ubiwan.dmz' >> /etc/rsyslog.conf"; done
                                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "echo '\$Escape8BitCharactersOnReceive on' >> /etc/rsyslog.conf"; done
                                for i in $(cat $FOLDER/$1); do echo $i && ssh -i $RSA_KEY root@$i "systemctl restart rsyslog"; done
                fi
fi
echo "====END===="