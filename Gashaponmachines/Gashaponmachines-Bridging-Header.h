#ifndef Gashaponmachines_Bridging_Header_h
#define Gashaponmachines_Bridging_Header_h

// iPhone 4S
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
// iPhone 5 && iPhone 5S && iPhone 5C
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
// iPhone 7 && iPhone 6
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
// iPhone 7P && iPhone 6P
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
// iPhone X
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)]?CGSizeEqualToSize(CGSizeMake(1125, 2436),[[UIScreen mainScreen]currentMode].size):NO)

// 
#import "WKWebViewJavascriptBridge.h"

//ShareSDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <MOBFoundation/MobSDK+Privacy.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

// 阿里云Log
#import "AliyunLogProducer.h"

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
//支付宝支付
#import <AlipaySDK/AlipaySDK.h>
// AliCloud
#import "AliCloudGatewayHelper.h"
#import "HttpConstant.h"
//
#import <CommonCrypto/CommonCrypto.h>
#import "HMSegmentedControl.h"
#import "QULocationPicker.h"
#import "KLCPopup.h"

#import "QUEncryption.h"
#import <Bugtags/Bugtags.h>

#import "CACommonMessage.h"
#import "CACommonRequest.h"
#import "CAUtils.h"
#import "CAClient.h"
#import "CACommonResponse.h"

#endif /* Gashaponmachines_Bridging_Header_h */

