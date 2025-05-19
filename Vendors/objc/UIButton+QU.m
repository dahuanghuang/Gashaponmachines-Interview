#import "UIButton+QU.h"
#import "Macro.h"

@implementation UIButton (QU)

+ (UIButton *)simpleTextButton:(NSString *) text{
    
    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [textButton setTitle:text forState:UIControlStateNormal];
    [textButton setTitleColor:UIColorFromRGB(0x3a3a3a) forState:UIControlStateNormal];
    [textButton setTitleColor:UIColorFromRGB(0x4e331d) forState:UIControlStateHighlighted];
    textButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [textButton sizeToFit];
    
    return textButton;
    
}

@end
