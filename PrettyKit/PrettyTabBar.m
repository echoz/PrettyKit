//
//  PrettyTabBar.m
//  PrettyExample
//
//  Created by Víctor on 01/03/12.

// Copyright (c) 2012 Victor Pena Placer (@vicpenap)
// http://www.victorpena.es/
// 
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "PrettyTabBar.h"
#import "PrettyDrawing.h"
#import "PrettyTabBarButton.h"

#define default_upwards_shadow_opacity                  0.5
#define default_downwards_shadow_opacity                0.5
#define default_gradient_start_color                    [UIColor colorWithHex:0x444444]
#define default_gradient_end_color                      [UIColor colorWithHex:0x060606]
#define default_separator_line_color                    [UIColor colorWithHex:0x666666]

// pretty buttons
#define default_text_shadow_offset                      CGSizeMake(0,-1)
#define default_text_shadow_opacity                     0.5
#define default_font                                    [UIFont boldSystemFontOfSize:10]
#define default_text_color                              [UIColor colorWithWhite:0.5 alpha:1.0]
#define default_highlighted_text_color                  [UIColor colorWithWhite:0.90 alpha:1.0]
#define default_badge_font                              [UIFont boldSystemFontOfSize:11]
#define default_badge_gradient_start_color              [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:1.000]
#define default_badge_gradient_end_color                [UIColor colorWithRed:0.6 green:0.000 blue:0.000 alpha:1.000]
#define default_badge_border_color                      [UIColor whiteColor]
#define default_badge_shadow_opacity                    0.75
#define default_badge_shadow_offset                     CGSizeMake(0,2)
#define default_badge_text_color                        [UIColor whiteColor]
#define default_highlight_corner_radius                 3.0
#define default_highlight_gradient_start_color          [UIColor colorWithWhite:0.35 alpha:1.0] 
#define default_highlight_gradient_end_color            [UIColor colorWithWhite:0.2 alpha:1.0]
#define default_highlighted_image_gradient_start_color  [UIColor colorWithRed:0.276 green:0.733 blue:1.000 alpha:1.000]
#define default_highlighted_image_gradient_end_color    [UIColor colorWithRed:0.028 green:0.160 blue:0.332 alpha:1.000]

@interface PrettyTabBar (/* Private Methods */)
@property (nonatomic, retain) NSMutableArray *_prettyTabBarButtons;
@property (nonatomic, retain) NSMutableArray *_originalTabBarButtons;
-(void)_prettyTabBarButtonTapped:(id)sender;
-(UIImage *)_imageForPrettyButtonImagesOfIndex:(NSInteger)index;
-(void)_setupTabBarSubviews;
@end

@implementation PrettyTabBar
@synthesize upwardsShadowOpacity, downwardsShadowOpacity, gradientStartColor, gradientEndColor, separatorLineColor;
@synthesize prettyTabBarButtons, prettyStretchedTabBarButtons;

@synthesize prettyButtonHighlightedImageGradientStartColor, prettyButtonHighlightedImageGradientEndColor, prettyButtonHighlightedImages;
@synthesize prettyButtonTitleFont, prettyButtonTitleTextColor, prettyButtonTitleHighlightedTextColor, prettyButtonTitleTextShadowOpacity, prettyButtonTitleTextShadowOffset;
@synthesize prettyButtonHighlightGradientStartColor, prettyButtonHighlightGradientEndColor, prettyButtonHighlightImage, prettyButtonHighlightCornerRadius;
@synthesize prettyButtonBadgeBorderColor, prettyButtonBadgeGradientStartColor, prettyButtonBadgeGradientEndColor, prettyButtonBadgeShadowOpacity, prettyButtonBadgeShadowOffset, prettyButtonBadgeFont, prettyButtonBadgeTextColor;

@synthesize _prettyTabBarButtons = __prettyTabBarButtons, _originalTabBarButtons = __originalTabBarButtons;

#pragma mark - Object Life Cycle

