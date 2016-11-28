//
//  TRSConsumer+Private.h
//  Pods
//
//  Created by Gero Herkenrath on 12/04/16.
//
//

/**
 This privateheader just keeps the class extension hidden from the public headers, yet it allows for the
 TRSOrder class to also include the readwrite properties. 
 */

@interface TRSConsumer ()

@property (nonatomic, readwrite, assign) TRSMembershipStatus membershipStatus;

@end
