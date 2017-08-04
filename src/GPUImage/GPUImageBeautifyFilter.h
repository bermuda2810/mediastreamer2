//
//  GPUImageBeautifyFilter.h
//  SimpleVideoFilter
//
//  Created by Bui Quoc Viet on 8/3/17.
//  Copyright © 2017 Cell Phone. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImage.h"

@class GPUImageBilateralFilter;
@class GPUImageCannyEdgeDetectionFilter;
@class GPUImageCombinationFilter;
@class GPUImageHSBFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end
