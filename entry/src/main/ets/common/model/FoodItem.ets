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

  toDbValues(): Record<string, Object> {
    return {
      'name': this.name,
      'category': this.category,
      'storageLocation': this.storageLocation,
      'quantity': this.quantity,
      'unit': this.unit,
      'purchaseDate': this.purchaseDate,
      'expiryDate': this.expiryDate,
      'notes': this.notes,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt
    }
  }
}
