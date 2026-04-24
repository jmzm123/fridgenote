import { FoodItem } from '../common/model/FoodItem'
import { AppColors, ExpiryStatus } from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'
import { FoodItemCard } from '../components/FoodItemCard'
import { ExpiryBadge } from '../components/ExpiryBadge'
import { EmptyView } from '../components/EmptyView'
import { router } from '@kit.ArkUI'

@Component
export struct HomePage {
  @State expiredItems: FoodItem[] = []
  @State expiringSoonItems: FoodItem[] = []
  @State recentItems: FoodItem[] = []
  @State totalCount: number = 0
  @State expiredCount: number = 0
  @State expiringSoonCount: number = 0

  aboutToAppear() {
    this.loadData()
  }

  async loadData() {
    try {
      const repo = FoodRepository.getInstance()
      const expired = await repo.queryExpired()
      const expiringSoon = await repo.queryExpiringSoon()
      const recent = await repo.queryRecent(5)
      const all = await repo.queryAll()

      this.expiredItems = expired
      this.expiringSoonItems = expiringSoon
      this.recentItems = recent
      this.totalCount = all.length
      this.expiredCount = expired.length
      this.expiringSoonCount = expiringSoon.length
    } catch (e) {
      console.error('HomePage loadData error: ' + JSON.stringify(e))
    }
  }

  build() {
    Scroll() {
      Column() {
        // 标题栏
        this.TitleBar()

        // 过期/临期警告区域
        this.WarningSection()

        // 统计概览
        this.StatsSection()

        // 最近添加
        this.RecentSection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }

  @Builder
  TitleBar() {
    Row() {
      Text('冰箱笔记')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
  }

  @Builder
  WarningSection() {
    Column() {
      // 已过期警告
      if (this.expiredCount > 0) {
        Column() {
          Row() {
            Text('已过期')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            Text(`${this.expiredCount}项`)
              .fontSize(14)
              .fontColor('#FFCCCC')
              .margin({ left: 8 })
          }

          ForEach(this.expiredItems.slice(0, 3), (item: FoodItem) => {
            Row() {
              Text(item.name)
                .fontSize(14)
                .fontColor(Color.White)
                .layoutWeight(1)
              ExpiryBadge({
                status: ExpiryStatus.EXPIRED,
                remainingText: DateUtils.getRemainingDaysText(item.expiryDate)
              })
            }
            .width('100%')
            .margin({ top: 8 })
          }, (item: FoodItem) => item.id.toString())

          if (this.expiredCount > 3) {
            Text(`还有${this.expiredCount - 3}项已过期...`)
              .fontSize(12)
              .fontColor('#FFCCCC')
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AppColors.EXPIRED)
        .borderRadius(12)
        .margin({ bottom: 8 })
      }

      // 临期警告
      if (this.expiringSoonCount > 0) {
        Column() {
          Row() {
            Text('即将到期')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
            Text(`${this.expiringSoonCount}项`)
              .fontSize(14)
              .fontColor('#FFF3CD')
              .margin({ left: 8 })
          }

          ForEach(this.expiringSoonItems.slice(0, 3), (item: FoodItem) => {
            Row() {
              Text(item.name)
                .fontSize(14)
                .fontColor(Color.White)
                .layoutWeight(1)
              ExpiryBadge({
                status: ExpiryStatus.EXPIRING_SOON,
                remainingText: DateUtils.getRemainingDaysText(item.expiryDate)
              })
            }
            .width('100%')
            .margin({ top: 8 })
          }, (item: FoodItem) => item.id.toString())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(AppColors.EXPIRING_SOON)
        .borderRadius(12)
      }
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  StatsSection() {
    Column() {
      Text('冰箱概览')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: 12 })

      Row() {
        this.StatItem('食材总数', `${this.totalCount}`, AppColors.PRIMARY)
        this.StatItem('即将到期', `${this.expiringSoonCount}`, AppColors.EXPIRING_SOON)
        this.StatItem('已过期', `${this.expiredCount}`, AppColors.EXPIRED)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppColors.CARD_BACKGROUND)
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  StatItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  RecentSection() {
    Column() {
      Row() {
        Text('最近添加')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)

        Blank()

        Text('查看全部')
          .fontSize(14)
          .fontColor(AppColors.PRIMARY)
          .onClick(() => {
            // 切换到库存Tab
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.recentItems.length === 0) {
        EmptyView({ message: '冰箱空空如也，快去添加食材吧' })
      } else {
        ForEach(this.recentItems, (item: FoodItem) => {
          Column() {
            FoodItemCard({
              item: item,
              onDetail: () => {
                this.goToDetail(item.id)
              }
            })
          }
          .margin({ bottom: 8 })
        }, (item: FoodItem) => item.id.toString())
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppColors.CARD_BACKGROUND)
    .borderRadius(12)
  }

  private goToDetail(id: number) {
    try {
      router.pushUrl({
        url: 'pages/ItemDetailPage',
        params: { id: id }
      })
    } catch (e) {
      console.error('router pushUrl error')
    }
  }
}
