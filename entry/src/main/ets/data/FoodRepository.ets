import { relationalStore } from '@kit.ArkData'
import { DBConfig } from '../common/constants/Constants'
import { FoodItem } from '../common/model/FoodItem'
import { BusinessError } from '@kit.BasicServicesKit'

const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS ${DBConfig.TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category INTEGER NOT NULL,
    storageLocation INTEGER NOT NULL,
    quantity REAL NOT NULL,
    unit TEXT NOT NULL,
    purchaseDate INTEGER NOT NULL,
    expiryDate INTEGER NOT NULL,
    notes TEXT NOT NULL DEFAULT '',
    createdAt INTEGER NOT NULL,
    updatedAt INTEGER NOT NULL
  )
`

export class FoodRepository {
  private rdbStore: relationalStore.RdbStore | null = null
  private static instance: FoodRepository

  private constructor() {}

  static getInstance(): FoodRepository {
    if (!FoodRepository.instance) {
      FoodRepository.instance = new FoodRepository()
    }
    return FoodRepository.instance
  }

  async init(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DBConfig.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      }
      this.rdbStore = await relationalStore.getRdbStore(context, config)
      if (this.rdbStore) {
        await this.rdbStore.executeSql(CREATE_TABLE_SQL)
      }
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository init error: ' + err.message)
    }
  }

  private ensureStore(): relationalStore.RdbStore | null {
    return this.rdbStore
  }

  async insert(item: FoodItem): Promise<number> {
    const store = this.ensureStore()
    if (!store) {
      return -1
    }
    try {
      item.updatedAt = Date.now()
      const rowId = await store.insert(DBConfig.TABLE_NAME, item.toDbValues())
      return rowId
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository insert error: ' + err.message)
      return -1
    }
  }

  async update(item: FoodItem): Promise<number> {
    const store = this.ensureStore()
    if (!store) {
      return -1
    }
    try {
      item.updatedAt = Date.now()
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.equalTo('id', item.id)
      const changedRows = await store.update(item.toDbValues(), predicates)
      return changedRows
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository update error: ' + err.message)
      return -1
    }
  }

  async deleteById(id: number): Promise<number> {
    const store = this.ensureStore()
    if (!store) {
      return -1
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.equalTo('id', id)
      const deletedRows = await store.delete(predicates)
      return deletedRows
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository deleteById error: ' + err.message)
      return -1
    }
  }

  async queryById(id: number): Promise<FoodItem | null> {
    const store = this.ensureStore()
    if (!store) {
      return null
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.equalTo('id', id)
      const resultSet = await store.query(predicates)
      try {
        if (resultSet.goToFirstRow()) {
          return this.rowToFoodItem(resultSet)
        }
        return null
      } finally {
        resultSet.close()
      }
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryById error: ' + err.message)
      return null
    }
  }

  async queryAll(): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.orderByDesc('createdAt')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryAll error: ' + err.message)
      return []
    }
  }

  async queryByCategory(category: number): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.equalTo('category', category)
      predicates.orderByDesc('createdAt')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryByCategory error: ' + err.message)
      return []
    }
  }

  async queryByStorageLocation(location: number): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.equalTo('storageLocation', location)
      predicates.orderByDesc('createdAt')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryByStorageLocation error: ' + err.message)
      return []
    }
  }

  async queryByName(keyword: string): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.like('name', `%${keyword}%`)
      predicates.orderByDesc('createdAt')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryByName error: ' + err.message)
      return []
    }
  }

  async queryByCategoryAndLocation(category: number, location: number): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      if (category >= 0) {
        predicates.equalTo('category', category)
      }
      if (location >= 0) {
        predicates.equalTo('storageLocation', location)
      }
      predicates.orderByDesc('createdAt')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryByCategoryAndLocation error: ' + err.message)
      return []
    }
  }

  async queryRecent(limit: number = 5): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.orderByDesc('createdAt')
      predicates.limit(limit)
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryRecent error: ' + err.message)
      return []
    }
  }

  async queryByExpiryRange(from: number, to: number): Promise<FoodItem[]> {
    const store = this.ensureStore()
    if (!store) {
      return []
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DBConfig.TABLE_NAME)
      predicates.greaterThan('expiryDate', 0)
      if (from > 0) {
        predicates.greaterThanOrEqualTo('expiryDate', from)
      }
      if (to > 0) {
        predicates.lessThanOrEqualTo('expiryDate', to)
      }
      predicates.orderByAsc('expiryDate')
      const resultSet = await store.query(predicates)
      return this.resultSetToList(resultSet)
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository queryByExpiryRange error: ' + err.message)
      return []
    }
  }

  async queryExpired(): Promise<FoodItem[]> {
    return this.queryByExpiryRange(1, Date.now())
  }

  async queryExpiringSoon(): Promise<FoodItem[]> {
    const now = Date.now()
    const threeDaysLater = now + 3 * 24 * 60 * 60 * 1000
    return this.queryByExpiryRange(now, threeDaysLater)
  }

  async countByCategory(): Promise<number[]> {
    const items = await this.queryAll()
    const countArr: number[] = [0, 0, 0, 0, 0, 0, 0] // 7 categories
    items.forEach(item => {
      const cat = item.category
      if (cat >= 0 && cat < 7) {
        countArr[cat]++
      }
    })
    return countArr
  }

  async consume(id: number, amount: number = 1): Promise<boolean> {
    try {
      const item = await this.queryById(id)
      if (!item) {
        return false
      }
      item.quantity = Math.max(0, item.quantity - amount)
      if (item.quantity <= 0) {
        await this.deleteById(id)
      } else {
        await this.update(item)
      }
      return true
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository consume error: ' + err.message)
      return false
    }
  }

  private resultSetToList(resultSet: relationalStore.ResultSet): FoodItem[] {
    const list: FoodItem[] = []
    try {
      while (resultSet.goToNextRow()) {
        list.push(this.rowToFoodItem(resultSet))
      }
    } catch (e) {
      const err = e as BusinessError
      console.error('FoodRepository resultSetToList error: ' + err.message)
    } finally {
      try {
        resultSet.close()
      } catch (e) {
        console.error('resultSet close error')
      }
    }
    return list
  }

  private rowToFoodItem(resultSet: relationalStore.ResultSet): FoodItem {
    const item = new FoodItem()
    try {
      const idIdx = resultSet.getColumnIndex('id')
      const nameIdx = resultSet.getColumnIndex('name')
      const categoryIdx = resultSet.getColumnIndex('category')
      const locationIdx = resultSet.getColumnIndex('storageLocation')
      const quantityIdx = resultSet.getColumnIndex('quantity')
      const unitIdx = resultSet.getColumnIndex('unit')
      const purchaseIdx = resultSet.getColumnIndex('purchaseDate')
      const expiryIdx = resultSet.getColumnIndex('expiryDate')
      const notesIdx = resultSet.getColumnIndex('notes')
      const createdIdx = resultSet.getColumnIndex('createdAt')
      const updatedIdx = resultSet.getColumnIndex('updatedAt')

      item.id = resultSet.getLong(idIdx)
      item.name = resultSet.getString(nameIdx)
      item.category = resultSet.getLong(categoryIdx)
      item.storageLocation = resultSet.getLong(locationIdx)
      item.quantity = resultSet.getDouble(quantityIdx)
      item.unit = resultSet.getString(unitIdx)
      item.purchaseDate = resultSet.getLong(purchaseIdx)
      item.expiryDate = resultSet.getLong(expiryIdx)
      item.notes = resultSet.getString(notesIdx)
      item.createdAt = resultSet.getLong(createdIdx)
      item.updatedAt = resultSet.getLong(updatedIdx)
    } catch (e) {
      console.error('FoodRepository rowToFoodItem error')
    }
    return item
  }
}
