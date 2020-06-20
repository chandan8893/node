#! /bin/bash

###################################################################
#Script Name	: deploy.sh
#Description	: Single node Jenkins and Rancher deployment
#                 script. (Leveraging Docker)
#Args           : None
#Author       	: Donovan Austin
#eMail         	: Donovan.Austin@dimensiondata.com
###################################################################

if ! [ $(id -u) = 0 ]
then
    echo "ERROR: $0 must be run as su / root, exiting"
    exit
fi

OS=$(echo $(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om ) | awk '{ print $1 }')

echo "INFO: OS String: $OS"

case $OS in
    Ubuntu )
          # TODO: Update as per CENTOS Logic
          APT_URL=$(apt-cache policy | grep 500 | grep updates/main | awk '{print $2}' | awk -F\/ '{print $3}')
          if ping -c1 $APT_URL >/dev/null 2>&1
          then
              echo "INFO: Able to ping APT repo: $APT_URL"
          else
              echo "ERROR: Check network config, unable to ping: $APT_URL"
          fi

          if [ "$(apt -qq list ansible)" != "" ]
          then
              echo "INFO: Installing Ansible"
              apt -y install ansible
          fi
          ansible-playbook ./install.yml
          ;;
    CentOS )
        BASE_URL=$(yum repolist rhcd -v | grep "* base:" | awk -F\: '{print $2}' | tr -d " ")
        if ping -c1 $BASE_URL >/dev/null 2>&1
        then
            echo "INFO: Able to ping BASE repo: $BASE_URL"
        else
            echo "ERROR: Please check network config, unable to ping: $BASE_URL"
            exit 1
        fi

        # Check & Install EPEL
        if [ -z $(rpm -qa | grep epel-release) ]
        then
            echo "INFO: EPEL Repository not present, adding"
            sudo yum install -y epel-release
            if [ $? -eq 0 ]; then
                echo "INFO: EPEL Repository added successfully"
                sudo yum clean all
                sudo yum -y update
            else
                echo "ERROR: Failed to add EPEL Repository"
                exit 1
            fi
        else
          echo "INFO: EPEL Repository present, ensuring packages updated"
          sudo yum -y update
        fi

        # Check and install Ansible
        if [ "$(rpm -q ansible)" = "package ansible is not installed" ]
        then
            echo "INFO: Ansible not installed - installing"
            yum -y install ansible
            if [ $? -eq 0 ]; then
                    echo "INFO: EPEL Repository added successfully"
                else
                    echo "ERROR: Failed to add EPEL Repository"
                    exit 1
                fi
          else
            # Ansible Already Present
            echo "INFO: Package $(rpm -q ansible) present"
          fi
          ansible-playbook ./install.yml
          ;;
     RedHat )
          # TODO: Update as per CENTOS Logic
          YUM_URL=$(yum repolist rhcd -v | grep "server-rhui-rpms" | head -1  | awk -F\: '{print $2}')
          if ping -c1 $YUM_URL >/dev/null 2>&1
          then
              echo "Able to ping YUM repo: $YUM_URL"
          else
              echo "Please check network config, able to ping: $YUM_URL"
          fi

          if [ "$(rpm -q ansible)" = "package ansible is not installed" ]
          then
              echo "Installing Ansible"
              yum -y install ansible
          fi
          ansible-playbook ./install.yml
          ;;
    * )
          echo "Unsupported OS"
          exit 1
          ;;
esac
