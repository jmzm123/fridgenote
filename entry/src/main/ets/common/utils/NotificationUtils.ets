import { notificationManager } from '@kit.NotificationKit'
import { wantAgent } from '@kit.AbilityKit'
import { FoodRepository } from '../../data/FoodRepository'
import { getCategoryName } from '../../constants/Constants'
import { DateUtils } from '../../utils/DateUtils'
import { common } from '@kit.AbilityKit'

export class NotificationUtils {
  private static NOTIFICATION_ID_EXPIRED = 1001
  private static NOTIFICATION_ID_EXPIRING_SOON = 1002

  /**
   * 请求通知权限
   */
  static async requestPermission(context: Context): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        // 打开通知设置页面让用户手动开启
        const contextObj = context as common.UIAbilityContext
        contextObj.startAbility({
          bundleName: 'com.huawei.systemmanager',
          abilityName: 'com.huawei.systemmanager.commontool.MainAbility'
        })
      }
      return enabled
    } catch (e) {
      console.error('NotificationUtils requestPermission error: ' + JSON.stringify(e))
      return false
    }
  }

  /**
   * 检查并推送临期/过期通知
   */
  static async checkAndNotify(): Promise<void> {
    try {
      const repo = FoodRepository.getInstance()
      const expiredItems = await repo.queryExpired()
      const expiringSoonItems = await repo.queryExpiringSoon()

      // 已过期通知
      if (expiredItems.length > 0) {
        const content = expiredItems.slice(0, 5).map(item =>
          `${item.name}(${getCategoryName(item.category)}) - ${DateUtils.getRemainingDaysText(item.expiryDate)}`
        ).join('\n')

        const extraInfo = expiredItems.length > 5 ? `\n...还有${expiredItems.length - 5}项已过期` : ''

        await NotificationUtils.publishNotification(
          NotificationUtils.NOTIFICATION_ID_EXPIRED,
          '食材已过期',
          content + extraInfo
        )
      }

      // 临期通知
      if (expiringSoonItems.length > 0) {
        const content = expiringSoonItems.slice(0, 5).map(item =>
          `${item.name}(${getCategoryName(item.category)}) - ${DateUtils.getRemainingDaysText(item.expiryDate)}`
        ).join('\n')

        const extraInfo = expiringSoonItems.length > 5 ? `\n...还有${expiringSoonItems.length - 5}项即将到期` : ''

        await NotificationUtils.publishNotification(
          NotificationUtils.NOTIFICATION_ID_EXPIRING_SOON,
          '食材即将到期',
          content + extraInfo
        )
      }
    } catch (e) {
      console.error('NotificationUtils checkAndNotify error: ' + JSON.stringify(e))
    }
  }

  /**
   * 发布通知
   */
  private static async publishNotification(id: number, title: string, text: string): Promise<void> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.ethan.fridgenote',
            abilityName: 'EntryAbility'
          }
        ],
        requestCode: 0,
        operationType: wantAgent.OperationType.START_ABILITY,
        flags: wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG
      }

      const agent = await wantAgent.getWantAgent(wantAgentInfo)

      const request: notificationManager.NotificationRequest = {
        id: id,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        },
        wantAgent: agent
      }

      await notificationManager.publish(request)
    } catch (e) {
      console.error('NotificationUtils publishNotification error: ' + JSON.stringify(e))
    }
  }

  /**
   * 取消所有通知
   */
  static async cancelAll(): Promise<void> {
    try {
      await notificationManager.cancelAll()
    } catch (e) {
      console.error('NotificationUtils cancelAll error: ' + JSON.stringify(e))
    }
  }
}
