#import <Foundation/Foundation.h>

@interface QUEncryption : NSObject

+ (NSString *)encryptWithText:(NSString *)sText;
+ (NSString *)decryptWithText:(NSString *)sText;

@end
