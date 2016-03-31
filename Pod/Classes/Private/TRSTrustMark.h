//
//  TRSTrustMark.h
//  Pods
//
//  Created by Gero Herkenrath on 08.03.16.
//
//

#import <Foundation/Foundation.h>

@interface TRSTrustMark : NSObject

@property (nonatomic, strong) NSString 	*status;
@property (nonatomic, strong) NSDate 	*validFrom;
@property (nonatomic, strong) NSDate 	*validTo;

- (instancetype)initWithDictionary:(NSDictionary *)trustMarkInfo NS_DESIGNATED_INITIALIZER;

@end
