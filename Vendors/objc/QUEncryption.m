#import "QUEncryption.h"
#import <CommonCrypto/CommonCrypto.h>

//加密算法：des-ede3
//加密解密的key,与后台一致

//初始化向量，与后台一致


@implementation QUEncryption

#pragma mark - Public

+ (NSString *)encryptWithText:(NSString *)sText
{
	//kCCEncrypt 加密
//    NSLog(@"encrypt -----> %@", [sText description]);
    NSString *res = [self TripleDES:sText encryptOrDecrypt:kCCEncrypt];
    return res;
}

+ (NSString *)decryptWithText:(NSString *)sText
{
	//kCCDecrypt 解密
//    NSLog(@"decrypt -----> %@", [sText description]);
    NSString *res = [self TripleDES:sText encryptOrDecrypt:kCCDecrypt];
    return res;
}

#pragma mark - Private

+ (NSMutableData *) datawithhexstring :(NSString *)input{

	NSString *command = input;
	
	command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	int i;
	for (i=0; i < [command length]/2; i++) {
		byte_chars[0] = [command characterAtIndex:i*2];
		byte_chars[1] = [command characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1];
	}
	return commandToSend;
}

+ (NSString *)hexadecimalString:(NSData *)data {
	/* Returns hexadecimal string of NSData. Empty string if data is empty.   */
	
	const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
	
	if (!dataBuffer)
		return [NSString string];
	
	NSUInteger          dataLength  = [data length];
	NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
	
	for (int i = 0; i < dataLength; ++i)
		[hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
	
	return [NSString stringWithString:hexString];
}

#pragma mark - ENC & DEC

+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt
{
	
	const void *vplainText;
	size_t plainTextBufferSize;
	
    // 解密
	if (encryptOrDecrypt == kCCDecrypt) {
		NSData *EncryptData = [self datawithhexstring:plainText];
		plainTextBufferSize = [EncryptData length];
		vplainText = [EncryptData bytes];
	} else {
		NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
		plainTextBufferSize = [data length];
		vplainText = (const void *)[data bytes];
	}
	
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	
	bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	// memset((void *) iv, 0x0, (size_t) sizeof(iv));
	
	const void *vkey = (const void *) [[NSString stringWithFormat:@"PHeomE91GRhIGCa8fXoV0Lbn"] UTF8String];
	// NSString *initVec = @"init Vec";
	//const void *vinitVec = (const void *) [initVec UTF8String];
	//  Byte iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
	ccStatus = CCCrypt(encryptOrDecrypt,
					   kCCAlgorithm3DES,
					   kCCOptionPKCS7Padding | kCCOptionECBMode,
					   vkey,
					   kCCKeySize3DES,
					   NULL,
					   vplainText,
					   plainTextBufferSize,
					   (void *)bufferPtr,
					   bufferPtrSize,
					   &movedBytes);
	
	NSString *result;
	
	if (encryptOrDecrypt == kCCDecrypt) {
		NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
		result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	} else {
		NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
		result = [self hexadecimalString: myData];
	}
    free(bufferPtr);
	
	return result;
}


@end
