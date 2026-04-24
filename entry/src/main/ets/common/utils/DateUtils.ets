import { ExpiryStatus, EXPIRING_SOON_DAYS } from '../constants/Constants'

export class DateUtils {
  /**
   * 计算过期状态
   * @param expiryDate 保质期时间戳(ms)，0表示无保质期
   * @returns ExpiryStatus
   */
  static getExpiryStatus(expiryDate: number): ExpiryStatus {
    if (expiryDate === 0) {
      return ExpiryStatus.NO_EXPIRY
    }
    const now = Date.now()
    if (expiryDate < now) {
      return ExpiryStatus.EXPIRED
    }
    const diffDays = DateUtils.getDaysDiff(now, expiryDate)
    if (diffDays <= EXPIRING_SOON_DAYS) {
      return ExpiryStatus.EXPIRING_SOON
    }
    return ExpiryStatus.FRESH
  }

  /**
   * 计算两个时间戳之间相差的天数（向上取整）
   */
  static getDaysDiff(fromTs: number, toTs: number): number {
    const fromDay = Math.floor(fromTs / (24 * 60 * 60 * 1000))
    const toDay = Math.floor(toTs / (24 * 60 * 60 * 1000))
    return toDay - fromDay
  }

  /**
   * 获取剩余天数描述
   */
  static getRemainingDaysText(expiryDate: number): string {
    if (expiryDate === 0) {
      return '无保质期'
    }
    const now = Date.now()
    const diffDays = DateUtils.getDaysDiff(now, expiryDate)
    if (diffDays < 0) {
      return `已过期${Math.abs(diffDays)}天`
    } else if (diffDays === 0) {
      return '今天到期'
    } else {
      return `剩余${diffDays}天`
    }
  }

  /**
   * 时间戳转日期字符串 (YYYY-MM-DD)
   */
  static formatDate(ts: number): string {
    if (ts === 0) {
      return ''
    }
    const date = new Date(ts)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * 日期字符串转时间戳 (当天23:59:59)
   */
  static dateStrToTimestamp(dateStr: string): number {
    if (!dateStr) {
      return 0
    }
    const parts = dateStr.split('-')
    const date = new Date(
      parseInt(parts[0]),
      parseInt(parts[1]) - 1,
      parseInt(parts[2]),
      23, 59, 59
    )
    return date.getTime()
  }

  /**
   * 获取今天的日期字符串 (YYYY-MM-DD)
   */
  static getTodayStr(): string {
    return DateUtils.formatDate(Date.now())
  }

  /**
   * 获取N天后的日期字符串 (YYYY-MM-DD)
   */
  static getFutureDateStr(days: number): string {
    const ts = Date.now() + days * 24 * 60 * 60 * 1000
    return DateUtils.formatDate(ts)
  }
}
