# OpenCV 4.10.0 

show_opencv_menu()
{
	clear
	printf "OpenCV setup menu \n----------\n\
select setup option or x to exit \n\
1) Install - Python only \n\
2) Build/install - local \n\
3) Build/install - server \n\
4) Install - client \n"
}

install_python()
{
	python pip3 install opencv-python opencv-contrib-python
}

install_deps()
{
	apt-get -y install libjpeg-dev libpng-dev libavcodec-dev libavformat-dev libswscale-dev libgtk2.0-dev libcanberra-gtk* libgtk-3-dev libgstreamer1.0-dev gstreamer1.0-gtk3 libgstreamer-plugins-base1.0-dev gstreamer1.0-gl libxvidcore-dev libx264-dev python3-numpy python3-pip libtbbmalloc2 libdc1394-dev libv4l-dev v4l-utils libopenblas-dev libatlas-base-dev libblas-dev liblapack-dev gfortran libhdf5-dev libprotobuf-dev libgoogle-glog-dev libgflags-dev protobuf-compiler
}

install_local()
{
	cd $usrpath
	# Check memory
	memtot=$(grep MemTotal /proc/meminfo | tr -cd '[:digit:].')
 	if [ $memtot -lt 5800000 ]
	then
		sed -i "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g" /etc/dphys-swapfile
		/etc/init.d/dphys-swapfile restart
	fi
 	install_deps
	git clone https://github.com/opencv/opencv.git
	git clone https://github.com/opencv/opencv_contrib.git
	mkdir opencv/build
	cd opencv/build
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=$usrpath/opencv_contrib/modules -D ENABLE_NEON=ON -D WITH_OPENMP=ON -D WITH_OPENCL=OFF -D BUILD_TIFF=ON -D WITH_FFMPEG=ON -D WITH_TBB=ON -D BUILD_TBB=ON -D WITH_GSTREAMER=ON -D BUILD_TESTS=OFF -D WITH_EIGEN=OFF -D WITH_V4L=ON -D WITH_LIBV4L=ON -D WITH_VTK=OFF -D WITH_QT=OFF -D WITH_PROTOBUF=ON -D OPENCV_ENABLE_NONFREE=ON -D INSTALL_C_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D PYTHON3_PACKAGES_PATH=$usrpath/.venv/lib/python3.11/site-packages -D OPENCV_GENERATE_PKGCONFIG=ON -D BUILD_EXAMPLES=OFF ..
	cores=$(nproc)
	make -j$cores all
	make install
	ldconfig
	cd $usrpath
	rm -rf opencv*
	if [ $memtot -lt 5800000 ]
	then
		sed -i "s/CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/g" /etc/dphys-swapfile
		/etc/init.d/dphys-swapfile restart
	fi
	read -p "OpenCV $(opencv_version) Local install finished, press enter to return to menu" input
}

install_server()
{
	install_local
	if grep -F "/usr/local" "/etc/exports"; then
  		echo "export exists"
  	else
		echo "/usr/local $localnet(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
  		exportfs -ra
	fi
	read -p "OpenCV $(opencv_version) Server install finished, press enter to return to menu" input
}

# 3- Install to run from server
install_client()
{
	read -p "Remote node (integer only): " nfsrem
	read -p "Full path to remote directory (press enter for default = /usr/local): " userdir
	nfsdir=${userdir:="/usr/local"}
	mkdir -p $nfsdir
 	if grep -F $nfsdir "/etc/fstab"; then
  		echo "mount already exists"
    	else
		echo "pinode-$nfsrem.local:$nfsdir $nfsdir    nfs defaults" >> /etc/fstab
  	fi
	mount -a
 	#systemctl daemon-reload
  	install_deps
  	ldconfig
   	#su -c "scp -r multipi@pinode-$nfsrem:$usrpath/.venv/lib/python3.11/site-packages/cv2 $usrpath/.venv/lib/python3.11/site-packages/" multipi
    	cp -r $usrpath/share1/lib/python3/cv2 $usrpath/.venv/lib/python3.11/site-packages/
	read -p "OpenCV $(opencv_version) Client install done, press enter to return to menu" input
}

# Run in Python Virtual Environment
source $usrpath/.venv/bin/activate
show_opencv_menu
read -p "Select option or x to exit to main menu: " n
while [ $n != "x" ]; do
	case $n in
		1) install_python;;
		2) install_local;;  
		3) install_server;;
		4) install_client;;
		*) read -p "invalid option - press enter to continue" errkey;;
	esac
	show_opencv_menu
	read -p "Select option or x to exit to main menu: " n
done
deactivate
