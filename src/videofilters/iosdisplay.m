/*
 iosdisplay.m
 Copyright (C) 2011 Belledonne Communications, Grenoble, France

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#if defined(HAVE_CONFIG_H)
#include "mediastreamer-config.h"
#endif
#include "mediastreamer2/msvideo.h"
#include "mediastreamer2/msticker.h"
#include "mediastreamer2/msv4l.h"
#include "mediastreamer2/mswebcam.h"
#include "mediastreamer2/mscommon.h"
#include "nowebcam.h"
#include "mediastreamer2/msfilter.h"
#include "scaler.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>

#include "opengles_display.h"
#import "GPUImage.h"

@interface IOSDisplay : GPUImageView {
    
@public
	struct opengles_display* display_helper;
    GPURenderFrame *renderFrame;

@private
	NSRecursiveLock* lock;
	EAGLContext* context;
	GLuint defaultFrameBuffer, colorRenderBuffer;
	id displayLink;
	BOOL animating;
	CGRect prevBounds;
    GPUImageBeautifyFilter *filter;
}

@property (nonatomic, retain) UIView* parentView;
@property (assign) int deviceRotation;
@property (assign) int displayRotation;

@end

@implementation IOSDisplay

@synthesize parentView;
@synthesize deviceRotation;
@synthesize displayRotation;

- (void)initIOSDisplay {
	self->deviceRotation = 0;
	self->lock = [[NSRecursiveLock alloc] init];
	self->display_helper = ogl_display_new();
	self->prevBounds = CGRectMake(0, 0, 0, 0);
	self->context = nil;
    
    renderFrame = [[GPURenderFrame alloc] init];
    filter = [[GPUImageBeautifyFilter alloc] init];
    [filter addTarget:self];
    [renderFrame addTarget:filter];
    
//    // Init view
//	[self setOpaque:YES];
//	[self setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//	// Init layer
//	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
//	[eaglLayer setOpaque:YES];
//	[eaglLayer setDrawableProperties: [NSDictionary dictionaryWithObjectsAndKeys:
//									   [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
//									   kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
//									   nil]];
}

- (id)init {
	self = [super init];
	if (self) {
		[self initIOSDisplay];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initIOSDisplay];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initIOSDisplay];
	}
	return self;
}

- (void)initOpenGL {
//	 Init OpenGL context
//	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//	if (!context || ![EAGLContext setCurrentContext:context]) {
//		ms_error("Opengl context failure");
//		return;
//	}
//
//	glGenFramebuffers(1, &defaultFrameBuffer);
//	glGenRenderbuffers(1, &colorRenderBuffer);
//	glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
//	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
//	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
//	ogl_display_init(display_helper, NULL, prevBounds.size.width, prevBounds.size.height);
//
//	// release GL context for this thread
//	[EAGLContext setCurrentContext:nil];
}

- (void)drawView {
	/* no opengl es call made when in background */
//	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
//		return;
//	if([lock tryLock]) {
//		if(context == nil) {
//			[self initOpenGL];
//		}
//		if (![EAGLContext setCurrentContext:context]) {
//			ms_error("Failed to bind GL context");
//			return;
//		}
//
//		if (!CGRectEqualToRect(prevBounds, [self bounds])) {
//			CAEAGLLayer* layer = (CAEAGLLayer*)self.layer;
//
//			if (prevBounds.size.width != 0 || prevBounds.size.height != 0) {
//				// release previously allocated storage
//				[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:nil];
//			}
//
//			prevBounds = [self bounds];
//
//			// allocate storage
//			if ([context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer]) {
//				ms_message("GL renderbuffer allocation size (layer %p frame size: %f x %f)", layer, layer.frame.size.width, layer.frame.size.height);
//				ogl_display_set_size(display_helper, prevBounds.size.width, prevBounds.size.height);
//				glClear(GL_COLOR_BUFFER_BIT);
//			} else {
//				ms_error("Error in renderbufferStorage (layer %p frame size: %f x %f)", layer, layer.frame.size.width, layer.frame.size.height);
//			}
//		}
//
//		if (!animating) {
//			glClear(GL_COLOR_BUFFER_BIT);
//		} else {
//			ogl_display_render(display_helper, deviceRotation);
//		}
//
//		[context presentRenderbuffer:GL_RENDERBUFFER];
//		[lock unlock];
//	}
}

