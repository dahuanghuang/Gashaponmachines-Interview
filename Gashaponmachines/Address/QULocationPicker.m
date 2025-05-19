#import "QULocationPicker.h"
#import "UIButton+QU.h"
#import "Macro.h"

@interface QULocationPicker()<UIPickerViewDelegate, UIPickerViewDataSource>

/// 全部城市
@property (nonatomic, strong) NSMutableArray *provinces;

@property (nonatomic, strong) NSMutableArray *cities;

@property (nonatomic, strong) NSMutableArray *areas;

@property (nonatomic, strong) NSArray *allProvincesCode;

@property (nonatomic, strong) NSArray *allCitiesCode;

@property (nonatomic, strong) NSArray *allAreasCode;

@property (nonatomic, strong) UIPickerView *locationPicker;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *doneButton;


/// 储存的 Selected 城市

@property (nonatomic, strong) NSString *selectedProvince;

@property (nonatomic, strong) NSString *selectedCity;

@property (nonatomic, strong) NSString *selectedArea;

/// 储存的 Selected Code

@property (nonatomic, strong) NSString *selectedProvinceCode;

@property (nonatomic, strong) NSString *selectedCityCode;

@property (nonatomic, strong) NSString *selectedAreaCode;

/// 储存的Code数组

@property (nonatomic, strong) NSMutableArray *provinceCodeArray;

@property (nonatomic, strong) NSMutableArray *cityCodeArray;

@property (nonatomic, strong) NSMutableArray *areaCodeArray;

@property (nonatomic, strong) NSDictionary  *json;

@property (nonatomic, strong) NSMutableDictionary *result;

@end

@implementation QULocationPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cityCodeArray = [NSMutableArray array];
        _provinceCodeArray = [NSMutableArray array];
        _areaCodeArray = [NSMutableArray array];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pca" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        self.json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        _cities = [NSMutableArray array];
        _areas = [NSMutableArray array];
        _provinces = [NSMutableArray arrayWithArray:@[@"北京市",
                                                      @"天津市",
                                                      @"河北省",
                                                      @"山西省",
                                                      @"内蒙古自治区",
                                                      @"辽宁省",
                                                      @"吉林省",
                                                      @"黑龙江省",
                                                      @"上海市",
                                                      @"江苏省",
                                                      @"浙江省",
                                                      @"安徽省",
                                                      @"福建省",
                                                      @"江西省",
                                                      @"山东省",
                                                      @"河南省",
                                                      @"湖北省",
                                                      @"湖南省",
                                                      @"广东省",
                                                      @"广西壮族自治区",
                                                      @"海南省",
                                                      @"重庆市",
                                                      @"四川省",
                                                      @"贵州省",
                                                      @"云南省",
                                                      @"西藏自治区",
                                                      @"陕西省",
                                                      @"甘肃省",
                                                      @"青海省",
                                                      @"宁夏回族自治区",
                                                      @"新疆维吾尔自治区"]];
        
        NSMutableArray *allProvinces = [NSMutableArray array];
        [[self.json valueForKey:@"province"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //[allProvinces addObject:[[obj allKeys] objectAtIndex:0]];
            
            for (NSString *key in [obj allKeys]) {
                if ([obj[key] isEqualToString:_provinces[idx]]){
                    //NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:obj[key] forKey:key];
                    [allProvinces addObject:key];
                }
            }
        }];
        
        self.provinceCodeArray = allProvinces;
      
        
        // 拿到所有的市
        NSDictionary *district = [self.json valueForKey:@"district"];
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        for (NSString *provinceCode in allProvinces) {
            NSArray *citiesArray = [[self.json valueForKey:@"city"] valueForKey:provinceCode];
            NSMutableArray *allCitys = [NSMutableArray array];
            for (NSDictionary *dic in citiesArray) {
                NSArray *cities = [dic allKeys];
                
                NSMutableDictionary *subResult = [NSMutableDictionary dictionary];
                for (NSString *city in cities) {
                    
                    NSMutableArray *districts = [NSMutableArray array];
                    
                    for (NSDictionary *dic in [district valueForKey:city]) {
                        [districts addObject:[[dic allKeys] objectAtIndex:0]];
                    }
                    
                    [subResult setObject:districts forKey:city];
                }
                
                [allCitys addObject:subResult];
            }
            
            [result setObject:allCitys forKey:provinceCode];
        }
        
        self.result = result;
      
        [self initUI];
        
        self.preSelectedProvinceCode = self.provinceCodeArray.firstObject;
        self.preSelectedCityCode = self.cityCodeArray.firstObject;
        self.preSelectedDistrictCode = self.areaCodeArray.firstObject;
    }
    return self;
}

