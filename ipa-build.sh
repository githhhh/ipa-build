#!/bin/sh

#  ipa-build.sh
#  project
#
#  Created by 唐斌 on 14-4-21.
#  Copyright (c) 2014年 project. All rights reserved.

#变量
findWorkspacePath=""
configurationModel=""

#添加configuration参数
if [ -z $1 ];then
    echo "\n [!] Miss option paramter \n"
    echo "\t\t Did you option: Debug、Release 、AdHoc \n"
    exit
else
    configuration_array=("Debug","Release","AdHoc")
    if echo "${configuration_array[@]}" | grep -w "$1" &>/dev/null; then
        configurationModel=$1
    else
        echo "\n [!] Unknown option: '$1'\n"
        echo "\t\t Did you mean: Debug、Release 、AdHoc \n"
        exit
    fi
fi

#工程绝对路径
project_path=$(pwd)
#build文件夹路径
build_path=${project_path}/build
#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')


cd $project_path

#删除bulid目录
if  [ -d ${build_path} ];then
   rm -rf ${build_path}
fi

#去掉xcode源码末尾的空格
#find . -name "*.[hm]" | xargs sed -Ee 's/ +$//g' -i ""

#find .xcworkspace
for workspacePath in `find ${project_path} -name "${project_name}.xcworkspace" -print`
do
   findWorkspacePath=${workspacePath}
   break
done

if [ "$findWorkspacePath" == "" ];then
   #清理工程
   xcodebuild  -project ${project_name}.xcodeproj \
               -scheme ${project_name} \
               -sdk iphoneos \
               clean || exit

  xcodebuild  -configuration $configurationModel \
			   -project "${project_path}/${project_name}.xcodeproj" \
			   -scheme ${project_name} \
			   SYMROOT="${PWD}/build" || exit
else
   #清理工程
   xcodebuild  -workspace ${project_name}.xcworkspace \
               -scheme ${project_name} \
               -sdk iphoneos \
               clean || exit

   xcodebuild  -configuration $configurationModel \
			   -workspace "${project_name}.xcworkspace" \
			   -scheme ${project_name} \
			   SYMROOT="${PWD}/build" || exit
fi



if [ -d ./ipa-build ];then
    rm -rf ipa-build
fi

#打包
cd $build_path

mkdir -p ipa-build/Payload

cp -r ./${configurationModel}-iphoneos/*.app ./ipa-build/Payload/

cd ipa-build

zip -r ${project_name}.ipa *

echo ${build_path}/ipa-build/${project_name}.ipa

#找到桌面路径
cd ~/Desktop
#拷贝文件
cp -r ${build_path}/ipa-build/${project_name}.ipa  $(pwd)
#清空bulid目录
cd ${build_path}/ipa-build
#清理
rm -rf Payload

if  [ -d ${build_path} ];then
    rm -rf ${build_path}
fi

