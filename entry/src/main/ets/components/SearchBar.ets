import { AppColors } from '../common/constants/Constants'

@Component
export struct SearchBar {
  @State searchText: string = ''
  onSearch?: (keyword: string) => void

  build() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ left: 12, right: 8 })

      TextInput({ text: this.searchText, placeholder: '搜索食材...' })
        .layoutWeight(1)
        .height(36)
        .backgroundColor(Color.Transparent)
        .fontSize(14)
        .fontColor(AppColors.TEXT_PRIMARY)
        .onChange((value: string) => {
          this.searchText = value
          if (this.onSearch) {
            this.onSearch(value)
          }
        })

      if (this.searchText.length > 0) {
        Text('✕')
          .fontSize(14)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ right: 12 })
          .onClick(() => {
            this.searchText = ''
            if (this.onSearch) {
              this.onSearch('')
            }
          })
      }
    }
    .width('100%')
    .height(44)
    .backgroundColor(AppColors.CARD_BACKGROUND)
    .borderRadius(22)
    .alignItems(VerticalAlign.Center)
  }
}
