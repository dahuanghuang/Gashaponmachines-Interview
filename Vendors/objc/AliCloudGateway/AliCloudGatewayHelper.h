#import <Foundation/Foundation.h>

@interface AliCloudGatewayHelper : NSObject

- (instancetype _Nonnull) init;

- (NSURLRequest * _Nonnull) buildHeader:protocol
                         method:(NSString* _Nonnull) method
                           host:(NSString* _Nonnull) host
                           path:(NSString* _Nonnull) path
                     pathParams:(nullable NSDictionary *) pathParams
                    queryParams:(nullable NSDictionary *) queryParams
                     formParams:(nullable NSDictionary *) formParams
                           body:(nullable NSData *) body
             requestContentType:(nullable NSString *) requestContentType
              acceptContentType:(nullable NSString *) acceptContentType
                   headerParams:(nullable NSMutableDictionary*) headerParams;
@end
