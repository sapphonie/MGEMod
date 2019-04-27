cd $BUILD_REPOSITORY_LOCALPATH/addons/sourcemod/scripting
sed -i'' -r -e "s/(#define PL_VERSION \")[^\"]*\"/\1$1\"/" "mgemod.sp"
