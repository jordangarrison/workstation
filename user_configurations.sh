#!/bin/bash

source $(dirname $0)/workstation.conf

handle_error() {
    local __retval="$1"
    local __msg="$2"
    if [ $RETVAL -ne 0 ] ; then
        echo "ERROR: ${__msg}. Return Value ${__retval}"
        exit $__retval
    fi
}

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

echo -n "Would you like to install Anaconda? [Y/N]: "
read answer
echo ""
if [[ "$answer" == "y" || "$answer" == "Y" ]] ; then
    if [ ! -d ~/anaconda3 ] ; then
        curl https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh --output /tmp/Anaconda302019.03-Linux-x86_64.sh
        bash /tmp/Anaconda302019.03-Linux-x86_64.sh
        RETVAL=$?
        handle_error $RETVAL "Error installing anaconda python"
    else
        echo "Anaconda is already installed, moving on"
    fi
else
    echo "Skipping anaconda installation this time, if you want to install this at a later date please rerun this script: $0"
fi

if [ -d ~/anaconda3 ] ; then
    echo "Installing python black formatter"
    ~/anaconda3/bin/pip install black
fi

echo "Installing awesome vimrc"
if [ ! -d ~/.vim_runtime ] ; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    RETVAL=$?
    handle_error $RETVAL "Error cloning awesome vimrc"
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    RETVAL=$?
    handle_error $RETVAL "Error Installing awesome vimrc"
fi

echo "Installing you complete me for vim"
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim_runtime/my_plugins/YouCompleteMe
__starting_dir=$(pwd)
cd ~/.vim_runtime/my_plugins/YouCompleteMe
git submodule update --init --recursive
RETVAL=$?
handle_error ${RETVAL} "Error submoduling YouCompleteMe Dependencies"
/usr/bin/python3 ./install.py --go-completer
cd $__starting_dir

# if [ -d ~/anaconda3 ] ; then
#     echo "Installing black formatter for python"
#     if [ ! -d ~/.vim_runtime/my_plugins/black ] ; then
#         git clone https://github.com/python/black.git ~/.vim_runtime/my_plugins/black
#     else
#         echo "Black plugin already installed"
#     fi
# fi

echo "Activating anaconda"
source ~/anaconda3/bin/activate

# The below command must run last because it invokes a shell for you to begin your work in
if [ ! -d ~/.oh-my-zsh ] ; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    RETVAL=$?
    handle_error $RETVAL "Error adding ohmyzsh"
    exit
else
    echo "You have already installed OH-MY-ZSH!"
fi

echo "Finished setting up workstation"