- (void)initUI
{
    CGFloat pickerViewHeight = 200.0f;
    UIPickerView *heightPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    heightPicker.delegate = self;
    heightPicker.dataSource = self;
    heightPicker.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:heightPicker];
    self.locationPicker = heightPicker;
    
    self.locationPicker.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.locationPicker attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self addConstraint:width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.locationPicker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:pickerViewHeight];
    [self addConstraint:height];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.locationPicker attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:bottom];
    
//    [self.locationPicker mas_makeConstraints:^(MASConstraintMaker *make){
//        make.width.equalTo(self);
//        make.height.equalTo([NSNumber numberWithFloat:pickerViewHeight]);
//        make.bottom.equalTo(self);
//    }];
//
    UIView *toolBar = [UIView new];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:toolBar];
    
    NSLayoutConstraint *toolBar_width = [NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self addConstraint:toolBar_width];
    
    NSLayoutConstraint *toolbar_height = [NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:48];
    [self addConstraint:toolbar_height];
    
    NSLayoutConstraint *toolbar_top = [NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:toolbar_top];
    
    NSLayoutConstraint *toolbar_left = [NSLayoutConstraint constraintWithItem:toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self addConstraint:toolbar_left];
    
//    [toolBar mas_makeConstraints:^(MASConstraintMaker *make){
//        make.width.equalTo(self);
//        make.height.equalTo(@(48));
//        make.top.equalTo(self);
//        make.left.equalTo(self);
//    }];
    
    // toolsbar items
    UIButton *cancelButton = [UIButton simpleTextButton:@"取消"];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton = cancelButton;
    
    UIButton *doneButton = [UIButton simpleTextButton:@"确定"];
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [doneButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButton = doneButton;
    
    UILabel *blankLabel = [UILabel new];
    blankLabel.translatesAutoresizingMaskIntoConstraints = NO;
    blankLabel.text = @"请选择您所在区域";
    blankLabel.font = [UIFont systemFontOfSize:15];
    blankLabel.backgroundColor = [UIColor clearColor];
    blankLabel.textAlignment = NSTextAlignmentCenter;
    blankLabel.textColor = UIColorFromRGB(0x3e3e3e);
    [blankLabel sizeToFit];
    
    [toolBar addSubview:cancelButton];
    [toolBar addSubview:blankLabel];
    [toolBar addSubview:doneButton];
    
    NSLayoutConstraint *blankLabel_centerX = [NSLayoutConstraint constraintWithItem:blankLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [toolBar addConstraint:blankLabel_centerX];
    
    
    NSLayoutConstraint *blankLabel_centerY = [NSLayoutConstraint constraintWithItem:blankLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [toolBar addConstraint:blankLabel_centerY];
    
    
//
//    [blankLabel mas_makeConstraints:^(MASConstraintMaker *make){
//        make.center.equalTo(toolBar);
//    }];
    
    NSLayoutConstraint *cancelButton_centerY = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [toolBar addConstraint:cancelButton_centerY];
    
    NSLayoutConstraint *cancelButton_left = [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
    [toolBar addConstraint:cancelButton_left];
    
//    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make){
//        make.centerY.equalTo(toolBar);
//        make.left.equalTo(@10);
//    }];
    
    NSLayoutConstraint *doneButton_centerY = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [toolBar addConstraint:doneButton_centerY];
    
    NSLayoutConstraint *doneButton_right = [NSLayoutConstraint constraintWithItem:doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:toolBar attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
    [toolBar addConstraint:doneButton_right];
    
//    [doneButton mas_makeConstraints:^(MASConstraintMaker *make){
//        make.centerY.equalTo(toolBar);
//        make.right.equalTo(@-10);
//    }];
    

}

#pragma mark - Actions
- (void)buttonAction:(UIButton *) button
{
    if (self.cancelButton == button && self.selectorHandler) {
        self.selectorHandler(YES, nil, nil, nil, nil, nil, nil);
    } else if (self.doneButton == button && self.selectorHandler) {
        self.selectorHandler(NO, self.selectedProvince, self.selectedCity, self.selectedArea, self.selectedProvinceCode, self.selectedCityCode, self.selectedAreaCode);
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.provinces count];
        case 1:
            return [self.cities count];
        case 2:
            return [self.areas count];
        default:
            return 0;
        
    }
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    switch (component) {
//        case 0:
//            return [self.provinces objectAtIndex:row];
//        case 1:
//            return [self.cities objectAtIndex:row];
//        case 2:
//            if ([self.areas count] > 0) {
//                return [self.areas objectAtIndex:row];
//            }
//        default:
//            return @"";
//    }
//}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:{
            NSString* province = [self.provinces objectAtIndex:row];
            return [[NSAttributedString alloc] initWithString:province attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        }
        case 1:{
            NSString* city = [self.cities objectAtIndex:row];
            return [[NSAttributedString alloc] initWithString:city attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        }
        case 2:{
            if ([self.areas count] > 0) {
                NSString* area = [self.areas objectAtIndex:row];
                return [[NSAttributedString alloc] initWithString:area attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            }
        }
        default:
            return [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
}


#pragma mark - Setter

/// 找 Index
- (void)setPreSelectedCityCode:(NSString *)preSelectedCityCode
{
    _preSelectedCityCode = preSelectedCityCode;
    self.selectedCityCode = preSelectedCityCode;
}

- (void)setPreSelectedDistrictCode:(NSString *)preSelectedDistrictCode
{
    _preSelectedDistrictCode = preSelectedDistrictCode;
    self.selectedAreaCode = preSelectedDistrictCode;
}

- (void)setPreSelectedProvinceCode:(NSString *)preSelectedProvinceCode
{
    _preSelectedProvinceCode = preSelectedProvinceCode;
    self.selectedProvinceCode = preSelectedProvinceCode;
}

///
- (void)setSelectedProvinceCode:(NSString *)selectedProvinceCode
{
    [self.cities removeAllObjects];
    [self.cityCodeArray removeAllObjects];
    
    _selectedProvinceCode = selectedProvinceCode;
    if (!_selectedProvinceCode) {
        _selectedProvinceCode = [self.provinceCodeArray objectAtIndex:0];
      
    }
  

  
    NSArray *array = [self.result valueForKey:_selectedProvinceCode];
    
    NSUInteger index = [self.provinceCodeArray indexOfObject:_selectedProvinceCode];
    if (index != NSNotFound) {
        [self.locationPicker selectRow:index inComponent:0 animated:NO];
        if (selectedProvinceCode == _preSelectedProvinceCode) {
            _selectedProvince = [self.provinces objectAtIndex:index];
        }
    }
  
  
  
  
    for (NSDictionary *dic in array) {
        [self.cityCodeArray addObjectsFromArray:[dic allKeys]];
    }

    
    NSArray *cities = [[self.json valueForKey:@"city"]  valueForKey:_selectedProvinceCode];
    
    for (NSDictionary *dic in cities) {
        [self.cities addObjectsFromArray:[dic allValues]];
    }
    
    //NSLog(@"selectedProvinceCode: %@ Cities : %@",self.selectedProvinceCode, weakSelf.cities);
    //NSLog(@"CityCode Array : %@",weakSelf.cityCodeArray);
}



- (void)setSelectedCityCode:(NSString *)selectedCityCode
{
    [self.areas removeAllObjects];
    
    _selectedCityCode = selectedCityCode;
    if (!_selectedCityCode) {
        _selectedCityCode = [self.cityCodeArray objectAtIndex:0];
      
    }
    NSArray *array = [self.result valueForKey:_selectedProvinceCode];
    
    for (NSUInteger i = 0; i <= array.count - 1; i ++) {
        if ([[[[array objectAtIndex:i] allKeys] objectAtIndex:0] isEqualToString:_selectedCityCode]) {
            self.areaCodeArray = [[array objectAtIndex:i] valueForKey:_selectedCityCode];
            NSLog(@"area code array : %@",self.areaCodeArray);
        }
    }
    
    
    
    
    NSArray *districts = [[self.json valueForKey:@"district"]  valueForKey:_selectedCityCode];
    for (NSDictionary *dic in districts) {
        [self.areas addObjectsFromArray:[dic allValues]];
    }
    
    
    //NSLog(@"self.area : %@",self.areas);
    
    NSUInteger index = [self.cityCodeArray indexOfObject:_selectedCityCode];
    [self.locationPicker reloadComponent:1];
    if (index != NSNotFound) {
        [self.locationPicker selectRow:index inComponent:1 animated:NO];
        if (selectedCityCode == _preSelectedCityCode) {
            _selectedCity = [self.cities objectAtIndex:index];
        }
    }
    
    
}

- (void)setSelectedAreaCode:(NSString *)selectedAreaCode
{
    _selectedAreaCode = selectedAreaCode;
    if (!_selectedAreaCode) {
        _selectedAreaCode = [self.areaCodeArray objectAtIndex:0];
      
    }
    NSUInteger index = [self.areaCodeArray indexOfObject:_selectedAreaCode];
    [self.locationPicker reloadComponent:2];
    if (index != NSNotFound) {
        [self.locationPicker selectRow:index inComponent:2 animated:NO];
        if (selectedAreaCode == _preSelectedDistrictCode) {
            _selectedArea = [self.areas objectAtIndex:index];
        }
    }
    
}



#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            if (self.provinceCodeArray.count > 0) {
                self.selectedProvinceCode = [self.provinceCodeArray objectAtIndex:row];
                self.selectedProvince = [self.provinces objectAtIndex:row];
            }
            
            [self.locationPicker reloadComponent:1];
            [self.locationPicker selectRow:0 inComponent:1 animated:YES];
            
            if (self.cityCodeArray.count > 0) {
                self.selectedCityCode = [self.cityCodeArray objectAtIndex:0];
                self.selectedCity = [self.cities objectAtIndex:0];
            }
            
            [self.locationPicker reloadComponent:2];
            [self.locationPicker selectRow:0 inComponent:2 animated:YES];
            
            
            if (self.areaCodeArray.count > 0) {
                self.selectedArea = [self.areas objectAtIndex:0];
                self.selectedAreaCode = [self.areaCodeArray objectAtIndex:0];
            }
            
            break;
        case 1:
            
            if (self.cityCodeArray.count > 0 && self.cities.count > 0) {
                self.selectedCityCode = [self.cityCodeArray objectAtIndex:row];
                self.selectedCity = [self.cities objectAtIndex:row];
            }
            
            [self.locationPicker reloadComponent:2];
            [self.locationPicker selectRow:0 inComponent:2 animated:YES];
            
            
            if (self.areas.count > 0 && self.areaCodeArray.count > 0) {
                self.selectedArea = [self.areas objectAtIndex:0];
                self.selectedAreaCode = [self.areaCodeArray objectAtIndex:0];
            }
            break;
        case 2:
            
            if (self.areas.count > 0 && self.areaCodeArray.count > 0) {
                
                /// 用 Code
                self.selectedArea = [self.areas objectAtIndex:row];
                self.selectedAreaCode = [self.areaCodeArray objectAtIndex:row];
            }
            break;
    }
}

@end
