import { AppColors } from '../common/constants/Constants'

@Component
export struct EmptyView {
  @Prop message: string = '暂无数据'

  build() {
    Column() {
      Text(this.message)
        .fontSize(14)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
