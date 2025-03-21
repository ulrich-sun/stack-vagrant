#!/bin/bash
yum -y update
yum -y install epel-release

if [ $1 == "minishifts" ]
then
        echo "###################################################"
        echo "Install minishift"
        echo "###################################################"
        curl -L https://github.com/minishift/minishift/releases/download/v1.16.1/minishift-1.16.1-linux-amd64.tgz -o minishift.tar.gz
        tar -xvzf minishift.tar.gz
        cd minishift-1.16.1-linux-amd64
        cp minishift /usr/bin/
        export PATH=$PWD:$PATH
        export MINISHIFT_ENABLE_EXPERIMENTAL=y
        minishift addons disable minishift-mobilecore-addon
        minishift delete
        rm -rf ~/.minishift/machines
        minishift start --vm-driver generic --remote-ipaddress $2 --remote-ssh-user vagrant --remote-ssh-key /home/vagrant/.ssh/minishift.key --openshift-version v3.7.0
        cp /root/.minishift/cache/oc/v3.7.0/linux/oc /usr/bin/

        echo "###################################################"
        echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
        echo "###################################################"
else
        echo "###################################################"
        echo "Create docker host"
        echo "###################################################"
        # Install docker

        #ref : https://github.com/mikenairn/minishift-vagrant
        yum install -y docker net-tools

        groupadd docker || true
        usermod -aG docker vagrant || true

        systemctl restart docker || true
        systemctl enable docker || true

        yum install -y sshpass
        echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
fi