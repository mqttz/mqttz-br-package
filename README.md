# Buildroot MQTTZ Custom Package Template

Small repo containing the code to load the MQTTZ source to buildroot.

To compile MQT-TZ with OP-TEE:

1. Clone this directory inside `buildroot/package`. In the following steps we'll
   assume the name of the directory is `mqttz`.
2. Edit the variable `MQTTZ_SITE` on `mqttz.mk` with the correct path.
3. Add the following line at the end of the file `buildroot/package/Config.in`
   ```
   source "package/mqttz/Config.in"
   ```
4. Go to `build/common.mk` and add the following line
   ```
   BR2_PACKAGE_MQTTZ=y
   ```

When you compile the OS, MQT-TZ will be compiled as well.

During the compilation, a copy of the MQT-TZ directory will be made to
`out-br/build/mqttz`, which is what will be used when compiling the OS. Because
of this, you will have to run make clean inside the original MQT-TZ directory
(if you don't, OP-TEE will just take the compiled binaries, which will probably
not be compatible with the architecture). On top of that, once you have compiled
MQT-TZ once, any changes to the original code will be ignored by OP-TEE, since
its copy will be untouched. To solve this, you can delete the copy at
`out-br/build/mqttz`, forcing it to make a fresh copy. If you are editing
MQT-TZ and testing it, a quick way of not missing anything is to run:

```
rm -rf ../out-br/build/mqttz/ && make -C /path/to/mqttz clean && make -j `nproc`
```

from the `build` directory (or, alternatively, with `make run` if you want to
run it with QEMU).
