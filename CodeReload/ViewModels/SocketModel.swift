import Foundation
import Combine

class SocketModel : ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    var isConnected:Bool = false
    @Published var isBrowserConnected:Bool = false
    
    init() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2){
            self.connect()
        }
    }
    
    func connect() {
        let url = URL(string: "ws://localhost:35729/ws")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
        print("Connected to websocket")
        self.ping()
        self.isConnected = true
    }
    
    func send(text:String) {    
        webSocketTask?.send(.string(text)) { error in
                if let error = error {
                    self.isConnected = false
                    print("Error sending message", error)
                }
            }
    }
    
    func ping() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            self.send(text: "ping")
        }
      }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive)

        if case .success(let message) = incoming {
            switch message {
                case .string(let text):
                if(text == "No browsers connected"){
                    Task {
                        await MainActor.run {
                            self.isBrowserConnected = false
                        }
                    }
                }
                if(text == "Connected from browser"){
                    print("connected from browser")
                    Task {
                        await MainActor.run {
                            self.isBrowserConnected = true
                        }
                    }
                }
                case .data(let data):
                    print(data)
            @unknown default:
                return
            }
        }
        if case .failure(_) = incoming {
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                if(!self.isConnected){
                    print("Attempting to re-connect to websocket.")
                    self.connect()
                }
            }
        }
    }
    
    deinit {
        disconnect()
    }
}
