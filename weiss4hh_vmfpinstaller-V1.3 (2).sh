#!/bin/bash
#############################################################################################
#
#		This script install L7.0 blackbox build
#
#############################################################################################


PRODUCT="Weiss4HH"
#REDMINE_SERVER="10.188.105.88"
REDMINE_SERVER="10.188.103.153"
newfile="/root/version/ebxversion.txt"
oldfile="/root/currentbuild/ebxversion.txt"
BUILD_NUM=""

############################# Installing RFS  ##############################################
rfs_install() {
      echo "Installing rfs..." >>/root/bb.log
      cd /root/
      rm -rf /root/bbrfs/
      svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/$BUILD_NUM/bbrfs
      cd bbrfs
      if [ -f *.deb ];then
         dpkg -i *.deb
         echo "RFS installed successfully.." >>/root/bb.log    
         echo "V21.x.0.700.xx" >/root/chroot/weiss2VMFP_RootFS/home/ebxversion.txt
      else
         echo "There is no new rfs available" >>/root/bb.log
      fi  
      echo "Installing rfs end..." >>/root/bb.log
}

############################# Applying patch  ##############################################
patch_install() {
      echo "Checking for patch..." >>/root/bb.log
      cd /root/
      rm -rf /root/patch/
      newversion=`cat $newfile`
      buildnum=$(echo "$newversion" | cut -d'.' -f5);
      build="B700."
      finalBuildVar=$build$buildnum
      BUILD_NUM=$finalBuildVar
      svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/$BUILD_NUM/patch
      cd patch
      if [ -f *.deb ];then
        echo "Info: Patch is available for $BUILD_NUM"
        read -p "Do you want to install patch? yes/no :" option
        if [ "yes" = $option ]; then
           dpkg -i *.deb
           echo "Patch applied successfully"  >>/root/bb.log
           echo "Rebooting machine"  >>/root/bb.log
           sleep 5
           reboot
        else
           echo "Bye.."
        fi
      else
         echo "There is no patch available for $BUILD_NUM" >>/root/bb.log
      fi
      echo "patch_install() end..." >>/root/bb.log
} 

############################# GET PANEL STATUS  ##############################################
panel_status () {
    echo "Get panel status..." >>/root/bb.log
    pgrep alUiFrameWork
    if [ $? -eq 0 ];then
       echo "As panel is running..Can't be install, please reboot vMFP machine and run install script again.." 
       read -p "Do you want to reboot? yes/no :" option
       if [ "yes" = $option ]; then
          reboot
       else
          echo "Bye.."
        fi
    else
       echo "No ebn process are running"  >>/root/bb.log 
    fi
    echo "Get panel status end..." >>/root/bb.log
}

############################# GET N/W STATUS  ##############################################
network_check () {
    echo "N/W checking..." >>/root/bb.log
    if ping -q -c 1 -W 1 $REDMINE_SERVER >/dev/null; then
        return 1
    else
        return 0  
    fi

}

############################# CONFIGURE PROXY  ##############################################
configure_proxy ()
{
    echo "Configure proxy details..." >>/root/bb.log
    read  -p "Enter HRIS User Name: " username
    echo -n "Enter HRIS Password: " ;stty -echo; read passwordd; stty echo;echo
    export http_proxy=http://$username:password@proxy:8080
    apt-get update
    apt-get install subversion -y
    echo "Configure proxy details end..." >>/root/bb.log
}

############################# UPDEATS CHECK #################################################
updates_check () {
    echo "Updates check..." >>/root/bb.log
    network_check
    retVal=$?
    if [ "$retVal" -eq "1" ]; then
      svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/version
      mkdir -p /root/currentbuild
      cp -r /root/chroot/weiss2VMFP_RootFS/home/ebxversion.txt /root/currentbuild
      newversion=`cat $newfile`
      oldversion=`cat $oldfile`
      echo "Current installed build version: $oldversion"
      if [ $oldversion !=  $newversion ]; then
        read -p "New build version: $newversion is avalable, Enter: 1->New build install or  2->Old build install:" option
        if [ 1 -eq $option ]; then
          echo "This will take several minutes, please wait..."
          install_bb
        elif [ 2 -eq $option ]; then
          install_oldbuild
        fi
      else 
        patch_install	
        echo "Info: There is no updates are availabe from build server"
        read -p "Do you want to install Old build? yes/no :" option
        if [ "yes" = $option ]; then
           install_oldbuild
        else
           echo "Bye.."
        fi

      fi
    else
      echo "Err: Check your network connection,there is no network in vMFP machine "
      echo "Resolve: shutdown vmfp machine, open virtual box->Network settings->NAT, then Start vMFP machine"
   fi
   echo "Updates check end..." >>/root/bb.log
}

############################# NEW BUILD VERSION  #################################################
build_num () {
    echo "Get build number..." >>/root/bb.log
    newversion=`cat $newfile`
    buildnum=$(echo "$newversion" | cut -d'.' -f5);
    build="B700."
    finalBuildVar=$build$buildnum
    echo "Get build number end..." >>/root/bb.log
}

############################# INSTALL OLD BUILD  #################################################
install_oldbuild () {
    echo "Installing  old build..."  >>/root/bb.log
    rm -rf /root/bb/
    svn list  svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT
    read -p "Enter Old Build version from above List ex B700.50:  " BuildVersion
    BUILD_NUM=$BuildVersion         
    rfs_install
    cd /root/
    echo "This will take several minutes, please wait..."
    svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/$BuildVersion/bb/ >>/root/bb.log
    cd bb
    dpkg -i *.deb
    echo "Black box is installed" >>/root/bb.log
    echo "Installing  old build end..."  >>/root/bb.log
    patch_install

}

############################# INSTALL NEW BLACKBOX  #################################################
install_bb () {  
     echo "Installing new build..." >>/root/bb.log
     rm -rf /root/bb/ 
     newversion=`cat $newfile`
     buildnum=$(echo "$newversion" | cut -d'.' -f5);
     build="B700."
     finalBuildVar=$build$buildnum
     BUILD_NUM=$finalBuildVar
     rfs_install
     echo $finalBuildVar	
     dpkg -s subversion >>/root/bb.log
     if [ 0 -eq $? ]; then
        echo "subversion is installed" >>/root/bb.log 
        cd /root/
        svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/$finalBuildVar/bb/ >>/root/bb.log
        cd bb
        dpkg -i *.deb
        patch_install
        echo "Black box is installed" >>/root/bb.log
        cp /root/ebxversion.txt /root/currentbuild/
     else
        echo "subversion pkg not installed" >>/root/bb.log 
     apt-get install subversion -y >>/root/bb.log
     if [ 0 -eq $? ]; then
        svn co svn://$REDMINE_SERVER/trunk/vmfp/L7.0/$PRODUCT/$finalBuildVar/bb/ >>/root/bb.log
        cd bb
        dpkg -i *.deb
        patch_install
        echo "Black box is installed" >>/root/bb.log
        cp /root/version/ebxversion.txt /root/currentbuild/
     else
        echo "subversion not installed. Configure proxy details in /etc/apt/apt.conf and try again."
        exit 0
     fi 
     fi
     echo "Installing new build... end" >>/root/bb.log
}


##############################################################################################
#
#                     DRIVER TO INSTALL OLD/NEW BLACK BOX BUILDS
#
##############################################################################################

rm -f /root/bb.log
panel_status
configure_proxy 
updates_check


