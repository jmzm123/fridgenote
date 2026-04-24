import { ValuesBucket } from '@kit.ArkData'

export class FoodItem {
  id: number = 0
  name: string = ''
  category: number = 0
  storageLocation: number = 1
  quantity: number = 1
  unit: string = '个'
  purchaseDate: number = 0
  expiryDate: number = 0
  notes: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  constructor() {
    const now = Date.now()
    this.purchaseDate = now
    this.createdAt = now
    this.updatedAt = now
  }

  toValuesBucket(): ValuesBucket {
    const bucket: ValuesBucket = {}
    bucket.name = this.name
    bucket.category = this.category
    bucket.storageLocation = this.storageLocation
    bucket.quantity = this.quantity
    bucket.unit = this.unit
    bucket.purchaseDate = this.purchaseDate
    bucket.expiryDate = this.expiryDate
    bucket.notes = this.notes
    bucket.createdAt = this.createdAt
    bucket.updatedAt = this.updatedAt
    return bucket
  }
}
