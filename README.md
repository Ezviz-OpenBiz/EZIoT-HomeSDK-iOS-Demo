## SDK Demo
SDK Demo 演示了萤石 App SDK 的接入流程以及 SDK 开放的功能，因此通过参考 Demo 可以基本解决再接入过程中碰到的问题。Demo下载地址：[点击下载](https://github.com/Ezviz-OpenBiz/EZIoT-HomeSDK-iOS-Demo)

### Demo 模块介绍：

* 登录模块：包含注册，登录，忘记密码功能
* 家庭模块：包含添加家庭，删除家庭，修改家庭信息，邀请家庭成员和移除家庭成员等功能
* 房间模块：包含添加房间，删除房间，移动房间设备，修改房间信息
* 设备模块：包含从服务器中拉取设备列表，从本地数据库中拉取设备信息，对设备功能点进行操作相关逻辑
* 消息模块：包含消息列表展示，消息操作和消息免打扰开关逻辑
* 配网模块：包含接触式配网  

### 运行 Demo
* 打开 Demo 工程进入 EZIoTHomeSDKDemo.xcodeproj 所在目录，通过终端执行 pod install 命令安装依赖组件。执行成功后在当前目录会生成 EZIoTHomeSDKDemo.xcworkspace 文件。
* 通过 Xcode 打开 EZIoTHomeSDKDemo.xcworkspace 文件，进入工程；
* 在工程 Targets -> Signing & Capabilities -> Signing 中配置您的 Bundle Identifier 和 Provisioning Profile；
* 在项目文件 AppDelegate.m 的 setupAppSDK 方法中设置您的 AppId;
  
**Demo示例：**  

<img src="https://resource.eziot.com/group1/M00/00/81/CtwQE2GbMFiAeuoaAABfnCDPi5s050.PNG" width = "389px" height = "700px"  />