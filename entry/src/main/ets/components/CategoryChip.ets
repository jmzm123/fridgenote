import { AppColors } from '../common/constants/Constants'

@Component
export struct CategoryChip {
  @Prop label: string = ''
  @Prop isSelected: boolean = false
  onSelected?: () => void

  build() {
    Text(this.label)
      .fontSize(13)
      .fontColor(this.isSelected ? Color.White : AppColors.TEXT_PRIMARY)
      .backgroundColor(this.isSelected ? AppColors.PRIMARY : AppColors.CARD_BACKGROUND)
      .borderRadius(16)
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .onClick(() => {
        if (this.onSelected) {
          this.onSelected()
        }
      })
  }
}
