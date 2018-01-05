//
//  OATypes.m
//  openalpr-swift
//
//  Created by Yasir M Türk on 14/11/2017.
//  Copyright © 2017 Yasir M Türk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OATypes.h"

#include <openalpr/alpr.h>

// Global utility methods

// Objective-C wrapper for alpr::AlprChar

@interface OACharacter() {
}
@end

@implementation OACharacter

- (instancetype)initWithAlprChar:(void *)character {
    if (self = [super init]) {
        alpr::AlprChar *c = (alpr::AlprChar *)character;
        _character = [NSString stringWithUTF8String:c->character.c_str()];
        _confidence = c->confidence;
        _corners = [OACharacter parseCorners:c->corners];
    }
    return self;
}

+ (NSArray *)parseCorners:(alpr::AlprCoordinate [4])corners {
    return @[
             [NSValue valueWithCGPoint:CGPointMake(corners[0].x, corners[0].y)],
             [NSValue valueWithCGPoint:CGPointMake(corners[1].x, corners[1].y)],
             [NSValue valueWithCGPoint:CGPointMake(corners[2].x, corners[2].y)],
             [NSValue valueWithCGPoint:CGPointMake(corners[3].x, corners[3].y)],
             ];
}

@end

// Objective-C wrapper for alpr::AlprPlate

@interface OAPlate() {
    alpr::AlprPlate *_plate;
}
@end

@implementation OAPlate

- (instancetype)initWithAlprPlate:(void *)plate {
    if (self = [super init]) {
        _plate = (alpr::AlprPlate *)plate;
        _number = [NSString stringWithUTF8String:_plate->characters.c_str()];
        _matchesTemplate = _plate->matches_template;
        _confidence = _plate->overall_confidence;
        NSMutableArray *ca = [[NSMutableArray alloc] initWithCapacity:_plate->character_details.size()];
        for (int i = 0; i < _plate->character_details.size(); i++) {
            [ca addObject:[[OACharacter alloc] initWithAlprChar:&_plate->character_details[i]]];
        }
        _characters = [NSArray arrayWithArray:ca];
        
    }
    return self;
}

@end

// Objective-C wrapper for alpr::AlprPlateResult

@implementation OAPlateResult

- (instancetype)initWithAlprPlateResult:(void *)plateResult {
    if (self = [super init]) {
        alpr::AlprPlateResult *pr = (alpr::AlprPlateResult *)plateResult;
        _requestedTopN = pr->requested_topn;
        _country = [NSString stringWithUTF8String:pr->country.c_str()];
        _bestPlate = [[OAPlate alloc] initWithAlprPlate:&pr->bestPlate];
        NSMutableArray *plates = [[NSMutableArray alloc] initWithCapacity:pr->topNPlates.size()];
        for (int i = 0; i < pr->topNPlates.size(); i++) {
            [plates addObject:[[OAPlate alloc] initWithAlprPlate:&pr->topNPlates[i]]];
        }
        _topNPlates = [NSArray arrayWithArray:plates];
        _processingTime = pr->processing_time_ms;
        _platePoints = [OACharacter parseCorners:pr->plate_points];
        _plateIndex = pr->plate_index;
        _regionConfidence = pr->regionConfidence;
        _region = [NSString stringWithUTF8String:pr->region.c_str()];
    }
    return self;
}

@end

// Objective-C wrapper for alpr::AlprResults

@implementation OAResults

- (instancetype)initWithAlprResults:(void *)results {
    if (self = [super init]) {
        alpr::AlprResults *r = (alpr::AlprResults *)results;
        _epochTime = r->epoch_time;
        _frameNumber = r->frame_number;
        _imgWidth = r->img_width;
        _imgHeight = r->img_height;
        _totalProcessingTime = r->total_processing_time_ms;
        NSMutableArray *pResults = [[NSMutableArray alloc] initWithCapacity:r->plates.size()];
        for (int i = 0; i < r->plates.size(); i++) {
            [pResults addObject:[[OAPlateResult alloc] initWithAlprPlateResult:&r->plates[i]]];
        }
        _plates = [NSArray arrayWithArray:pResults];
        _regionsOfInterest = [OAResults parseRegionOfInterests:r->regionsOfInterest];
    }
    return self;
}

+ (NSArray *)parseRegionOfInterests:(std::vector<alpr::AlprRegionOfInterest>)regions {
    NSMutableArray *rois = [[NSMutableArray alloc] initWithCapacity:regions.size()];
    for (int i = 0; i < regions.size(); i++) {
        alpr::AlprRegionOfInterest roi = regions[i];
        [rois addObject:[NSValue valueWithCGRect:CGRectMake(roi.x, roi.y, roi.width, roi.height)]];
    }
    return [NSArray arrayWithArray:rois];
}

@end


