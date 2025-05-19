import Argo
import Curry
import Runes

// READY: 服务端当成功处理 user-play-game 事件后马上发送此状态
//
// GO: 机台开始运行时发送此状态
//
// ACT: 机台出球时发送此状态
//
// WIN: 机台结束时返回此状态
//
// ERR: 以上3种状态，某一步出错时返回此状态
// 房间游戏状态，在房间内的所有人都能收到
struct Game {

    enum State: String {
        // 抢占成功
        case ready = "READY"
        // 开始扭蛋
        case go    = "GO"
        // 揭晓结果
        case win   = "WIN"
        // 错误
        case err   = "ERR"
        // 出球
        case act   = "ACT"
        // 霸机充值
        case recharge = "RECHARGE"

        // 手动 reset 状态，此状态不由服务器返回
        case reset = "RESET"
    }
}
extension Game.State: Argo.Decodable {}

/// 遵守这个 protocol 的 UI 为游戏组件，能收到 GameComponentAction 中定义的事件
protocol GameComponent {}

// extension GameExchangeButton: GameComponent {}
// extension GameRechargeButton: GameComponent {}
// extension GamePlayingButton: GameComponent {}
// extension GameIdleButton: GameComponent {}
// extension GameCountdownView: GameComponent {}
// extension GameErrorView: GameComponent {}
// extension AudioService: GameComponent {}
// extension GamePopOverView: GameComponent {}
//// 其实这里应该继续把 navigation 拆出来
// extension GameViewController: GameComponent {}

// New
extension GameNewExchangeButton: GameComponent {}
extension GameNewRechargeButton: GameComponent {}
extension GameNewPlayingButton: GameComponent {}
extension GameNewIdleButton: GameComponent {}
extension GameNewCountdownView: GameComponent {}
extension GameErrorView: GameComponent {}
extension AudioService: GameComponent {}
extension GamePopOverView: GameComponent {}

protocol GameComponentAction {
    func on(state: Game.State)
}

extension GameComponentAction where Self: GameComponent {
    func on(state: Game.State) {}
}
