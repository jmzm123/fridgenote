import { ExpiryStatus, AppColors } from '../common/constants/Constants'

@Component
export struct ExpiryBadge {
  @Prop status: ExpiryStatus = ExpiryStatus.FRESH
  @Prop remainingText: string = ''

  build() {
    Text(this.remainingText)
      .fontSize(11)
      .fontColor(Color.White)
      .backgroundColor(this.getBackgroundColor())
      .borderRadius(10)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }

  private getBackgroundColor(): string {
    switch (this.status) {
      case ExpiryStatus.EXPIRED:
        return AppColors.EXPIRED
      case ExpiryStatus.EXPIRING_SOON:
        return AppColors.EXPIRING_SOON
      case ExpiryStatus.FRESH:
        return AppColors.FRESH
      case ExpiryStatus.NO_EXPIRY:
      default:
        return AppColors.NO_EXPIRY
    }
  }
}
