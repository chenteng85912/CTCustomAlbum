//
//  AlbumViewController.m
//  eyerecolor
//
//  Created by 腾 on 15/9/15.
//
//

#import "ListGroupViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ListGroupViewController ()<UITableViewDataSource,UITableViewDelegate>

@end
static NSString *identify = @"albumTable";

@implementation ListGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tbView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tbView.delegate = self;
    tbView.dataSource = self;
    self.TbView = tbView;
    
    [self.view addSubview:tbView];
    [self.TbView registerClass:[UITableViewCell class] forCellReuseIdentifier:identify];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *mycell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    if (!mycell) {
        mycell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    }
    ALAssetsGroup *group = self.groupArray[self.groupArray.count - 1- indexPath.row];
    [self scaleCellImageView:mycell.imageView withImage:[UIImage imageWithCGImage:group.posterImage]];
    mycell.imageView.layer.masksToBounds = YES;
    mycell.imageView.layer.cornerRadius = 5.0;
    mycell.textLabel.text = [group  valueForProperty:ALAssetsGroupPropertyName];
    mycell.detailTextLabel.text = [NSString stringWithFormat:@"%ld photos",(long)group.numberOfAssets];
    if (indexPath.row==0) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    }
    return mycell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(initGroupDetailsData:)]) {
        [self.delegate initGroupDetailsData:self.groupArray[self.groupArray.count - 1- indexPath.row]];
    }
}

- (void)scaleCellImageView:(UIImageView *)imgView withImage:(UIImage *)img{
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [img drawInRect:imageRect];
    
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
