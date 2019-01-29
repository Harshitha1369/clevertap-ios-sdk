#import "CTInboxIconMessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CTConstants.h"
#import "CTInAppUtils.h"

@implementation CTInboxIconMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnMessageTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.cellImageView sd_cancelCurrentAnimationImagesLoad];
    [self.cellIcon sd_cancelCurrentAnimationImagesLoad];
    self.cellImageView.image = nil;
    self.cellIcon.image = nil;
}

- (void)doLayoutForMessage:(CleverTapInboxMessage *)message {
    self.cellImageView.hidden = YES;
    self.avPlayerControlsView.alpha = 0.0;
    self.avPlayerContainerView.hidden = YES;
    self.activityIndicator.hidden = YES;
    CleverTapInboxMessageContent *content = message.content[0];
    if (content.mediaUrl == nil || [content.mediaUrl isEqual: @""]) {
        self.imageViewHeightContraint.priority = 999;
        self.imageViewLRatioContraint.priority = 750;
        self.imageViewPRatioContraint.priority = 750;
    } else if ([message.orientation.uppercaseString isEqualToString:@"P"] || message.orientation == nil ) {
        self.imageViewPRatioContraint.priority = 999;
        self.imageViewLRatioContraint.priority = 750;
        self.imageViewHeightContraint.priority = 750;
    } else {
        self.imageViewHeightContraint.priority = 750;
        self.imageViewPRatioContraint.priority = 750;
        self.imageViewLRatioContraint.priority = 999;
    }
    self.cellImageView.clipsToBounds = YES;
    self.titleLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.titleColor];
    self.bodyLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.messageColor];
    self.dateLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.titleColor];
    [self hideActionView:!content.actionHasLinks];
    [self layoutSubviews];
    [self layoutIfNeeded];
}

- (void)setupMessage:(CleverTapInboxMessage *)message {
    self.message = message;
     if (!message.content || message.content.count < 0) {
         self.titleLabel.text = nil;
         self.bodyLabel.text = nil;
         self.dateLabel.text = nil;
         self.cellImageView.image = nil;
         self.cellIcon = nil;
         return;
     }
    CleverTapInboxMessageContent *content = message.content[0];
    self.titleLabel.text = content.title;
    self.bodyLabel.text = content.message;
    self.dateLabel.text = message.relativeDate;
    self.readView.hidden = message.isRead;
    self.readViewWidthContraint.constant = message.isRead ? 0 : 16;
    [self setupInboxMessageActions:content];
    self.cellImageView.contentMode = content.mediaIsGif ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    if (content.mediaUrl && !content.mediaIsVideo && !content.mediaIsAudio) {
        self.cellImageView.hidden = NO;
        [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:content.mediaUrl]
                              placeholderImage:nil
                                       options:self.sdWebImageOptions];
    } else if (content.mediaIsVideo || content.mediaIsAudio) {
        [self setupMediaPlayer];
    }
    
    if (content.iconUrl) {
        [self.cellIcon sd_setImageWithURL:[NSURL URLWithString:content.iconUrl] placeholderImage: nil options:self.sdWebImageOptions];
        self.cellIconRatioContraint.priority = 999;
        self.cellIconWidthContraint.priority = 750;
    } else {
        self.cellIconRatioContraint.priority = 750;
        self.cellIconWidthContraint.priority = 999;
    }
}

- (void)hideActionView:(BOOL)hide {
    self.actionView.hidden = hide;
    self.actionViewHeightContraint.constant = hide ? 0 : 45;
    self.actionView.delegate = self;
}

@end
