//
//  OATypes.h
//  openalpr-swift
//
//  Created by Yasir M Türk on 14/11/2017.
//  Copyright © 2017 Yasir M Türk. All rights reserved.
//

#import <Foundation/Foundation.h>

// Objective-C wrapper for alpr::AlprChar

@interface OACharacter: NSObject

@property float confidence;

@property (readonly) NSArray    *corners;
@property (readonly) NSString   *character;

@end

// Objective-C wrapper for alpr::AlprPlate

@interface OAPlate: NSObject

@property (nonatomic) float confidence;
@property (nonatomic) NSArray<OACharacter *> *characters;
@property (nonatomic) bool matchesTemplate;

@property (readonly) NSString *number;

- (instancetype)initWithAlprPlate:(void *)plate;

@end

// Objective-C wrapper for alpr::AlprPlateResult

@interface OAPlateResult: NSObject

@property int       requestedTopN;
@property NSString  *country;
@property OAPlate   *bestPlate;

@property NSArray<OAPlate *>    *topNPlates;

@property float     processingTime;

@property (readonly) NSArray    *platePoints;

@property int       plateIndex;
@property int       regionConfidence;
@property NSString  *region;

- (instancetype)initWithAlprPlateResult:(void *)plateResult;

@end

// Objective-C wrapper for alpr::AlprResults

@interface OAResults: NSObject

@property int64_t   epochTime;
@property int64_t   frameNumber;
@property int       imgWidth;
@property int       imgHeight;
@property float     totalProcessingTime;

@property NSArray<OAPlateResult *> *plates;

@property NSArray *regionsOfInterest;

- (instancetype)initWithAlprResults:(void *)results;

@end
