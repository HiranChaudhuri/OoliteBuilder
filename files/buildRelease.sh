#!/bin/bash -x

mkdir -p release/Doc
cp -r oolite/Doc/AdviceForNewCommanders.pdf release/Doc
cp -r oolite/AddOns release
cp -r oolite/oolite.app release
cp -r oolite/deps/Linux-deps/x86_64/lib release/oolite.app

cat << 'EOF_OOLITE_WRAPPER' > "release/oolite"
#!/bin/bash -x
ESPEAK_DATA_PATH=oolite.app/Resources LD_LIBRARY_PATH=oolite.app/lib oolite.app/oolite
EOF_OOLITE_WRAPPER

chmod +x release/oolite

tar cvfz Oolite-Linux-Nightly.tar.gz release

