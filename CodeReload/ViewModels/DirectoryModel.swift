import Foundation
import FileWatcher
import SwiftUI

class DirectoryModel: ObservableObject {
    let defaults = UserDefaults.standard
    @Published var directoryArr:[Directories] = [Directories]()

    func saveDirectoryToDevice() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(directoryArr) {
            defaults.set(encoded, forKey: "directoryArr")
        }
    }
    
    func loadDirectoryFromDevice() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: "directoryArr") {
            let array = try! decoder.decode([Directories].self, from: data)
            directoryArr = array
        }
    }
            
    func watchSavedDirectories(directoryarr:DirectoryModel, socket: SocketModel){
        for dir in directoryArr {
            self.watchDirectory(path: dir.path, id: dir.id, socket: socket)
        }
    }
    
    func selectDirectory(directoryUrl:URL? = nil) -> Array<URL> {
        let openPanel = NSOpenPanel();
        var path:[URL] = [URL]()
        
        openPanel.allowsMultipleSelection = false;
        openPanel.canChooseDirectories = true;
        openPanel.canChooseFiles = false;
        
        if(directoryUrl != nil){
            openPanel.directoryURL = directoryUrl
        }
        
        let response = openPanel.runModal()
        if response == .OK {
            path = openPanel.urls
        }
        
        return path
    }
    
    func returnPathFromURL(url:URL) -> String! {
        return String("\(url)".dropFirst(7).dropLast()).removingPercentEncoding
    }
        
    func addDirectory(socket:SocketModel) -> Directories? {
        let id:UUID = UUID()
        let path = self.selectDirectory()
        
        if(path.count > 0){
            let path_modified = self.returnPathFromURL(url: path[0])
            let name = path_modified!.components(separatedBy: "/")
            
            if(!self.checkForDuplicates(path: path_modified!)){
                directoryArr.append(
                    Directories(id: id, url: path[0], path: path_modified! , name: name[name.count-1].removingPercentEncoding!, customName: name[name.count-1].removingPercentEncoding!)
                )
            }
            
            self.saveDirectoryToDevice()
            
            self.watchDirectory(path: path_modified!, id:id, socket:socket)
        }
        
        return self.directoryArr.last
    }
    
    func removeDirectory(id:UUID) -> Any{
        for i in 0..<directoryArr.count {
            if(id == directoryArr[i].id){
                directoryArr.remove(at: i)
                break
            }
        }
        
        self.saveDirectoryToDevice()
        
        if(directoryArr.last != nil){
            return directoryArr.last!
        } else {
            return false
        }
    }
    
    func addDirectoryExclusion(directoryId:UUID){
        for i in 0..<directoryArr.count {
            if(directoryId == directoryArr[i].id){
                let url = self.selectDirectory(directoryUrl: directoryArr[i].url)
                
                if(url.count > 0){
                    let urlString:String = "\(url[0])"
                    
                    if(!urlString.contains(directoryArr[i].path)){
                        break
                    }
                    
                    let path = self.returnPathFromURL(url: url[0])!
                    var shortenedPath = "";
                    var pathSplit = path.split(separator: "/")
                    var pathBeginningFound:Bool = false;
                    
                    innerLoop: for text in pathSplit {
                        if(pathBeginningFound){
                            break innerLoop
                        }
                        if(text != directoryArr[i].name) {
                            pathSplit.remove(at: 0)
                        } else {
                            pathBeginningFound = true
                        }
                    }
                    
                    shortenedPath = "../\(pathSplit.joined(separator:"/"))"
                    
                    if(!directoryArr[i].excludedFolders.contains(shortenedPath)){
                        directoryArr[i].excludedFolders.append(shortenedPath)
                        self.saveDirectoryToDevice()
                    }
                }
                break
            }
        }
    }
    
    func removeDirectoryExclusion(directoryId:UUID, folder:String){
        for i in 0..<directoryArr.count {
            if(directoryId == directoryArr[i].id){
                directoryArr[i].excludedFolders = directoryArr[i].excludedFolders.filter { $0 != folder }
            }
        }
    }
    
    func disableIsEditing(currentId:UUID){
        for i in 0..<directoryArr.count {
            if(currentId != directoryArr[i].id){
                directoryArr[i].isEditing = false
            }
        }
        
        self.saveDirectoryToDevice()
    }
    
    func updateCustomName(id:UUID, customName:String){
        for i in 0..<directoryArr.count {
            if(id == directoryArr[i].id){
                directoryArr[i].customName = customName
                directoryArr[i].isEditing = false
            }
        }
        
        self.saveDirectoryToDevice()
    }
    
    func checkForDuplicates(path:String) -> Bool {
        for dir in directoryArr {
            if(dir.path == path) {
                return true
            }
        }
        
        return false
    }
    
    func getDirectory(id:UUID) -> Directories{
        for dir in directoryArr {
            if(dir.id == id){
                return dir
            }
        }
        
        return directoryArr[0]
    }
    
    func watchDirectory(path:String, id:UUID, socket:SocketModel) {
        let filewatcher = FileWatcher([NSString(string: path).expandingTildeInPath])

        filewatcher.callback = { event in
            let path = event.path
            socket.send(text: "Directory has changed")
        }

        filewatcher.start()
        
        self.checkForDeletion(id:id, filewatcher:filewatcher)
    }
    
    func checkForDeletion(id:UUID, filewatcher:FileWatcher) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            var isDeleted = true
            for dir in self.directoryArr {
                if dir.id == id {
                    isDeleted = false
                }
            }
            
            if(isDeleted){
                filewatcher.stop()
            } else {
                self.checkForDeletion(id: id, filewatcher: filewatcher)
            }
        }
    }
}
