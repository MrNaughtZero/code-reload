import Foundation
import SwiftUI

struct Navigation: View {
    @State private var customFolderName:String = ""
    @ObservedObject var directories:DirectoryModel
    @Binding var activeFolder:Directories?
    @Binding var showExtensionPopup:Bool
    @EnvironmentObject var socket:SocketModel
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Text("Watched Folders")
                    .font(.system(size:15, weight:.semibold))
            }
            .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
            .padding([.top, .leading], 20)
            
            if(activeFolder == nil) {
                HStack {
                    Text("You're not watching any folders 😔")
                        .multilineTextAlignment(.center)
                        .frame(minWidth:150, maxWidth:150, minHeight:0, maxHeight: .infinity, alignment: .center)
                        .offset(y:-10)
                }
            }
            
            if(activeFolder != nil) {
                ScrollView {
                    VStack {
                        ForEach(0..<directories.directoryArr.count, id:\.self) { i in
                            HStack {
                                Image("folder")
                                    .resizable()
                                    .frame(width:15, height:15)
                                if(!directories.directoryArr[i].isEditing){
                                    Text("\(directories.directoryArr[i].customName)")
                                        .onTapGesture(count:2) {
                                            directories.directoryArr[i].isEditing = true
                                            customFolderName = directories.directoryArr[i].customName
                                            
                                            directories.disableIsEditing(currentId:directories.directoryArr[i].id)
                                        }
                                }
                                
                                if(directories.directoryArr[i].isEditing){
                                    TextField(
                                        "\(directories.directoryArr[i].customName)",
                                        text: $customFolderName
                                    )
                                    .onSubmit {
                                        if(customFolderName.count < 1) {
                                            customFolderName = directories.directoryArr[i].customName
                                        }
                                        directories.updateCustomName(id: directories.directoryArr[i].id, customName: customFolderName)
                                    }
                                    .frame(width:140)
                                }
                            }
                            .frame(width:180, alignment: .leading)
                            .contentShape(Rectangle())
                            .padding(.all, 7.0)
                            .contextMenu {
                                Button {
                                    directories.directoryArr[i].isEditing = true
                                    customFolderName = directories.directoryArr[i].customName
                                } label: {
                                    Label("Rename", systemImage: "globe")
                                }
                                Button {
                                    let removeDir = directories.removeDirectory(id: directories.directoryArr[i].id)
                                    activeFolder = removeDir as? Directories ?? nil
                                    showExtensionPopup = false
                                } label: {
                                    Label("Delete", systemImage: "bin")
                                }
                            }
                            
                            .onTapGesture(count: 1) {
                                showExtensionPopup = false
                                activeFolder = directories.directoryArr[i]
                            }
                            .background((directories.directoryArr[i].id == (activeFolder != nil ? activeFolder!.id : nil)) ? Color(red: 0.122, green: 0.106, blue: 0.145) : nil)
                            .offset(x:-18, y: i > 0 ? (CGFloat(-2) - CGFloat(i) * 3) : 0)
                        }
                        Spacer()
                        .frame(alignment:.topLeading)
                    }
                    .frame(minHeight:0, maxHeight:.infinity, alignment: .leading)
                    .offset(x:20)
                }
            }
            
            HStack {
                if(activeFolder != nil && socket.isBrowserConnected) {
                    HStack {
                        Circle()
                            .fill(Color(red: 0.235, green: 0.702, blue: 0.443))
                            .frame(width:15, height:15)
                        Text("Connected")
                            .font(.system(size:12))
                    }
                    .offset(x:35)
                }
                if(activeFolder != nil && !socket.isBrowserConnected) {
                    HStack {
                        Circle()
                            .fill(Color(red: 0.863, green: 0.078, blue: 0.235))
                            .frame(width:15, height:15)
                        Text("Disconnected")
                            .font(.system(size:12))
                    }
                    .offset(x:35)
                }
                Spacer()
                Button() {
                    activeFolder = directories.addDirectory(socket:socket)
                } label: {
                    Image("add")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(minWidth:0, maxWidth:.infinity, alignment:.trailing)
            .offset(x:-15, y:-15)
        }
        .frame(width:220, height: 500)
        .background(Color(red: 0.149, green: 0.106, blue: 0.161))
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
