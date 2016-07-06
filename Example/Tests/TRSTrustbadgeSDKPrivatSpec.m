//
//  TRSTrustbadgeSDKPrivatSpec.m
//  Trustbadge
//
//  Taken up by Gero Herkenrath on 22/03/16.
//

#import "TRSTrustbadgeSDKPrivate.h"
#import <Specta/Specta.h>


SpecBegin(TRSTrustbadgeSDKPrivate)

describe(@"TRSTrustbadgeSDKPrivate", ^{

    describe(@"TRSTrustbadgeBundle", ^{

        it(@"returns a bundle object", ^{
            NSBundle *bundle = TRSTrustbadgeBundle();
            expect(bundle).to.beKindOf([NSBundle class]);
        });

        it(@"returns the same bundle object", ^{
            NSBundle *aBundle = TRSTrustbadgeBundle();
            NSBundle *otherBundle = TRSTrustbadgeBundle();
            expect(aBundle).to.equal(otherBundle);
        });

    });

});

SpecEnd
