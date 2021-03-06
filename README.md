# geany_dlang
Geany D language support plugin

Features
-----
* Autocompletion
* Arguments tips

Build
-----
At first, you should get Geany with GTK3 support.
Try to find binaries or compile it by yourself:
```
git clone https://github.com/geany/geany.git
cd geany
./autogen.sh --enable-gtk3
make
make install # as root, or using sudo
```

Compile and install plugin:
```
dub fetch geany_dlang
dub build --build=release geany_dlang
sudo cp ~/.dub/packages/geany_dlang-*/geany_dlang/libgeany_dlang.so /usr/local/lib/geany/geany_dlang.so
```

For comfortable working with standard library do not forget to add imports paths to dcd.conf:
```
$ cat ~/.config/dcd/dcd.conf
/usr/include/dmd/phobos
/usr/include/dmd/druntime/import
```

After this you can start Geany and enable plugin in "Plugin Manager".

Usage
-----
Currently plugin conflicts with standard Geany's autocompletion.
Thus, you should disable autocompletion at all for comfortable working with plugin.
Also plugin is not respects Geany configurations and autocompletion works always after each key is pressed.
