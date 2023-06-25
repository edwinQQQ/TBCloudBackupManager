//
//  ContentView.swift
//  TBCloudBackupManager
//
//  Created by eqi on 2023/6/20.
//

import SwiftUI

struct ContentView: View {
    let cloudBackupManager = TBCloudBackupManager.shared
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Try upload test content") {
                cloudBackupManager.createDemoDocument()
            }
            Button("Try overwrite test content") {
                cloudBackupManager.overwriteDemoDocument()
            }
            Button("Try delete test content") {
                cloudBackupManager.deleteDemoDocument()
            }
            Button("Try search test contests") {
                cloudBackupManager.getDocument()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
