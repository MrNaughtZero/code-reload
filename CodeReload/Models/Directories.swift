import Foundation

struct Directories: Hashable, Codable {
    var id:UUID = UUID()
    var url:URL
    var path:String
    var name:String
    var customName:String
    var isEditing:Bool = false
    var excludedExtensions:[String] = []
    var excludedFolders:[String] = []
    var processingDelay:Int = 0
    var runCommand:Bool = false
    var command:String = ""
}