- (void) dealloc {
    
    if (self.prettyTabBarButtons) {
        for (UITabBarItem *item in self.items)
            [item removeObserver:self forKeyPath:@"badgeValue"];
    }
    
    self.gradientStartColor = nil;
    self.gradientEndColor = nil;
    self.separatorLineColor = nil;
    
    self._originalTabBarButtons = nil;
    self._prettyTabBarButtons = nil;
    
    self.prettyButtonHighlightedImages = nil;
    
    self.prettyButtonHighlightedImageGradientStartColor = nil;
    self.prettyButtonHighlightedImageGradientEndColor = nil;
    self.prettyButtonTitleFont = nil;
    self.prettyButtonTitleTextColor = nil;
    self.prettyButtonTitleHighlightedTextColor = nil;
    self.prettyButtonBadgeBorderColor = nil;
    self.prettyButtonBadgeGradientStartColor = nil;
    self.prettyButtonBadgeGradientEndColor = nil;
    self.prettyButtonBadgeFont = nil;
    self.prettyButtonBadgeTextColor = nil;
    self.prettyButtonHighlightImage = nil;
    self.prettyButtonHighlightGradientStartColor = nil;
    self.prettyButtonHighlightGradientEndColor = nil;
    
    [super dealloc];
}

- (void) initializeVars 
{
    self.contentMode = UIViewContentModeRedraw;

    self.prettyTabBarButtons = NO;
    self.prettyStretchedTabBarButtons = NO;
    
    self.upwardsShadowOpacity = default_upwards_shadow_opacity;
    self.downwardsShadowOpacity = default_downwards_shadow_opacity;
    self.gradientStartColor = default_gradient_start_color;
    self.gradientEndColor = default_gradient_end_color;
    self.separatorLineColor = default_separator_line_color;
    
    // pretty button stuff
    self._prettyTabBarButtons = [NSMutableArray arrayWithCapacity:5];
    self._originalTabBarButtons = [NSMutableArray arrayWithCapacity:0];
    self.prettyButtonHighlightedImages = nil;
    
    self.prettyButtonHighlightCornerRadius = default_highlight_corner_radius;
    self.prettyButtonHighlightedImageGradientStartColor = default_highlighted_image_gradient_start_color;
    self.prettyButtonHighlightedImageGradientEndColor = default_highlighted_image_gradient_end_color;
    self.prettyButtonTitleFont = default_font;
    self.prettyButtonTitleTextColor = default_text_color;
    self.prettyButtonTitleHighlightedTextColor = default_highlighted_text_color;
    self.prettyButtonTitleTextShadowOpacity = default_text_shadow_opacity;
    self.prettyButtonTitleTextShadowOffset = default_text_shadow_offset;
    self.prettyButtonBadgeBorderColor = default_badge_border_color;
    self.prettyButtonBadgeGradientStartColor = default_badge_gradient_start_color;
    self.prettyButtonBadgeGradientEndColor = default_badge_gradient_end_color;
    self.prettyButtonBadgeShadowOffset = default_badge_shadow_offset;
    self.prettyButtonBadgeShadowOpacity = default_badge_shadow_opacity;
    self.prettyButtonBadgeFont = default_badge_font;
    self.prettyButtonBadgeTextColor = default_badge_text_color;
    self.prettyButtonHighlightImage = nil;
    self.prettyButtonHighlightGradientStartColor = default_highlight_gradient_start_color;
    self.prettyButtonHighlightGradientEndColor = default_highlight_gradient_end_color;
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeVars];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeVars];
    }
    return self;
}


- (id)init {
    self = [super init];
    if (self) {
        [self initializeVars];
    }
    return self;
}

#pragma mark - Overrides to handle internal PrettyTabBarButton

-(void)setItems:(NSArray *)items {
    [super setItems:items];
    
    [self _setupTabBarSubviews];
    [self setNeedsLayout];
}

