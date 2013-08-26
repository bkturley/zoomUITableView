/*
 * Copyright (c) 2013, BK Turley
 * All rights reserved.
 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "ZTView.h"
#import <QuartzCore/QuartzCore.h>


@implementation ZTView


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
	
        [self addGesture];
        
        CGRect sceenBounds =  [[UIScreen mainScreen]bounds];
        self.screenWidth = sceenBounds.size.width;
        self.screenHeight = sceenBounds.size.height;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.deltaY = 100;
        } else { //phone/pod
            self.deltaY = 50;

        }
    }
    return self;
}

- (void)addGesture {
	
	self.clipsToBounds = YES;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [self addGestureRecognizer:pinchGesture];
}


- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
		UIView *piece = gestureRecognizer.view;
		self.originalFrame = self.frame;
        
        CGPoint locationInView = [gestureRecognizer locationInView:nil];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
		
		UIInterfaceOrientation orientaion = [[UIApplication sharedApplication] statusBarOrientation];

		
		if( orientaion == UIInterfaceOrientationPortrait ) {
                //do nothing
		}
		
		else if ( orientaion == UIInterfaceOrientationPortraitUpsideDown ) {
			
			locationInView.x = self.screenWidth - locationInView.x;
			locationInView.y = (self.screenHeight -20) - locationInView.y;
		}
		
		else if ( orientaion == UIInterfaceOrientationLandscapeLeft ) {
			
			float x =  self.screenHeight - locationInView.y;
			float y = locationInView.x;
			
			locationInView.x = x;
			locationInView.y = y;
			
		}
		else if ( orientaion == UIInterfaceOrientationLandscapeRight ) {
			
			float y =  locationInView.y;
			float x = self.screenWidth - locationInView.x;
			
			locationInView.x = y;
			locationInView.y = x;
		}
        
		piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, (locationInView.y -self.deltaY) / piece.bounds.size.height);
        
        piece.center = locationInSuperview;
		
    }
	
	else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
		[self resetSize];
	}
	
}

- (void)resetSize
{
	
	[UIView beginAnimations:nil context:nil];
	[self setTransform:CGAffineTransformIdentity];
	self.frame = self.originalFrame;
	[UIView commitAnimations];
}

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer {
	
	[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
		[gestureRecognizer setScale:1];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
