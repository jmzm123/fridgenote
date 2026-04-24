import { FoodItem } from '../common/model/FoodItem'
import { FoodCategory, StorageLocation, ExpiryStatus } from '../common/constants/Constants'
import { DateUtils } from '../common/utils/DateUtils'
import { FoodRepository } from '../data/FoodRepository'

/**
 * 视图模型 - 连接数据层和UI层
 * 提供状态管理和数据刷新逻辑
 */
export class FoodViewModel {
  private static instance: FoodViewModel
  private repo: FoodRepository = FoodRepository.getInstance()

  private constructor() {}

  static getInstance(): FoodViewModel {
    if (!FoodViewModel.instance) {
      FoodViewModel.instance = new FoodViewModel()
    }
    return FoodViewModel.instance
  }

  /**
   * 获取首页所需数据
   */
  async getHomeData(): Promise<HomeData> {
    const allItems = await this.repo.queryAll()
    const expiredItems = await this.repo.queryExpired()
    const expiringSoonItems = await this.repo.queryExpiringSoon()
    const recentItems = await this.repo.queryRecent(5)
    const categoryCount = await this.repo.countByCategory()

    return {
      totalCount: allItems.length,
      expiredCount: expiredItems.length,
      expiringSoonCount: expiringSoonItems.length,
      expiredItems: expiredItems,
      expiringSoonItems: expiringSoonItems,
      recentItems: recentItems,
      categoryCount: categoryCount
    }
  }

  /**
   * 获取库存页所需数据（带过滤）
   */
  async getInventoryData(category: number, location: number, keyword: string): Promise<FoodItem[]> {
    let items: FoodItem[]

    if (keyword.length > 0) {
      items = await this.repo.queryByName(keyword)
    } else if (category >= 0 && location >= 0) {
      items = await this.repo.queryByCategoryAndLocation(category, location)
    } else if (category >= 0) {
      items = await this.repo.queryByCategory(category)
    } else if (location >= 0) {
      items = await this.repo.queryByStorageLocation(location)
    } else {
      items = await this.repo.queryAll()
    }

    // 按过期状态排序
    return this.sortByExpiryStatus(items)
  }

  /**
   * 保存食材（新增或编辑）
   */
  async saveFoodItem(item: FoodItem): Promise<boolean> {
    try {
      if (item.id > 0) {
        await this.repo.update(item)
      } else {
        await this.repo.insert(item)
      }
      return true
    } catch (e) {
      console.error('FoodViewModel saveFoodItem error: ' + JSON.stringify(e))
      return false
    }
  }

  /**
   * 消耗食材
   */
  async consumeFoodItem(id: number, amount: number = 1): Promise<boolean> {
    try {
      return await this.repo.consume(id, amount)
    } catch (e) {
      console.error('FoodViewModel consumeFoodItem error: ' + JSON.stringify(e))
      return false
    }
  }

  /**
   * 删除食材
   */
  async deleteFoodItem(id: number): Promise<boolean> {
    try {
      await this.repo.deleteById(id)
      return true
    } catch (e) {
      console.error('FoodViewModel deleteFoodItem error: ' + JSON.stringify(e))
      return false
    }
  }

  /**
   * 按过期状态排序
   */
  private sortByExpiryStatus(items: FoodItem[]): FoodItem[] {
    return items.sort((a, b) => {
      const statusA = DateUtils.getExpiryStatus(a.expiryDate)
      const statusB = DateUtils.getExpiryStatus(b.expiryDate)
      if (statusA !== statusB) {
        return statusA - statusB
      }
      // 相同状态按过期日期升序
      return a.expiryDate - b.expiryDate
    })
  }
}

/**
 * 首页数据结构
 */
export interface HomeData {
  totalCount: number
  expiredCount: number
  expiringSoonCount: number
  expiredItems: FoodItem[]
  expiringSoonItems: FoodItem[]
  recentItems: FoodItem[]
  categoryCount: number[]
}
