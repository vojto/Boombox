//
//  AppDelegate.swift
//  Boombox
//
//  Created by Vojtech Rinik on 12/10/2019.
//  Copyright © 2019 Vojtech Rinik. All rights reserved.
//

import Cocoa
import SwiftUI
import OAuth2
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow!
    var tickersWindow: TickersWindow!
    
    var oauth: OAuth2CodeGrant
    var alamofire: SessionManager

    static var instance: AppDelegate!
    
    override init() {
        let authorizeUri = "https://accounts.spotify.com/authorize"
        let tokenUri = "https://accounts.spotify.com/api/token"
        
        self.oauth = OAuth2CodeGrant(settings: [
            "authorize_uri": authorizeUri,
            "token_uri": tokenUri,
            "client_id": "ab9cca6db343470e91de316d72223a8f",
            "client_secret": "6b6e3a1db27944009f707a4877cfd29d",
            "response_type": "code",
            "redirect_uris": ["boombox://oauth/callback"],
            "scope": "user-library-read",
            "parameters": [
                "method": "get"
            ]
        ] as OAuth2JSON)
        
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: self.oauth)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        self.alamofire = sessionManager
        
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.instance = self
        
        let contentView = ContentView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environmentObject(TracksManager())

        // Create the window and set the content view. 
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        mainWindow.center()
        mainWindow.setFrameAutosaveName("Main Window")
        mainWindow.contentView = NSHostingView(rootView: contentView)
        mainWindow.makeKeyAndOrderFront(nil)
        
        tickersWindow = TickersWindow()
        tickersWindow.makeKeyAndOrderFront(nil)
        
        self.loginToSpotify()
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidChangeScreenParameters(_ notification: Notification) {
        tickersWindow.updateFrame()
    }
    
    // MARK: - Dicking around with Spotify
    func loginToSpotify() {
//        oauth.authorize { (json, error) in
//            print("finished authorizing!")
//            print("json: \(json)")
//            print("error: \(error)")
//        }
    }
    
    // MARK: - Handle custom scheme
    
    func application(_ application: NSApplication, open urls: [URL]) {
        let url = urls[0]
        self.oauth.handleRedirectURL(url)
    }
    
//    func application(_ application: NSApplication,
//                     open url: URL,
//                     options: [NSApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {
//
//        // Determine who sent the URL.
//        let sendingAppID = options[.sourceApplication]
//        print("source application = \(sendingAppID ?? "Unknown")")
//
//        // Process the URL.
//        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//            let albumPath = components.path,
//            let params = components.queryItems else {
//                print("Invalid URL or album path missing")
//                return false
//        }
//
//        if let photoIndex = params.first(where: { $0.name == "index" })?.value {
//            print("albumPath = \(albumPath)")
//            print("photoIndex = \(photoIndex)")
//            return true
//        } else {
//            print("Photo index missing")
//            return false
//        }
//    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Boombox")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

