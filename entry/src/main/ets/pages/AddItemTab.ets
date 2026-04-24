import { FoodItem } from '../common/model/FoodItem'
import {
  FoodCategory, FoodCategoryList, CategoryItem, StorageLocation,
  UnitOptions, AppColors
} from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'
import { promptAction } from '@kit.ArkUI'

@Component
export struct AddItemTab {
  @State foodName: string = ''
  @State selectedCategory: number = FoodCategory.MEAT
  @State selectedLocation: number = StorageLocation.FRIDGE
  @State quantity: string = '1'
  @State selectedUnit: string = '个'
  @State purchaseDateStr: string = DateUtils.getTodayStr()
  @State expiryDateStr: string = ''
  @State notes: string = ''
  @State showUnitPicker: boolean = false
  @State year: number = 2025
  @State month: number = 1
  @State day: number = 1
  @State expYear: number = 2025
  @State expMonth: number = 1
  @State expDay: number = 1

  aboutToAppear() {
    const now = new Date()
    this.year = now.getFullYear()
    this.month = now.getMonth() + 1
    this.day = now.getDate()
    this.expYear = now.getFullYear()
    this.expMonth = now.getMonth() + 1
    this.expDay = now.getDate()
  }

  build() {
    Scroll() {
      Column() {
        Text('添加食材')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
          .width('100%')
          .margin({ top: 16, bottom: 20 })

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

        // 数量和单位
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
              .onClick(() => {
                this.showUnitPicker = !this.showUnitPicker
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          if (this.showUnitPicker) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(UnitOptions, (unit: string) => {
                Text(unit)
                  .fontSize(13)
                  .fontColor(this.selectedUnit === unit ? Color.White : AppColors.TEXT_PRIMARY)
                  .backgroundColor(this.selectedUnit === unit ? AppColors.PRIMARY : AppColors.CARD_BACKGROUND)
                  .borderRadius(12)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .onClick(() => {
                    this.selectedUnit = unit
                    this.showUnitPicker = false
                  })
              }, (unit: string) => unit)
            }
            .width('100%')
            .margin({ top: 8 })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })
        .alignItems(HorizontalAlign.Start)

        // 购买日期
        Column() {
          Text('购买日期')
            .fontSize(14)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ bottom: 8 })
          this.DateRow(true)
        }
        .width('100%')
        .margin({ bottom: 20 })
        .alignItems(HorizontalAlign.Start)

        // 保质期至
        Column() {
          Text('保质期至')
            .fontSize(14)
            .fontColor(AppColors.TEXT_SECONDARY)
            .margin({ bottom: 8 })
          Row() {
            this.DateRow(false)
            if (this.expiryDateStr.length > 0) {
              Text('清除')
                .fontSize(13)
                .fontColor(AppColors.EXPIRED)
                .margin({ left: 12 })
                .onClick(() => {
                  this.expiryDateStr = ''
                })
            }
          }
          .alignItems(VerticalAlign.Center)
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
        Button('添加食材')
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

  @Builder
  DateRow(isPurchase: boolean) {
    Row() {
      Row() {
        Text(`${isPurchase ? this.year : this.expYear}`)
          .fontSize(15)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('年')
          .fontSize(13)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ left: 2 })
      }
      .padding({ left: 12, right: 8, top: 8, bottom: 8 })
      .backgroundColor(AppColors.CARD_BACKGROUND)
      .borderRadius(8)
      .onClick(() => {
        if (isPurchase) {
          this.year = Math.min(this.year + 1, 2030)
          this.purchaseDateStr = this.formatDateStr(this.year, this.month, this.day)
        } else {
          this.expYear = Math.min(this.expYear + 1, 2030)
          this.expiryDateStr = this.formatDateStr(this.expYear, this.expMonth, this.expDay)
        }
      })

      Row() {
        Text(`${isPurchase ? this.month : this.expMonth}`)
          .fontSize(15)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('月')
          .fontSize(13)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ left: 2 })
      }
      .padding({ left: 10, right: 6, top: 8, bottom: 8 })
      .backgroundColor(AppColors.CARD_BACKGROUND)
      .borderRadius(8)
      .margin({ left: 8 })
      .onClick(() => {
        if (isPurchase) {
          this.month = (this.month % 12) + 1
          this.purchaseDateStr = this.formatDateStr(this.year, this.month, this.day)
        } else {
          this.expMonth = (this.expMonth % 12) + 1
          this.expiryDateStr = this.formatDateStr(this.expYear, this.expMonth, this.expDay)
        }
      })

      Row() {
        Text(`${isPurchase ? this.day : this.expDay}`)
          .fontSize(15)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('日')
          .fontSize(13)
          .fontColor(AppColors.TEXT_SECONDARY)
          .margin({ left: 2 })
      }
      .padding({ left: 10, right: 6, top: 8, bottom: 8 })
      .backgroundColor(AppColors.CARD_BACKGROUND)
      .borderRadius(8)
      .margin({ left: 8 })
      .onClick(() => {
        if (isPurchase) {
          const maxDay = new Date(this.year, this.month, 0).getDate()
          this.day = (this.day % maxDay) + 1
          this.purchaseDateStr = this.formatDateStr(this.year, this.month, this.day)
        } else {
          const maxDay = new Date(this.expYear, this.expMonth, 0).getDate()
          this.expDay = (this.expDay % maxDay) + 1
          this.expiryDateStr = this.formatDateStr(this.expYear, this.expMonth, this.expDay)
        }
      })
    }
    .alignItems(VerticalAlign.Center)
  }

  private formatDateStr(y: number, m: number, d: number): string {
    return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
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
      item.name = this.foodName.trim()
      item.category = this.selectedCategory
      item.storageLocation = this.selectedLocation
      item.quantity = q
      item.unit = this.selectedUnit
      item.purchaseDate = DateUtils.dateStrToTimestamp(this.purchaseDateStr)
      item.expiryDate = DateUtils.dateStrToTimestamp(this.expiryDateStr)
      item.notes = this.notes.trim()

      await repo.insert(item)
      try { promptAction.showToast({ message: '添加成功' }) } catch (e) {}

      this.foodName = ''
      this.quantity = '1'
      this.expiryDateStr = ''
      this.notes = ''
    } catch (e) {
      console.error('saveItem error: ' + JSON.stringify(e))
      try { promptAction.showToast({ message: '保存失败' }) } catch (err) {}
    }
  }
}
