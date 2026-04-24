import { FoodItem } from '../common/model/FoodItem'
import { FoodCategoryList, CategoryItem, FoodCategory, StorageLocation, AppColors } from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'
import { FoodItemCard } from '../components/FoodItemCard'
import { CategoryChip } from '../components/CategoryChip'
import { SearchBar } from '../components/SearchBar'
import { EmptyView } from '../components/EmptyView'
import { router } from '@kit.ArkUI'

@Component
export struct InventoryPage {
  @State allItems: FoodItem[] = []
  @State filteredItems: FoodItem[] = []
  @State selectedCategory: number = -1  // -1表示全部
  @State selectedLocation: number = -1  // -1表示全部
  @State searchKeyword: string = ''

  aboutToAppear() {
    this.loadData()
  }

  async loadData() {
    try {
      const repo = FoodRepository.getInstance()
      this.allItems = await repo.queryAll()
      this.applyFilters()
    } catch (e) {
      console.error('InventoryPage loadData error: ' + JSON.stringify(e))
    }
  }

  applyFilters() {
    let items = [...this.allItems]

    // 搜索过滤
    if (this.searchKeyword.length > 0) {
      items = items.filter(item => item.name.includes(this.searchKeyword))
    }

    // 分类过滤
    if (this.selectedCategory >= 0) {
      items = items.filter(item => item.category === this.selectedCategory)
    }

    // 存放位置过滤
    if (this.selectedLocation >= 0) {
      items = items.filter(item => item.storageLocation === this.selectedLocation)
    }

    // 按过期状态排序：过期 > 临期 > 新鲜 > 无保质期
    items.sort((a, b) => {
      const statusA = DateUtils.getExpiryStatus(a.expiryDate)
      const statusB = DateUtils.getExpiryStatus(b.expiryDate)
      return statusA - statusB
    })

    this.filteredItems = items
  }

  build() {
    Column() {
      // 搜索框
      SearchBar({
        onSearch: (keyword: string) => {
          this.searchKeyword = keyword
          this.applyFilters()
        }
      })
      .margin({ bottom: 12 })

      // 分类筛选条
      Scroll() {
        Row() {
          CategoryChip({
            label: '全部',
            isSelected: this.selectedCategory === -1,
            onSelected: () => {
              this.selectedCategory = -1
              this.applyFilters()
            }
          })

          ForEach(FoodCategoryList, (cat: CategoryItem) => {
            CategoryChip({
              label: cat.name,
              isSelected: this.selectedCategory === cat.value,
              onSelected: () => {
                this.selectedCategory = cat.value
                this.applyFilters()
              }
            })
          }, (cat: CategoryItem) => cat.value.toString())
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 8 })

      // 存放位置筛选
      Row() {
        this.LocationFilterItem(-1, '全部')
        this.LocationFilterItem(StorageLocation.FREEZER, '冷冻')
        this.LocationFilterItem(StorageLocation.FRIDGE, '冷藏')
        this.LocationFilterItem(StorageLocation.ROOM_TEMP, '常温')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 12 })

      // 食材列表
      if (this.filteredItems.length === 0) {
        EmptyView({ message: '没有找到食材' })
      } else {
        List() {
          ForEach(this.filteredItems, (item: FoodItem) => {
            ListItem() {
              FoodItemCard({
                item: item,
                onConsume: () => {
                  this.consumeItem(item.id)
                },
                onDetail: () => {
                  this.goToDetail(item.id)
                }
              })
            }
            .swipeAction({ end: {
              builder: (): void => { this.SwipeActions(item) }
            } })
            .margin({ bottom: 8 })
          }, (item: FoodItem) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16 })
    .backgroundColor(AppColors.BACKGROUND)
  }

  @Builder
  LocationFilterItem(location: number, label: string) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(this.selectedLocation === location ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
        .fontWeight(this.selectedLocation === location ? FontWeight.Medium : FontWeight.Normal)
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor(this.selectedLocation === location ? '#EBF5FB' : Color.Transparent)
    .borderRadius(12)
    .onClick(() => {
      this.selectedLocation = location
      this.applyFilters()
    })
  }

  @Builder
  SwipeActions(item: FoodItem) {
    Row() {
      Button('消耗')
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor(AppColors.PRIMARY)
        .borderRadius(8)
        .width(60)
        .height(40)
        .onClick(() => {
          this.consumeItem(item.id)
        })

      Button('删除')
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor(AppColors.EXPIRED)
        .borderRadius(8)
        .width(60)
        .height(40)
        .margin({ left: 8 })
        .onClick(() => {
          this.deleteItem(item.id)
        })
    }
    .margin({ left: 8 })
  }

  private async consumeItem(id: number) {
    try {
      const repo = FoodRepository.getInstance()
      await repo.consume(id, 1)
      this.loadData()
    } catch (e) {
      console.error('consumeItem error: ' + JSON.stringify(e))
    }
  }

  private async deleteItem(id: number) {
    try {
      const repo = FoodRepository.getInstance()
      await repo.deleteById(id)
      this.loadData()
    } catch (e) {
      console.error('deleteItem error: ' + JSON.stringify(e))
    }
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
