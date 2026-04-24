import { FoodItem } from '../common/model/FoodItem'
import { getCategoryName, getStorageLocationName, AppColors, StorageLocation } from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { ExpiryBadge } from './ExpiryBadge'

@Component
export struct FoodItemCard {
  @Prop item: FoodItem = new FoodItem()
  onConsume?: () => void
  onDetail?: () => void

  build() {
    Row() {
      // 左侧：分类和名称信息
      Column() {
        Text(this.item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(getCategoryName(this.item.category))
            .fontSize(12)
            .fontColor(AppColors.TEXT_SECONDARY)

          Text('·')
            .fontSize(12)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ left: 4, right: 4 })

          Text(getStorageLocationName(this.item.storageLocation))
            .fontSize(12)
            .fontColor(this.getLocationColor())
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 中间：数量
      Column() {
        Text(`${this.item.quantity}${this.item.unit}`)
          .fontSize(14)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .margin({ left: 12, right: 12 })

      // 右侧：过期状态
      Column() {
        ExpiryBadge({
          status: DateUtils.getExpiryStatus(this.item.expiryDate),
          remainingText: DateUtils.getRemainingDaysText(this.item.expiryDate)
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppColors.CARD_BACKGROUND)
    .borderRadius(12)
    .onClick(() => {
      if (this.onDetail) {
        this.onDetail()
      }
    })
  }

  private getLocationColor(): string {
    switch (this.item.storageLocation) {
      case StorageLocation.FREEZER:
        return AppColors.FREEZER
      case StorageLocation.FRIDGE:
        return AppColors.FRIDGE
      case StorageLocation.ROOM_TEMP:
        return AppColors.ROOM_TEMP
      default:
        return AppColors.TEXT_SECONDARY
    }
  }
}
