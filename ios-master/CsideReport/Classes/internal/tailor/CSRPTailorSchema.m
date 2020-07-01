//
//  CSRPTailorSchema.m
//
#import "CSRPTailorSchema.h"

struct CSRPTailorSchemaLabels const CSRPTailorSchemaLabels = {
#define CSRPTailorSchema_L(name)    \
    . name = @ #name,

    //  CSRPTailorSchema_L( startTime )
        CSRPTailorSchema_L( startTimeInSeconds )
    //  CSRPTailorSchema_L( duration )
        CSRPTailorSchema_L( durationInSeconds )

        CSRPTailorSchema_L( avails )
    //  CSRPTailorSchema_L( availId )

        CSRPTailorSchema_L( ads )
        CSRPTailorSchema_L( adId )
        CSRPTailorSchema_L( vastAdId )

        CSRPTailorSchema_L( trackingEvents )
    //  CSRPTailorSchema_L( eventId )
        CSRPTailorSchema_L( eventType )
        CSRPTailorSchema_L( beaconUrls )

#undef  CSRPTailorSchema_L
};
