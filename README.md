## Introduction
这是一个通知中心插件，用于在通知中心显示日期。这个插件可以让你滑下通知中心就能方便地查看公历农历日期。

## Screenshots
![截图1](https://raw.github.com/crazytonyli/ChineseCalendar/master/screenshots/1.png "截图1")

![截图2](https://raw.github.com/crazytonyli/ChineseCalendar/master/screenshots/2.png "截图2")

## How to install?
可以通过两种方式来安装本插件：

  - 在Cydia搜索"Chinese Calendar for Notification Center"即可找到本插件；
  - 从源代码编译并安装到设备中。

## How to compile?
前提:

  - 已安装[Theos](https://github.com/DHowett/theos)
  - [iPhone Headers](https://github.com/rpetrich/iphoneheaders)
  - iDevice中已安装sshd

编译步骤:

  - 下载源码至本地
<pre><code>git clone git://github.com/crazytonyli/ChineseCalendar.git</code></pre>
  - 编辑Widget/config.mk文件。该文件中有两个属性：
    - THEOS: theos的安装路径
    - THEOS\_DEVICE\_IP: iDevice的IP地址
  - 运行编译打包安装命令：
<pre><code>make package install</code></pre>

## Lincese
本项目使用GPL v3.0协议发布

## Have fun! Go fork it!

