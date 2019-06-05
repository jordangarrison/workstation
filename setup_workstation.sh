#!/bin/bash

source $(dirname $0)/workstation.conf

if [[ $(whoami) != "root" ]] ; then
    echo "You must run as root"
    exit 1
fi

handle_error() {
    local __retval="$1"
    local __msg="$2"
    if [ $RETVAL -ne 0 ] ; then
        echo "ERROR: ${__msg}. Return Value ${__retval}"
        exit $__retval
    fi
}

echo "Installing the following packages:"
for i in $(<$PACKAGES) ; do
    echo "  $i"
done

apt update
RETVAL=$?
handle_error $RETVAL "Unable to update apt local cache"
echo apt install -y $(cat $PACKAGES | grep -v '#')
apt install -y $(cat $PACKAGES | grep -v '#')
RETVAL=$?
handle_error $RETVAL "Error installing packages"

echo -n "Is this WSL? [Y/N]: "
read answer
echo ""
if [[ "$answer" == "y" || "$answer" == "Y" ]] ; then
    echo "Setting up paths for WSL systems"
    echo -n "What is your windows user name? "
    read answer
    ln -sf /mnt/c/Users/${answer} ~/windows
    RETVAL=$?
    handle_error $RETVAL "Error linking windows directory"
    ln -sf ~/windows/Documents ~/documents
    RETVAL=$?
    handle_error $RETVAL "Error linking docuements directory"
    ln -sf ~/windows/Downloads ~/downloads
    RETVAL=$?
    handle_error $RETVAL "Error linking downloads directory"
fi

echo -n "Would you like to install Docker? [Y/N]: "
read answer
echo ""
if [[ "$answer" == "y" || "$answer" == "Y" ]] ; then
    if [[ "$(which docker)" == "" ]] ; then
        echo "Installing Docker"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        RETVAL=$?
        handle_error $RETVAL "Error adding Docker GPG key"

        add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        RETVAL=$?
        handle_error $RETVAL "Error adding docker repository to sources"

        apt update
        RETVAL=$?
        handle_error $RETVAL "Error updating repo cache"

        apt install -y docker-ce docker-ce-cli containerd.io
        RETVAL=$?
        handle_error $RETVAL "Error installing docker packages"

        if [ ! -f /.dockerenv ] ; then
            systemctl daemon-reload
            RETVAL=$?
            handle_error $RETVAL "Error reloading daemons"
            systemctl restart docker
            RETVAL=$?
            handle_error $RETVAL "Error restarting docker"
        else
            echo "No sytemctl command in docker containers"
        fi
    else
        echo "Docker already installed"
    fi
else
    echo "Skipping Docker installation, if you want to install docker at a later time simply rerun this script: $0"
fi

echo "Finished setting up workstation"
