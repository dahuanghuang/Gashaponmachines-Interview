#import <UIKit/UIKit.h>

typedef void(^QULocationSelectionHandler)(BOOL isCancel, NSString *provinceName, NSString *cityName, NSString *areaName, NSString *provinceCode, NSString *cityCode, NSString *areaCode);

@interface QULocationPicker : UIView

@property (nonatomic, strong) QULocationSelectionHandler selectorHandler;

/// 修改地址： （从服务器返回来的） 通过这三个属性查找
@property (nonatomic, strong) NSString *preSelectedCityCode;

@property (nonatomic, strong) NSString *preSelectedProvinceCode;

@property (nonatomic, strong) NSString *preSelectedDistrictCode;

@end
