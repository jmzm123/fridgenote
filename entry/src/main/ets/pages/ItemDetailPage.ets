import { FoodItem } from '../common/model/FoodItem'
import {
  getCategoryName, getStorageLocationName, AppColors
} from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'
import { ExpiryBadge } from '../components/ExpiryBadge'
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct ItemDetailPage {
  @State item: FoodItem = new FoodItem()
  @State itemId: number = -1

  aboutToAppear() {
    try {
      const params = router.getParams() as Record<string, Object>
      if (params && params['id']) {
        this.itemId = params['id'] as number
        this.loadItem()
      }
    } catch (e) {
      // ignore
    }
  }

  async loadItem() {
    try {
      const repo = FoodRepository.getInstance()
      const item = await repo.queryById(this.itemId)
      if (item) {
        this.item = item
      }
    } catch (e) {
      console.error('loadItem error: ' + JSON.stringify(e))
    }
  }

  build() {
    Scroll() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('<')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)
            .onClick(() => {
              try { router.back() } catch (e) {}
            })

          Text('食材详情')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ left: 12 })
            .layoutWeight(1)

          // 编辑按钮
          Text('编辑')
            .fontSize(15)
            .fontColor(AppColors.PRIMARY)
            .onClick(() => {
              this.goToEdit()
            })
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)

        // 食材名称和过期状态
        Column() {
          Text(this.item.name)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)

          ExpiryBadge({
            status: DateUtils.getExpiryStatus(this.item.expiryDate),
            remainingText: DateUtils.getRemainingDaysText(this.item.expiryDate)
          })
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 16, bottom: 24 })

        // 详细信息卡片
        Column() {
          this.DetailRow('分类', getCategoryName(this.item.category))
          this.DetailRow('存放位置', getStorageLocationName(this.item.storageLocation))
          this.DetailRow('数量', `${this.item.quantity} ${this.item.unit}`)
          this.DetailRow('购买日期', this.item.purchaseDate > 0 ? DateUtils.formatDate(this.item.purchaseDate) : '未设置')
          this.DetailRow('保质期至', this.item.expiryDate > 0 ? DateUtils.formatDate(this.item.expiryDate) : '未设置')

          if (this.item.notes.length > 0) {
            this.DetailRow('备注', this.item.notes)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AppColors.CARD_BACKGROUND)
        .borderRadius(12)

        // 操作按钮
        Row() {
          // 消耗按钮
          Button('消耗一个')
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(22)
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.consumeItem()
            })

          // 删除按钮
          Button('删除')
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor(AppColors.EXPIRED)
            .borderRadius(22)
            .layoutWeight(1)
            .height(44)
            .margin({ left: 12 })
            .onClick(() => {
              this.deleteItem()
            })
        }
        .width('100%')
        .margin({ top: 24, bottom: 40 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }

  @Builder
  DetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor(AppColors.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .borderRadius(0)
  }

  private async consumeItem() {
    try {
      const repo = FoodRepository.getInstance()
      await repo.consume(this.item.id, 1)
      try { promptAction.showToast({ message: '已消耗' }) } catch (e) {}
      this.loadItem()
    } catch (e) {
      console.error('consumeItem error: ' + JSON.stringify(e))
    }
  }

  private async deleteItem() {
    try {
      const repo = FoodRepository.getInstance()
      await repo.deleteById(this.item.id)
      try { promptAction.showToast({ message: '已删除' }) } catch (err) {}
      try { router.back() } catch (e) {}
    } catch (e) {
      console.error('deleteItem error: ' + JSON.stringify(e))
    }
  }

  private goToEdit() {
    try {
      router.pushUrl({
        url: 'pages/AddItemPage',
        params: { id: this.item.id }
      })
    } catch (e) {
      console.error('router pushUrl error')
    }
  }
}
