##Pinyou 固定位广告iOS SDK集成指南

### iOS SDK集成流程

####1. 获取广告位ID

注册自己的App并获取广告位ID`adUnitId`

####2. iOS SDK配置

1. 在项目中添加libPinyou.a，*.h和Pinyou.bundle文件。
2. 在Targets添加对libPinyou.a的依赖。
3. 在Targets中添加以下Framework

	* SystemConfiguration.framework
	* ImageIO.framework
	* CoreLocation.framework
	* CoreTelephony.framework
	* AdSupport.framework

####3. 广告展示代码

#####3.1 快速展示广告

直接调用`Pinyou`的类方法

	[Pinyou showDefaultTopBannerView];
	
#####3.2 自定义展示广告

需要自定义创建`PYBannerView`对象

	PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:rect] autorelease];
    bannerView.delegate = self;
    [bannerView setAdUnitId:adUnitId];
    [layerView addSubview:bannerView];
    
    [bannerView loadAdInfo];
    


###联系品友**如果您有任何问题或疑问,请及时联系品友移动组。我们将在第一时间做出回应。****Email:mobile-core@ipinyou.com**