- (void)setParentView:(UIView*)aparentView{
	if (parentView == aparentView) {
		return;
	}

	if(parentView != nil) {
		animating = FALSE;

		// stop schedule rendering
		[displayLink invalidate];
		displayLink = nil;

		[self drawView];

		// remove from parent
		[self removeFromSuperview];

		[parentView release];
		parentView = nil;
	}

	parentView = aparentView;

	if(parentView != nil) {
		[parentView retain];
		animating = TRUE;

		// add to new parent
		[self setFrame: [parentView bounds]];
		[parentView addSubview:self];

		// schedule rendering
//		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
//		[displayLink setFrameInterval:1];
//		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
}

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (void)dealloc {
//	[EAGLContext setCurrentContext:context];
//
//	ogl_display_uninit(display_helper, TRUE);
//	ogl_display_free(display_helper);
//	display_helper = NULL;
//
//	glDeleteFramebuffers(1, &defaultFrameBuffer);
//	glDeleteRenderbuffers(1, &colorRenderBuffer);
//
//	[EAGLContext setCurrentContext:0];
//
//	[context release];
	[lock release];

	self.parentView = nil;

	[super dealloc];
}

-(int) pixel_unpack_alignment:(uint8_t *)ptr datasize:(int)datasize {
    uintptr_t num_ptr = (uintptr_t) ptr;
    int alignment_ptr = !(num_ptr % 4) ? 4 : !(num_ptr % 2) ? 2 : 1;
    int alignment_data = !(datasize % 4) ? 4 : !(datasize % 2) ? 2 : 1;
    return (alignment_ptr <= alignment_data) ? alignment_ptr : alignment_data;
}

@end

static void iosdisplay_init(MSFilter *f) {
	NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
	f->data = [[IOSDisplay alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	[loopPool drain];
}

static void iosdisplay_process(MSFilter *f) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;

	mblk_t *m = ms_queue_peek_last(f->inputs[0]);
    
	if (thiz != nil && m != nil) {
        MSPicture picture;
        ms_yuv_buf_init_from_mblk(&picture, m);
        
        int size_cbcr = picture.w * picture.h * 0.5;
        int length_u_v = picture.w * picture.h * 0.25;
        
        uint8_t planecCbCr[size_cbcr];
        
        for (int i = 0,j=0;i<length_u_v;i++) {
            planecCbCr[j++] = picture.planes[1][i];
            planecCbCr[j++] = picture.planes[2][i];
        }
        
        NSDictionary *pixelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey,
                                         nil];
        
        CVImageBufferRef yBuffer;
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            picture.w,
                            picture.h,
                            kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                            (__bridge CFDictionaryRef _Nullable)(pixelAttributes),
                            &yBuffer);
        
        CVPixelBufferLockBaseAddress(yBuffer,0);
        uint8_t *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(yBuffer,0);
        memcpy(yDestPlane, picture.planes[0], picture.h*picture.w);
        uint8_t *cbcr = CVPixelBufferGetBaseAddressOfPlane(yBuffer,1);
        memcpy(cbcr, planecCbCr, size_cbcr);
        CVPixelBufferUnlockBaseAddress(yBuffer, 0);
        
        unsigned int aligned_yuv_w, aligned_yuv_h;
        int alignment = 0;
        
        if (picture.w == 0 || picture.h == 0) {
            return;
        }
        
        /* alignment of pointers and datasize */
        {
            int alig_Y = [thiz pixel_unpack_alignment:picture.planes[0] datasize:picture.w * picture.h];
            int alig_U = [thiz pixel_unpack_alignment:picture.planes[1] datasize:picture.w >> 1];
            int alig_V = [thiz pixel_unpack_alignment:picture.planes[2] datasize:picture.w >> 1];
            alignment = (alig_U > alig_V)
            ? ((alig_V > alig_Y) ? alig_Y : alig_V)
            :	((alig_U > alig_Y) ? alig_Y : alig_U);
        }
        
        [thiz->renderFrame processVideoSampleBuffer:yBuffer alignment:alignment];
//		ogl_display_set_yuv_to_display(thiz->display_helper, m);
	}
        
	ms_queue_flush(f->inputs[0]);

	if (f->inputs[1] != NULL) {
		ms_queue_flush(f->inputs[1]);
	}
}



static void iosdisplay_uninit(MSFilter *f) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;

	if (thiz != nil) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		// Remove from parent view in order to release all reference to IOSDisplay
		[thiz performSelectorOnMainThread:@selector(setParentView:) withObject:nil waitUntilDone:NO];
		[thiz release];
		[loopPool drain];
	}
}

static int iosdisplay_set_native_window(MSFilter *f, void *arg) {
	IOSDisplay *thiz = (IOSDisplay*)f->data;
	UIView* parentView = *(UIView**)arg;
	if (thiz != nil) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		// set current parent view
		[thiz performSelectorOnMainThread:@selector(setParentView:) withObject:parentView waitUntilDone:NO];
		[loopPool drain];
	}
	return 0;
}

static int iosdisplay_get_native_window(MSFilter *f, void *arg) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;
	if (!thiz)
		return 0;
	unsigned long *winId = (unsigned long*)arg;
	*winId = (unsigned long)[thiz parentView];
	return 0;
}

static int iosdisplay_set_device_orientation(MSFilter* f, void* arg) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;
	if (!thiz)
		return 0;
	thiz.deviceRotation = *((int*)arg);
	return 0;
}

static int iosdisplay_set_device_orientation_display(MSFilter* f, void* arg) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;
	if (!thiz)
		return 0;
	thiz.displayRotation = *((int*)arg);
	return 0;
}

static int iosdisplay_set_zoom(MSFilter* f, void* arg) {
	IOSDisplay* thiz = (IOSDisplay*)f->data;
	if (!thiz)
		return 0;
	ogl_display_zoom(thiz->display_helper, arg);
	return 0;
}

static MSFilterMethod iosdisplay_methods[] = {
	{ MS_VIDEO_DISPLAY_SET_NATIVE_WINDOW_ID, iosdisplay_set_native_window },
	{ MS_VIDEO_DISPLAY_GET_NATIVE_WINDOW_ID, iosdisplay_get_native_window },
	{ MS_VIDEO_DISPLAY_SET_DEVICE_ORIENTATION, iosdisplay_set_device_orientation },
	{ MS_VIDEO_DISPLAY_SET_DEVICE_ORIENTATION, iosdisplay_set_device_orientation_display },
	{ MS_VIDEO_DISPLAY_ZOOM, iosdisplay_set_zoom },
	{ 0, NULL }
};

MSFilterDesc ms_iosdisplay_desc = {
	.id=MS_IOS_DISPLAY_ID, /* from Allfilters.h*/
	.name="IOSDisplay",
	.text="IOS Display filter.",
	.category=MS_FILTER_OTHER,
	.ninputs=2, /*number of inputs*/
	.noutputs=0, /*number of outputs*/
	.init=iosdisplay_init,
	.process=iosdisplay_process,
	.uninit=iosdisplay_uninit,
	.methods=iosdisplay_methods
};
MS_FILTER_DESC_EXPORT(ms_iosdisplay_desc)
