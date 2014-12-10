#!/bin/sh

#  ipa-build.sh
#  project
#
#  Created by 唐斌 on 14-4-21.
#  Copyright (c) 2014年 project. All rights reserved.
#!/bin/bash

#执行git 命令
#git st
#exit


workspaceExt=".xcworkspace"
tempPath=""



#工程绝对路径
#cd $1
project_path=$(pwd)
#build文件夹路径
build_path=${project_path}/build

#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
project_infoplist_path=${project_path}/${project_name}/${project_name}-Info.plist
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${project_infoplist_path})
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${project_infoplist_path})
#取bundle Identifier前缀
bundlePrefix=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" `find . -name "*-Info.plist"` | awk -F$ '{print $1}')


cd $project_path
echo "***clean  start**"

#删除bulid目录
if  [ -d ${build_path} ];then
rm -rf ${build_path}

echo "***clean build_path success***"
fi

#去掉xcode源码末尾的空格
#find . -name "*.[hm]" | xargs sed -Ee 's/ +$//g' -i ""


#find .xcworkspace
for workspacePath in `find ${project_path} -name "$project_name$workspaceExt" -print`
do
tempPath=${workspacePath}
break
done

if [ "$tempPath" == "" ];then

#清理工程
xctool  -project ${project_name}.xcodeproj \
        -scheme ${project_name} \
        -sdk iphoneos \
        clean || exit

#编译工程  Distribution  Release Debug
xctool  -configuration Debug \
        -sdk iphoneos \
        -project ${project_path}/${project_name}.xcodeproj \
        -scheme ${project_name} \
         ONLY_ACTIVE_ARCH=NO \
        TARGETED_DEVICE_FAMILY=1 \
        DEPLOYMENT_LOCATION=YES CONFIGURATION_BUILD_DIR=${project_path}/build/Release-iphoneos || exit

else

#清理工程
xctool  -workspace ${project_name}.xcworkspace \
        -scheme ${project_name} \
        -sdk iphoneos \
        clean || exit

#编译工程  Distribution  Release Debug
xctool  -configuration Debug  -workspace ${project_path}/${project_name}.xcworkspace \
        -scheme ${project_name} \
        -sdk iphoneos \
        ONLY_ACTIVE_ARCH=NO \
        TARGETED_DEVICE_FAMILY=1 \
        DEPLOYMENT_LOCATION=YES CONFIGURATION_BUILD_DIR=${project_path}/build/Release-iphoneos  || exit

fi




if [ -d ./ipa-build ];then
rm -rf ipa-build
fi
#打包
cd $build_path
mkdir -p ipa-build/Payload
cp -r ./Release-iphoneos/*.app ./ipa-build/Payload/
cd ipa-build
zip -r ${project_name}.ipa *

echo ${build_path}/ipa-build/${project_name}.ipa
#找到桌面路径
cd ~/Desktop
#echo Desktop dir
#echo $(pwd)
#拷贝文件
cp -r ${build_path}/ipa-build/${project_name}.ipa  $(pwd)
#清空bulid目录
cd ${build_path}/ipa-build
rm -rf Payload
if  [ -d ${build_path} ];then
rm -rf ${build_path}
fi
#done


