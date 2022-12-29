import Foundation
import SwiftUI

struct Main: View {
    @ObservedObject var directories:DirectoryModel
    @Binding var activeFolder:Directories?
    @Binding var showExtensionPopup:Bool
    @State private var emptyTextField:String = """
    <script>document.write('<script src="http://localhost:35729/codereload/1"></' + 'script>')</script>
    """
    @State private var showCommandPopup:Bool = false
    
    @ViewBuilder
    var body: some View {
        HStack {
            if(activeFolder == nil){
                Text("Welcome to CodeReload")
                    .font(.largeTitle)
            }
            
            if(activeFolder != nil){
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(red: 0.149, green: 0.106, blue: 0.161))
                            
                        VStack {
                            HStack {
                                Image("folder")
                                    .resizable()
                                    .frame(width:50, height:50)
                                VStack {
                                    Text("\(activeFolder!.customName)")
                                        .font(.system(size:18, weight:.semibold))
                                        .frame(minWidth:0, maxWidth:.infinity, alignment: .leading)
                                        .offset(y:-3)
                                    Text("\(activeFolder!.path)")
                                        .font(.system(size:12))
                                        .frame(minWidth:0, maxWidth:.infinity, alignment: .leading)
                                }
                                .padding(.leading, 5)
                            }
                            .padding([.top, .leading, .trailing], 20)
                            .padding([.bottom], 5)
                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                            Divider()
                            
                            Spacer()
                            
                            VStack {
                                Text("Insert this snippet before </body> or install a browser extension")
                                    .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
                                TextField("Blah", text: $emptyTextField)
                                    .disabled(true)
                                
                                HStack {
                                    Link(destination: URL(string: "https://www.google.co.uk")!){
                                        Image("chrome")
                                            .resizable()
                                            .frame(width:15, height:15)
                                    }
                                    Link(destination: URL(string: "https://www.google.co.uk")!){
                                        Image("firefox")
                                            .resizable()
                                            .frame(width:18, height:18)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                            .offset(y:-30)
                            .padding([.leading, .trailing], 20)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            HStack {
                                Text("Monitoring all extensions and folders")
                                Spacer()
                                Button {
                                    showExtensionPopup = true
                                } label: {
                                    Text("Options...")
                                        .frame(width:60)
                                        .padding(5)
                                }
                            }
                            .padding([.leading, .trailing, .bottom], 20)
                            
                            HStack {
                                HStack {
                                    Text("Run a custom command after processing changes")
                                    Spacer()
                                    Button {
                                        showCommandPopup = true
                                    } label: {
                                        Text("Options...")
                                            .frame(width:60)
                                            .padding(5)
                                    }
                                }
                            }
                            .padding([.leading, .trailing, .bottom], 20)
                        }
                    }
                    .padding(.all, 20.0)
                    
                    Extensions(directories:directories, showExtensionPopup: $showExtensionPopup, activeFolder: $activeFolder)
                }
            }
        }
        .offset(x:-5)
        .frame(width:530, height:500)
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
