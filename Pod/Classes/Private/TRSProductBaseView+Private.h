//
//  TRSProductBaseView+Private.h
//  Pods
//
//  Created by Gero Herkenrath on 05/07/16.
//
//

/*
 This is a class extension (i.e. private methods) for TRSProductBaseView and potentially its subclasses.
 It redefines the readonly properties as readwrite, so the data loading mechanism can properly alter them in a
 convenient way. It's in a separate header file so any public subclasses can import it easily in their .m file
 in case they also need to alter the values. At the moment this is not the case, though, as the only direct class
 writing them is TRSProductBaseView.
 Obviously you shouldn't import it in the public header and expose these properties.
 
 See also TRSPrivateBasicDataView+Private.h to learn about the mechanics of data loading.
 */

@interface TRSProductBaseView ()

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *uuid;
@property (nonatomic, readwrite, strong) NSNumber *totalReviewCount;
@property (nonatomic, readwrite, strong) NSNumber *overallMark;
@property (nonatomic, readwrite, copy) NSString *overallMarkDescription;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
