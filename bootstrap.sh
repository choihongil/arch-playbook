#!/bin/bash
set -eu

case $(uname) in
    Linux)
        echo "Install git python"
        su -lc 'pacman -S --needed git python'
        # pip
        if [ ! -x ~/.local/bin/pip ]; then
            echo "Install pip"
            curl -O https://bootstrap.pypa.io/get-pip.py
            python get-pip.py --user
            rm get-pip.py
        fi
        # ansible
        if [ ! -x ~/.local/bin/ansible ]; then
            echo "Install ansible"
            ~/.local/bin/pip install --user ansible
        fi
        ANSIBLE_PLAYBOOK="${HOME}/.local/bin/ansible-playbook --become-method=su --ask-become-pass"
        PLAYBOOK="notebook-playbook.yml"
        
        # # select machine type
        # PS3="Select machine type: "
        # options=("notebook" "media server")
        # select opt in "${options[@]}"
        # do
        #     case $opt in
        #         notebook)
        #             PLAYBOOK="notebook-playbook.yml"
        #             break
        #             ;;
        #         "media server")
        #             PLAYBOOK="media_server-playbook.yml"
        #             break
        #             ;;
        #         *)
        #             echo "Invalid option"
        #             ;;
        #     esac
        # done
        ;;
    Darwin)
	# brew
	if ! which brew > /dev/null; then
	    echo "Install brew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
	# ansible
	if ! brew list --formula | grep ansible > /dev/null; then
	    echo "Install ansible"
	    brew install ansible
	fi
        ANSIBLE_PLAYBOOK=/usr/local/bin/ansible-playbook
        PLAYBOOK="mac-playbook.yml"
        ;;
esac

# arch-playbook
if [ ! -d ~/arch-playbook ]; then
    echo "Git clone arch-playbook repository"
    git clone https://github.com/choihongil/arch-playbook.git ~/arch-playbook
fi
# execute playbook
echo "Execute ansible playbook"
cd ~/arch-playbook
${ANSIBLE_PLAYBOOK} -i local $PLAYBOOK
