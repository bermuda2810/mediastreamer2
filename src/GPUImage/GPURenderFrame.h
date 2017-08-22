//
//  GPURenderFrame.h
//  GPUImage
//
//  Created by Bui Quoc Viet on 8/14/17.
//  Copyright © 2017 Brad Larson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "GPUImageContext.h"
#import "GPUImageOutput.h"
#import "GPUImageColorConversion.h"
#import "GPUImage.h"

//Optionally override the YUV to RGB matrices
void setColorConversion601( GLfloat conversionMatrix[9] );
void setColorConversion601FullRange( GLfloat conversionMatrix[9] );
void setColorConversion709( GLfloat conversionMatrix[9] );

@interface GPURenderFrame : GPUImageOutput{
    NSUInteger numberOfFramesCaptured;
    CGFloat totalFrameTimeDuringCapture;
    
    BOOL capturePaused;
    GPUImageRotationMode outputRotation, internalRotation;
    dispatch_semaphore_t frameRenderingSemaphore;
    
    BOOL captureAsYUV;
    GLuint luminanceTexture, chrominanceTexture;
}

@property (readwrite) int32_t frameRate;

- (instancetype)init;
- (void)processVideoSampleBuffer:(CVImageBufferRef)sampleBuffer alignment:(int)alignment;

@end
