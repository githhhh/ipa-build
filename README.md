## ipa-build 

自动生成ipa,并拷贝到mac 桌面

## 使用

* 请确保Xcode中的证书配置正确

1、可能需要修改shell 脚本执行权限

```
 $ sudo chmod 777 path-to/ipa_build.sh
```


2、导入下面别名到~/.zshrc (如果你用bsh,请导入对应配置文件)

```
 alias ipabuild=path-to/ipa-build.sh
```

3、项目目录下执行， 将生成指定模式ipa到桌面，默认可选：Debug 、Release、AdHoc

```
$ cd project-rootdir
$ ipabuild AdHoc
```


* 自定义ipa 模式

打开ipa-build.sh ，修改一下代码,替换数组为自定义模式

```
   configuration_array=("Debug","Release","AdHoc")
```


