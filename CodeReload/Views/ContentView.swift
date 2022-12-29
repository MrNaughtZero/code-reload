import SwiftUI
import ReloadServer

struct ContentView: View {
    @StateObject var directories:DirectoryModel = DirectoryModel()
    @MainActor @StateObject var socket:SocketModel = SocketModel()
    @State private var activeFolder:Directories?
    @State var showExtensionPopup:Bool = false
    let server = ReloadServer()
            
    @ViewBuilder
    var body: some View {
        HStack {
            Navigation(directories: directories, activeFolder: $activeFolder, showExtensionPopup: $showExtensionPopup)
                .environmentObject(socket)
            Main(directories: directories, activeFolder: $activeFolder, showExtensionPopup: $showExtensionPopup)
        }
        .frame(width:750, height:500)
        .onAppear() {
            directories.loadDirectoryFromDevice()
            directories.watchSavedDirectories(directoryarr: directories, socket: socket)
            activeFolder = directories.directoryArr.first
            server.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
