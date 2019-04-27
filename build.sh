# Compile the plugin in the build directory, because that's where we put the SourceMod compiler and includes.
cd $BUILD_REPOSITORY_LOCALPATH/addons/sourcemod/scripting
./spcomp mgemod.sp

# Move the compiled plugin into the artifact staging directory.
mkdir -p $BUILD_ARTIFACTSTAGINGDIRECTORY/addons/sourcemod/plugins
mv $BUILD_REPOSITORY_LOCALPATH/addons/sourcemod/scripting/mgemod.smx $BUILD_ARTIFACTSTAGINGDIRECTORY/addons/sourcemod/plugins

# Create the artifact zip
cd $BUILD_ARTIFACTSTAGINGDIRECTORY
zip -r mgemod.zip addons maps

# Move the artifact zip back to the build dir, so that semantic-release can find it.
mv mgemod.zip $BUILD_REPOSITORY_LOCALPATH/
