//
//  TRSProductBaseView+Private.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

/*
 This is the class extension (i.e. private methods) for TRSProductBaseView.
 It's in a separate header file so any public subclasses can import it easily in their .m file and can
 access the hidden properties storing the data (obviously you shouldn't import it in the header and expose it).
 */

@interface TRSProductBaseView ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *totalReviewCount;
@property (nonatomic, strong) NSNumber *overallMark;
@property (nonatomic, copy) NSString *overallMarkDescription;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
