//
//  NSLabel.h
//  ChitChat
//
//  Courtesy: Axel Guilmin
//  http://stackoverflow.com/questions/20169298/xcode-doesnt-recognize-nslabel
//
#import "NSLabel.h"

@implementation NSLabel

#pragma mark INIT
- (instancetype)init {
  self = [super init];
  if (self) {
    [self textFieldToLabel];
  }
  return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self textFieldToLabel];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self textFieldToLabel];
  }
  return self;
}

#pragma mark SETTER
- (void)setFontSize:(CGFloat)fontSize {
  super.font = [NSFont fontWithName:self.font.fontName size:fontSize];
}

- (void)setText:(NSString *)text {
  [super setStringValue:text];
}

#pragma mark GETTER
- (CGFloat)fontSize {
  return super.font.pointSize;
}

- (NSString*)text {
  return [super stringValue];
}

#pragma mark - PRIVATE
- (void)textFieldToLabel {
  super.bezeled = NO;
  super.drawsBackground = NO;
  super.editable = NO;
  super.selectable = NO;
}

@end