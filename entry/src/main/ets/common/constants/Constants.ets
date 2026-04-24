// 食材分类枚举
export enum FoodCategory {
  MEAT = 0,
  VEGETABLE = 1,
  FRUIT = 2,
  DAIRY_EGG = 3,
  CONDIMENT = 4,
  FROZEN_FOOD = 5,
  LEFTOVER = 6
}

// 存放位置枚举
export enum StorageLocation {
  FREEZER = 0,
  FRIDGE = 1,
  ROOM_TEMP = 2
}

// 过期状态枚举
export enum ExpiryStatus {
  EXPIRED = 0,
  EXPIRING_SOON = 1,
  FRESH = 2,
  NO_EXPIRY = 3
}

// 分类项类（替代匿名对象字面量）
export class CategoryItem {
  value: number = 0
  name: string = ''

  constructor(value: number, name: string) {
    this.value = value
    this.name = name
  }
}

// 分类名称查询函数（替代 Record<number, string>）
export function getCategoryName(category: number): string {
  switch (category) {
    case FoodCategory.MEAT:
      return '肉类'
    case FoodCategory.VEGETABLE:
      return '蔬菜'
    case FoodCategory.FRUIT:
      return '水果'
    case FoodCategory.DAIRY_EGG:
      return '乳制品/蛋'
    case FoodCategory.CONDIMENT:
      return '调料/干货'
    case FoodCategory.FROZEN_FOOD:
      return '冷冻速食'
    case FoodCategory.LEFTOVER:
      return '剩菜剩饭'
    default:
      return '未知'
  }
}

// 分类列表
export const FoodCategoryList: CategoryItem[] = [
  new CategoryItem(FoodCategory.MEAT, '肉类'),
  new CategoryItem(FoodCategory.VEGETABLE, '蔬菜'),
  new CategoryItem(FoodCategory.FRUIT, '水果'),
  new CategoryItem(FoodCategory.DAIRY_EGG, '乳制品/蛋'),
  new CategoryItem(FoodCategory.CONDIMENT, '调料/干货'),
  new CategoryItem(FoodCategory.FROZEN_FOOD, '冷冻速食'),
  new CategoryItem(FoodCategory.LEFTOVER, '剩菜剩饭')
]

// 存放位置名称查询函数
export function getStorageLocationName(location: number): string {
  switch (location) {
    case StorageLocation.FREEZER:
      return '冷冻'
    case StorageLocation.FRIDGE:
      return '冷藏'
    case StorageLocation.ROOM_TEMP:
      return '常温'
    default:
      return '未知'
  }
}

// 存放位置列表
export const StorageLocationList: CategoryItem[] = [
  new CategoryItem(StorageLocation.FREEZER, '冷冻'),
  new CategoryItem(StorageLocation.FRIDGE, '冷藏'),
  new CategoryItem(StorageLocation.ROOM_TEMP, '常温')
]

// 单位列表
export const UnitOptions: string[] = ['个', '斤', '袋', '盒', '瓶', '包', '块', '根', '把', '碗', '份']

// 颜色常量类（替代未声明类型的对象字面量）
export class AppColors {
  static readonly EXPIRED: string = '#E74C3C'
  static readonly EXPIRING_SOON: string = '#F39C12'
  static readonly FRESH: string = '#27AE60'
  static readonly NO_EXPIRY: string = '#95A5A6'
  static readonly FREEZER: string = '#3498DB'
  static readonly FRIDGE: string = '#2ECC71'
  static readonly ROOM_TEMP: string = '#95A5A6'
  static readonly PRIMARY: string = '#3498DB'
  static readonly BACKGROUND: string = '#F5F5F5'
  static readonly CARD_BACKGROUND: string = '#FFFFFF'
  static readonly TEXT_PRIMARY: string = '#2C3E50'
  static readonly TEXT_SECONDARY: string = '#7F8C8D'
  static readonly DIVIDER: string = '#ECF0F1'
}

// 数据库常量类
export class DBConfig {
  static readonly DB_NAME: string = 'fridgenote.db'
  static readonly DB_VERSION: number = 1
  static readonly TABLE_NAME: string = 'food_item'
}

// 临期天数阈值
export const EXPIRING_SOON_DAYS: number = 3
