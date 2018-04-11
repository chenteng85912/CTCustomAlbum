# CTCustomAlbum CTONEPhoto


#一句代码调用自定义相册，多选照片

        #调用方式一：block
        [CTCustomAlbum showCustomAlbumWithBlock:^(NSArray<UIImage *> *imagesArray) {

        }];

        #调用方式二：代理 self 应当遵守 CTSendPhotosProtocol 协议
        [CTCustomAlbum showCustomAlbumWithDelegate:self];
     
        #pragma mark CTSendPhotosProtocol
        - (void)sendImageArray:(NSMutableArray <UIImage *> *)imgArray{
        }

#一句代码调用系统相册、相机，获取图片或者视频

        #调用方式一：block
        相机
        [CTONEPhoto openCamera:NO photoComplete:^(UIImage *image, NSString *imageName) {

        }];

        照片或视频
        [CTONEPhoto openAlbum:CTShowAlbumImageAndVideoModel enableEdit:NO photoComplete:^(UIImage *image, NSString *imageName) {
        
        } videoComplete:^(NSString *videoPath, NSString *videoName, UIImage *videoShotImage) {
        
        }];
        
        #调用方式二：代理 self 应当遵守 CTONEPhotoDelegate 协议
        
        相机
        [CTCustomAlbum showCustomAlbumWithDelegate:self];
        
        照片
        [CTONEPhoto openAlbum:CTShowAlbumImageModel withDelegate:self enableEdit:NO];
  
        视频
        [CTONEPhoto openAlbum:CTShowAlbumVideoModel withDelegate:self enableEdit:NO];
        
        照片 + 视频
        [CTONEPhoto openAlbum:CTShowAlbumImageAndVideoModel withDelegate:self enableEdit:NO];
        
        #pragma mark CTONEPhotoDelegate
        - (void)sendOnePhoto:(UIImage *)image
               withImageName:(NSString *)imageName{
        }
        - (void)sendVideoPath:(NSString *)videoPath
                    videoName:(NSString *)videoName
               videoShotImage:(UIImage *)videoShotImage{
        }

