source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/aliyun/aliyun-specs.git'
use_frameworks!
platform :ios, '13.0'
inhibit_all_warnings!

dynamic_frameworks = ['JGProgressHUD', 'AlicloudPush', 'WechatOpenSDK', 'MJRefresh']

target 'GashaponmachinesTests' do
  pod 'Quick'
  pod 'Nimble'
end

target 'Gashaponmachines' do
  # JSON
  pod 'Argo'
  pod 'Curry'
  pod 'Runes'
  pod 'Result', '~> 5.0'
  
  # 网络图片加载
  pod 'Kingfisher', '~> 7.9.1'

  # 布局
  pod 'SnapKit', '4.0.1'

  # 网络请求库
  pod 'Alamofire'

  # Rx 组件
  pod 'RxSwift'
  pod 'RxOptional'
  pod 'RxKeyboard'
  pod 'RxDataSources'
  pod 'RxSwiftExt'
  pod 'RxGesture'

  # Socket IO
  pod 'Socket.IO-Client-Swift', '~> 13.1.0'

  # 网络封装层
  pod 'Moya/RxSwift'

  # HUD
  pod 'JGProgressHUD', '2.0'
  pod 'Toast-Swift', '4.0.0'

  # 下拉菜单
  pod 'DropDown', '2.3.9'

  # PageViewController
  pod 'Tabman', '3.0.2'
  pod 'FSPagerView', '0.8.1'

  # 阿里云推送
  pod 'AlicloudPush', '1.9.9'

  # 微信 SDK
#  pod 'WechatOpenSDK', '1.8.1'

  # TabBar
  # pod 'ESTabBarController-swift', :git => 'https://github.com/harelw/ESTabBarController.git', :branch => 'iphonex-fix'
  pod 'ESTabBarController-swift', :git => 'https://github.com/wongzigii/ESTabBarController.git', :branch => 'master'

  # 下拉刷新
  pod 'MJRefresh', '3.1.15.3'

  #BugTags
  pod 'Bugtags', '3.0.1'

  # 强类型的 Notification 管理工具
  pod 'SwiftNotificationCenter', '1.0.3'

  # 动画库
  pod 'lottie-ios', '~> 3.0.0'

  # tableView 为空页
  pod 'TBEmptyDataSet', '2.7'

  # Logger
  pod 'CocoaLumberjack/Swift', '3.4.2'

  # 与 WebView 进行交互的 JSBridge
#  pod 'WebViewJavascriptBridge'

  # 七牛
  pod 'Qiniu', '7.2.5'

  # 解压 Zip 工具
  pod 'ZIPFoundation', '0.9.6'

  # Date 小工具 相当于 js 的 Moment 库
  pod 'SwiftDate', '~> 7.0.0'

  # IM 聊天库
  pod 'MessageKit'

  # Image Viewer
  pod 'Agrume'

  # 渐变色 Progress Bar
  pod 'GradientProgressBar', '~> 1.0'

  # 状态机
  pod 'SwiftState', :git => 'https://github.com/ReactKit/SwiftState.git', :branch => 'swift/4.0'

  # 腾讯 Bugly
  pod 'Bugly', '2.5.0'

  # 内购
  pod 'SwiftyStoreKit'

end


# 将非dynamic_frameworks中的Pod设置为静态框架（static framework）
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if !dynamic_frameworks.include?(pod.name)
      puts "Overriding the static_framework? method for #{pod.name}"
      def pod.static_framework?;
        true
      end
    end
  end
end


# 设置Pods下每个Target的iOS DEPLOYMENT TARGET为iOS 13.0
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            xcconfig_path = config.base_configuration_reference.real_path
            xcconfig = File.read(xcconfig_path)
            xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
            File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
#            config.build_settings["DEVELOPMENT_TEAM"] = "YOUR TEAM ID"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
         end
    end
  end
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