-(void)setItems:(NSArray *)items animated:(BOOL)animated {
    [super setItems:items animated:animated];

    [self _setupTabBarSubviews];
    [self setNeedsLayout];
}

-(void)setSelectedItem:(UITabBarItem *)selectedItem {
    [super setSelectedItem:selectedItem];
    
    [self _setupTabBarSubviews];
    [self setNeedsLayout];
}


-(void)_setupTabBarSubviews {
    if (self.prettyTabBarButtons) {
        // changing from original to pretty implementation       
        
        // remove views that are not prettytabbarbuttons
        // they are usually the original buttons so add them to temp storage
        for (UIView *view in self.subviews) {
            if (![view isKindOfClass:[PrettyTabBarButton class]])
                [__originalTabBarButtons addObject:view];
            
            [view removeFromSuperview];
        }
        
        PrettyTabBarButton *button = nil;            
        // iterate over the data objects (UITabBarItem) and create the
        // pretty tabbar buttons that they represent and position them 
        // in the view.
        // we leave setting of properties to the laying out of subviews
        // where its always supposed to be anyways
        NSUInteger i = 0;
        
        for (UITabBarItem *item in self.items) {
            [item addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:item];
            
            button = [[PrettyTabBarButton alloc] initWithTitle:item.title image:item.image tag:i];
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            button.stretchedButton = self.prettyStretchedTabBarButtons;
            
            [button addTarget:self action:@selector(_prettyTabBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if (item == self.selectedItem) {
                button.selected = YES;
            } else {
                button.selected = NO;
            }
            
            [self addSubview:button];
            [__prettyTabBarButtons addObject:button];
            [button release];
            i++;
        }                
        
        
    } else {
        // changing from pretty to original implementation
        
        // remove observation status and remove the object from super view
        NSUInteger i = 0;
        
        for (UITabBarItem *item in self.items) {
            if ([__prettyTabBarButtons count] > 0) {
                [[__prettyTabBarButtons objectAtIndex:i] removeFromSuperview];
                [item removeObserver:self forKeyPath:@"badgeValue"];
            }
            
            i++;
        }                
        
        [__prettyTabBarButtons removeAllObjects];
        
        // lets add all the original buttons back into the view!
        for (UIView *view in self._originalTabBarButtons) {
            [self addSubview:view];
        }
        
        [__originalTabBarButtons removeAllObjects];
        
    }
}

-(void)setPrettyTabBarButtons:(BOOL)prettyTabBarButtons_ {
    
    // we should only change the status if its different
    
    if (prettyTabBarButtons != prettyTabBarButtons_) {
        
        // set the status of our internal representation
        prettyTabBarButtons = prettyTabBarButtons_;

        [self _setupTabBarSubviews];

        // finally, layout if there is a superview, ie. our view has been
        // added as a view somewhere
        if (self.superview)
            [self setNeedsLayout];
    }    
    
}

-(void)_prettyTabBarButtonTapped:(id)sender {
    if (self.prettyTabBarButtons) {
        for (PrettyTabBarButton *button in __prettyTabBarButtons) {
            button.selected = NO;
        }
        
        ((PrettyTabBarButton *)sender).selected = YES;
        
        if ([sender isKindOfClass:[PrettyTabBarButton class]]) {
            if ([self.delegate isKindOfClass:[UITabBarController class]]) {
                [((UITabBarController *)self.delegate) setSelectedIndex:((PrettyTabBarButton *)sender).tag];
            }
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (([keyPath isEqualToString:@"badgeValue"]) && (self.prettyTabBarButtons)) {
        UITabBarItem *item = (UITabBarItem *)context;
        NSUInteger index = [self.items indexOfObject:item];
        
        if ((index != NSNotFound) && ([self._prettyTabBarButtons count] > 0))
            [[self._prettyTabBarButtons objectAtIndex:index] setBadgeValue:[change objectForKey:NSKeyValueChangeNewKey]];
        
    } else {
        @try {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        @catch (NSException *exception) { }
    }
}

#pragma mark - Display
-(UIImage *)_imageForPrettyButtonImagesOfIndex:(NSInteger)index {
    if ([self.prettyButtonHighlightedImages count] == 0)
        return nil;
    
    id image = [self.prettyButtonHighlightedImages objectAtIndex:index];
    
    if ([image isKindOfClass:[NSNull class]])
        return nil;
    
    return image;
}

-(void)layoutSubviews {
    
    // make sure item count is not greater than 5. as we didn't
    // cater for customization of items.
    if ([self.items count] > 5)
        self.prettyTabBarButtons = NO;
    
    [super layoutSubviews];
    
    // so if we are the right mode and there are actual data objects
    // lets go ahead and layout the pretty buttons
    if (self.prettyTabBarButtons) {
        PrettyTabBarButton *button = nil;
        NSUInteger i = 0;
        
        // set frame and set all properties!
        for (UITabBarItem *item in self.items) {
            if ([self._prettyTabBarButtons count] == 0)
                break;
            
            button = [self._prettyTabBarButtons objectAtIndex:i];
            if (self.prettyStretchedTabBarButtons) {
                button.frame = CGRectMake(i * (self.frame.size.width/[self.items count]), 0, (self.frame.size.width/[self.items count]) - 1, self.frame.size.height);
            } else {
                button.frame = CGRectMake(i * (self.frame.size.width/[self.items count]), 0.5, (self.frame.size.width/[self.items count]) - 1, self.frame.size.height);
            }

            [self addSubview:button];
            
            // set button properties
            button.font = self.prettyButtonTitleFont;
            button.textColor = self.prettyButtonTitleTextColor;
            button.highlightedTextColor = self.prettyButtonTitleHighlightedTextColor;
            button.textShadowOpacity = self.prettyButtonTitleTextShadowOpacity;
            button.textShadowOffset = self.prettyButtonTitleTextShadowOffset;
            button.badgeBorderColor = self.prettyButtonBadgeBorderColor;
            button.badgeGradientStartColor = self.prettyButtonBadgeGradientStartColor;
            button.badgeGradientEndColor = self.prettyButtonBadgeGradientEndColor;
            button.badgeShadowOffset = self.prettyButtonBadgeShadowOffset;
            button.badgeShadowOpacity = self.prettyButtonBadgeShadowOpacity;
            button.badgeFont = self.prettyButtonBadgeFont;
            button.badgeTextColor = self.prettyButtonBadgeTextColor;
            button.highlightImage = self.prettyButtonHighlightImage;
            button.highlightGradientStartColor = self.prettyButtonHighlightGradientStartColor;
            button.highlightGradientEndColor = self.prettyButtonHighlightGradientEndColor;
            button.highlightedImage = [self _imageForPrettyButtonImagesOfIndex:i];
            button.highlightedImageGradientStartColor = self.prettyButtonHighlightedImageGradientStartColor;
            button.highlightedImageGradientEndColor = self.prettyButtonHighlightedImageGradientEndColor;
            button.highlightCornerRadius = self.prettyButtonHighlightCornerRadius;
            button.stretchedButton = self.prettyStretchedTabBarButtons;
            
            button.selected = NO;
            button.badgeValue = item.badgeValue;
            button.title = item.title;
            button.image = item.image;

            if (item == self.selectedItem)
                button.selected = YES;
            
            i++;
        }
        
    }
    
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (self.upwardsShadowOpacity > 0)
        [self dropShadowOffset:CGSizeMake(0, -1) withOpacity:self.upwardsShadowOpacity];
    
    if (self.downwardsShadowOpacity > 0)
        [self dropShadowOffset:CGSizeMake(0, 0) withOpacity:self.downwardsShadowOpacity];
    
    [PrettyDrawing drawGradient:rect fromColor:self.gradientStartColor toColor:self.gradientEndColor];
    [PrettyDrawing drawLineAtHeight:0 rect:rect color:self.separatorLineColor width:0.5];
}

@end
