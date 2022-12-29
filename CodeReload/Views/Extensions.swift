import SwiftUI

struct Extensions: View {
    @ObservedObject var directories:DirectoryModel
    @Binding var showExtensionPopup:Bool
    @Binding var activeFolder:Directories?
    @State var currentlySelectedExcludedFolder:String = ""
    
    @ViewBuilder
    var body: some View {
        if(activeFolder != nil){
            Section {
                VStack {
                    VStack {
                        HStack {
                            Text("Extensions to exclude:")
                                .frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: 250, alignment:.leading)
                                .padding([.bottom], 10)
                            
                            Spacer()
                            
                            HStack {
                                Button() {
                                    showExtensionPopup = true
                                } label: {
                                    Image("delete")
                                        .resizable()
                                        .frame(width:15, height:15)
                                }
                                
                                .buttonStyle(PlainButtonStyle())
                                
                                Button() {
                                    print("add new exclude dir")
                                } label: {
                                    Image("add")
                                        .resizable()
                                        .frame(width:13, height:13)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        List {
                            ForEach(activeFolder!.excludedExtensions, id:\.self) { item in
                                Text(item)
                            }
                        }
                        .frame(minWidth:0, maxWidth: .infinity, minHeight: 100, maxHeight: 150, alignment:.leading)
                        .offset(y:-10)
                    }
                    
                    VStack {
                        HStack {
                            Text("Folders to exclude:")
                                .frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: 250, alignment:.leading)
                                .padding([.bottom], 10)
                            
                            HStack {
                                if(currentlySelectedExcludedFolder != ""){
                                    Button() {
                                        directories.removeDirectoryExclusion(directoryId: activeFolder!.id, folder:currentlySelectedExcludedFolder)
                                        activeFolder = directories.directoryArr.last
                                        currentlySelectedExcludedFolder = ""
                                    } label: {
                                        Image("delete")
                                            .resizable()
                                            .frame(width:15, height:15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Button() {
                                    directories.addDirectoryExclusion(directoryId: activeFolder!.id)
                                    activeFolder = directories.directoryArr.last
                                } label: {
                                    Image("add")
                                        .resizable()
                                        .frame(width:13, height:13)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        List {
                            ForEach(activeFolder!.excludedFolders, id:\.self) { item in
                                Text(item)
                                    .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
                                    .onTapGesture {
                                        currentlySelectedExcludedFolder = item
                                    }
                                    .padding(4)
                                    .background(currentlySelectedExcludedFolder == item ? Color(red: 0.149, green: 0.106, blue: 0.161) : nil)
                            }
                        }
                        //.listStyle(PlainListStyle())
                        .frame(minWidth:0, maxWidth: .infinity, minHeight: 100, maxHeight: 150, alignment:.leading)
                        .offset(y:-10)
                    }
                    
                    VStack {
                        Button {
                            showExtensionPopup = false
                        } label: {
                            Text("Save")
                                .padding(15)
                        }
                    }
                    .frame(minWidth:0, maxWidth: .infinity, alignment:.trailing)
                    .offset(y:5)
                }
                .padding(20)
                .frame(minWidth:0, maxWidth:.infinity, minHeight: 0, maxHeight: .infinity)
                .offset(y:-5)
            }
            .background(RoundedCorners(color: Color(red: 0.149, green: 0.106, blue: 0.161), tl: 0, tr: 0, bl: 10, br: 10))
            .frame(minWidth:0, maxWidth: .infinity, minHeight:0, maxHeight:380)
            .padding(20)
            .offset(y:!showExtensionPopup ? 500 : 45)
            .animation(Animation.easeInOut(duration: 0.5), value: showExtensionPopup)
        }
    }
}

struct Extension_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
