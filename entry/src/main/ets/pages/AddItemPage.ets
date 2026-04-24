import { FoodItem } from '../common/model/FoodItem'
import {
  FoodCategory, FoodCategoryList, CategoryItem, StorageLocation,
  UnitOptions, AppColors
} from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct EditItemPage {
  @State foodName: string = ''
  @State selectedCategory: number = FoodCategory.MEAT
  @State selectedLocation: number = StorageLocation.FRIDGE
  @State quantity: string = '1'
  @State selectedUnit: string = '个'
  @State purchaseDateStr: string = ''
  @State expiryDateStr: string = ''
  @State notes: string = ''
  @State editItemId: number = -1

  aboutToAppear() {
    try {
      const params = router.getParams() as Record<string, Object>
      if (params && params['id']) {
        this.editItemId = params['id'] as number
        this.loadItemData(this.editItemId)
      }
    } catch (e) {
      // ignore
    }
  }

  async loadItemData(id: number) {
    try {
      const repo = FoodRepository.getInstance()
      const item = await repo.queryById(id)
      if (item) {
        this.foodName = item.name
        this.selectedCategory = item.category
        this.selectedLocation = item.storageLocation
        this.quantity = item.quantity.toString()
        this.selectedUnit = item.unit
        this.purchaseDateStr = DateUtils.formatDate(item.purchaseDate)
        this.expiryDateStr = item.expiryDate > 0 ? DateUtils.formatDate(item.expiryDate) : ''
        this.notes = item.notes
      }
    } catch (e) {
      console.error('loadItemData error: ' + JSON.stringify(e))
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('<')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
          .onClick(() => {
            try { router.back() } catch (e) {}
          })

        Text('编辑食材')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 12 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          // 食材名称
          Column() {
            Text('食材名称')
              .fontSize(14)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            TextInput({ text: this.foodName, placeholder: '请输入食材名称' })
              .width('100%')
              .height(44)
              .backgroundColor(AppColors.CARD_BACKGROUND)
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
              .fontSize(15)
              .fontColor(AppColors.TEXT_PRIMARY)
              .onChange((value: string) => {
                this.foodName = value
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          // 分类选择
          Column() {
            Text('分类')
              .fontSize(14)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(FoodCategoryList, (cat: CategoryItem) => {
                Text(cat.name)
                  .fontSize(13)
                  .fontColor(this.selectedCategory === cat.value ? Color.White : AppColors.TEXT_PRIMARY)
                  .backgroundColor(this.selectedCategory === cat.value ? AppColors.PRIMARY : AppColors.CARD_BACKGROUND)
                  .borderRadius(16)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.selectedCategory = cat.value
                  })
              }, (cat: CategoryItem) => cat.value.toString())
            }
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          // 存放位置
          Column() {
            Text('存放位置')
              .fontSize(14)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            Row() {
              this.LocationOption(StorageLocation.FREEZER, '冷冻', AppColors.FREEZER)
              this.LocationOption(StorageLocation.FRIDGE, '冷藏', AppColors.FRIDGE)
              this.LocationOption(StorageLocation.ROOM_TEMP, '常温', AppColors.ROOM_TEMP)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          // 数量
          Column() {
            Text('数量')
              .fontSize(14)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            Row() {
              TextInput({ text: this.quantity, placeholder: '1' })
                .type(InputType.Number)
                .width(100)
                .height(44)
                .backgroundColor(AppColors.CARD_BACKGROUND)
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
                .fontSize(15)
                .fontColor(AppColors.TEXT_PRIMARY)
                .onChange((value: string) => {
                  this.quantity = value
                })
              Text(this.selectedUnit)
                .fontSize(15)
                .fontColor(AppColors.TEXT_PRIMARY)
                .margin({ left: 12 })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          // 备注
          Column() {
            Text('备注')
              .fontSize(14)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            TextArea({ text: this.notes, placeholder: '添加备注信息...' })
              .width('100%')
              .height(80)
              .backgroundColor(AppColors.CARD_BACKGROUND)
              .borderRadius(10)
              .padding(12)
              .fontSize(14)
              .fontColor(AppColors.TEXT_PRIMARY)
              .onChange((value: string) => {
                this.notes = value
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          // 保存按钮
          Button('保存修改')
            .width('100%')
            .height(48)
            .backgroundColor(AppColors.PRIMARY)
            .borderRadius(24)
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ top: 8, bottom: 40 })
            .onClick(() => {
              this.saveItem()
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }

  @Builder
  LocationOption(location: number, label: string, color: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.selectedLocation === location ? Color.White : AppColors.TEXT_PRIMARY)
        .fontWeight(this.selectedLocation === location ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('30%')
    .height(44)
    .backgroundColor(this.selectedLocation === location ? color : AppColors.CARD_BACKGROUND)
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedLocation = location
    })
  }

  private async saveItem() {
    if (this.foodName.trim().length === 0) {
      try { promptAction.showToast({ message: '请输入食材名称' }) } catch (e) {}
      return
    }

    const q = parseFloat(this.quantity)
    if (isNaN(q) || q <= 0) {
      try { promptAction.showToast({ message: '请输入有效数量' }) } catch (e) {}
      return
    }

    try {
      const repo = FoodRepository.getInstance()
      const item = new FoodItem()
      item.id = this.editItemId
      item.name = this.foodName.trim()
      item.category = this.selectedCategory
      item.storageLocation = this.selectedLocation
      item.quantity = q
      item.unit = this.selectedUnit
      item.purchaseDate = DateUtils.dateStrToTimestamp(this.purchaseDateStr)
      item.expiryDate = DateUtils.dateStrToTimestamp(this.expiryDateStr)
      item.notes = this.notes.trim()

      await repo.update(item)
      try { promptAction.showToast({ message: '修改成功' }) } catch (e) {}
      try { router.back() } catch (e) {}
    } catch (e) {
      console.error('saveItem error: ' + JSON.stringify(e))
      try { promptAction.showToast({ message: '保存失败' }) } catch (err) {}
    }
  }
}
