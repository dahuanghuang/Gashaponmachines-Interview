#!/bin/bash

cd ./Frameworks/

# rename current framework to simulator 
mv GDTActionSDK.framework GDTActionSDK.sim.framework
mv GDTActionSDK.device.framework GDTActionSDK.framework

echo "switch GDTActionSDK success"
# Ex: to remove from git
# for i in `./script/unused_images.sh`; do git rm "$i"; done