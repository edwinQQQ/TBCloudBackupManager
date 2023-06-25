import Foundation
import UIKit

class TBCloudBackupManager {
    static let shared = TBCloudBackupManager()

    private let fileManager = FileManager.default
    private var ubiquityContainerIdentifier: String {
        get {
#if DEBUG
            return "iCloud.com.theknot.thebump.qa"
#else
            return "iCloud.com.theknot.thebump"
#endif
        }
    }
    private var appDocumentPath: String {
//#if DEBUG
//            return "Documents"  // Files will visible to user in 'Files' App
//#else
            return "The_Bump_Documents" // Files are invisible
//#endif
    }
    private var docURL: URL?

    init() {
        setupEnv()
    }

    private func iCloudAvailable() -> Bool {
        guard let _ = fileManager.ubiquityIdentityToken else {
            return false
        }
        return true
    }

    private func setupEnv() {
        guard let docURL = FileManager.default.url(forUbiquityContainerIdentifier: ubiquityContainerIdentifier)
        else {
            return
        }

        self.docURL = docURL.appendingPathComponent(appDocumentPath, isDirectory: true)

        guard let url = self.docURL else { return }
        if fileManager.fileExists(atPath: url.path) == false {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("create path error: \(error)")
            }
        }
    }

    private func loadFilePath(with fileName: String) -> URL? {
        guard let docURL else {
            return nil
        }

        return docURL.appending(path: fileName)
    }

    func getDocument() {
        let metadataQuery = NSMetadataQuery()
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery.valueListAttributes = [NSMetadataItemFSNameKey, NSMetadataItemPathKey]

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering,
                                               object: metadataQuery,
                                               queue: nil) { notification in
            metadataQuery.disableUpdates()
            metadataQuery.stop()

            let results = metadataQuery.results
            for item in results {
                    if let name = (item as AnyObject).value(forAttribute: NSMetadataItemFSNameKey) as? String,
                       let path = (item as AnyObject).value(forAttribute: NSMetadataItemPathKey) as? String {
                        print("Name: \(name), \nPath: \(path)")
                    }
                }
//            print("search doc: \(result)")
        }

        metadataQuery.enableUpdates()
        metadataQuery.start()
    }
}

extension TBCloudBackupManager {
    func createDemoDocument() {

        let fileName = "demo 2.txt"
        guard let filePathURL = loadFilePath(with: fileName) else {
            return
        }
        let tbUIDocument = TBUIDocument(fileURL: filePathURL)

        let testContent = "TB iCloud Document test content"
        tbUIDocument.tbContent = testContent.data(using: .utf8)

        tbUIDocument.save(to: filePathURL,
                          for: .forOverwriting) { isSuccess in
            print("is upload success \(isSuccess)")
        }
    }

    func overwriteDemoDocument() {
        let fileName = "demo 2.txt"
        guard let filePathURL = loadFilePath(with: fileName) else {
            return
        }
        let tbUIDocument = TBUIDocument(fileURL: filePathURL)

        let testContent = "TB iCloud Document test content is Update!"
        tbUIDocument.tbContent = testContent.data(using: .utf8)

        tbUIDocument.save(to: filePathURL,
                          for: .forCreating) { isSuccess in
            print("is over write success \(isSuccess)")
        }
    }

    func deleteDemoDocument() {
        let fileName = "demo 2.txt"
        guard let filePathURL = loadFilePath(with: fileName) else {
            return
        }

        do {
            try fileManager.removeItem(at: filePathURL)
            print("is delete success")
        } catch {
            print("is delete failure \(error)")
        }
    }
}


class TBUIDocument: UIDocument {
    var tbContent: Data?
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        print("iCloud: \(contents)")
        tbContent = contents as? Data
    }

    override func contents(forType typeName: String) throws -> Any {
        if tbContent == nil {
            tbContent = Data()
        }
        return tbContent ?? "nil"
    }
}
