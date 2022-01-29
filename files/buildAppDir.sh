#!/bin/bash -x
# exit when any command fails
#set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "===== Environment: ===="
env | sort
echo "===== current directory ===="
pwd
ls -la

mkdir -p AppDir/usr/lib AppDir/usr/bin
cp -r oolite/oolite.app AppDir/usr/lib
cp -r oolite/deps/Linux-deps/x86_64/lib AppDir/usr/lib/oolite.app
cp oolite/installers/FreeDesktop/oolite-icon.png AppDir

while :
do
	# find missing libs
	LD_LIBRARY_PATH=AppDir/usr/lib/oolite.app/lib ldd AppDir/usr/lib/oolite.app/oolite | grep "=> /lib" | grep -v libc.so | grep -v libpthread | grep -v librt >/tmp/libs.txt
	for f in $( find AppDir/usr/lib/oolite.app/lib -name "*.so.*" )
	do
		LD_LIBRARY_PATH=AppDir/usr/lib/oolite.app/lib ldd $f | grep "=> /lib" | grep -v libc.so | grep -v libpthread | grep -v librt
	done >> /tmp/libs.txt
	
	# bail out if none are missing
	if [ ! -s /tmp/libs.txt ]
	then
		break
	fi
	
	# copy over the missing ones
	while IFS= read -r line
	do
		echo $line
		library=`echo $line | awk '{ print $3 }'`
		cp $library AppDir/usr/lib/oolite.app/lib
	done < /tmp/libs.txt
	
done

echo still missing:
cat /tmp/libs.txt

cat << 'EOF_OOLITE_WRAPPER' > "AppDir/usr/bin/oolite"
#!/bin/bash -x
echo called from ${PWD} as ${0} "$@"

WRAPPERDIR=`dirname ${0}`
OOLITE_DIR=`dirname ${WRAPPERDIR}`

env | sort


ls -l ${OOLITE_DIR}/lib/oolite.app/
#ESPEAK_DATA_PATH=${OOLITE_DIR}/lib/oolite.app/Resources
LD_LIBRARY_PATH=${OOLITE_DIR}/lib/oolite.app/lib ${OOLITE_DIR}/lib/oolite.app/oolite
EOF_OOLITE_WRAPPER
chmod +x AppDir/usr/bin/oolite

# we have all the necessary libs in the libs folder. Move on...

