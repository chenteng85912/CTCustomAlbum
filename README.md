# Ablum

//选择单张照片 ONE

[ONEPhoto shareSigtonPhoto].delegate =self;//设置代理

[[ONEPhoto shareSigtonPhoto] openAlbum:self editModal:NO];//打开相册选择单张照片

[[ONEPhoto shareSigtonPhoto] openCamera:self editModal:NO];//打开摄像头拍摄单张照片

   
//选择多张照片 MULTIPLE

GroupAlbumViewController *album = [GroupAlbumViewController new];

album.delegate = self;//设置代理

album.totalNum = 12;//设置最大照片选择数量

//弹出相册
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:album];

[self presentViewController:nav animated:YES completion:nil];
    
