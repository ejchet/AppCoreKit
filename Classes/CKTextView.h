//
//  CKTextView.h
//  CloudKit
//
//  Created by Olivier Collet on 10-11-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface CKTextView : UITextView {
	UILabel *_placeholderLabel;
	CGFloat _maxStretchableHeight;
    CGPoint _placeholderOffset;
}

@property (nonatomic, readonly, retain) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, assign) NSString *placeholder;
@property (nonatomic, assign) CGFloat maxStretchableHeight;
@property (nonatomic, assign) CGPoint placeholderOffset;

- (void)updateHeight;

@end

//


/** TODO
 */
@protocol CKTextViewDelegate

-(void)textViewValueChanged:(NSString*)text;

@end