import SwiftState

/// 暴击状态
enum CriticalState {
    // 进房间
    case normal
    // 抢占机台
    case userStartGame(remainSec: TimeInterval)

    // 确定暴击 或 立即开始
    case fired(usedCrit: Bool)

    // 弹出结果弹窗
    case gameGetResult

    // 能量增加动画
    case gameDidFinished
}

extension CriticalState: Equatable {

    static func ==(lhs: CriticalState, rhs: CriticalState) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CriticalState: StateType {}
