#!/bin/bash

cd ./Frameworks/

# rename current framework to simulator 
mv GDTActionSDK.framework GDTActionSDK.device.framework
mv GDTActionSDK.sim.framework GDTActionSDK.framework

echo "switch GDTActionSDK success"
# Ex: to remove from git
# for i in `./script/unused_images.sh`; do git rm "$i"; done