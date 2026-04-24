import { AppColors } from '../common/constants/Constants'
import { HomePage } from './HomePage'
import { InventoryPage } from './InventoryPage'
import { AddItemTab } from './AddItemTab'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  private tabController: TabsController = new TabsController()

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBuilder(0, '首页'))

        TabContent() {
          InventoryPage()
        }
        .tabBar(this.TabBuilder(1, '库存'))

        TabContent() {
          AddItemTab()
        }
        .tabBar(this.TabBuilder(2, '添加'))
      }
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }

  @Builder
  TabBuilder(index: number, title: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}