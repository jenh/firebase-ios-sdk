// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FirebaseAppCheck
import FirebaseCore
import FirebaseRemoteConfig
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication
      .LaunchOptionsKey: Any]? = nil) -> Bool {

    FirebaseApp.configure()

    // Recommendation: Protect your Vertex AI API resources from abuse by preventing unauthorized
    // clients using App Check; see https://firebase.google.com/docs/app-check#get_started.
    AppCheck.setAppCheckProviderFactory(AppCheckNotConfiguredFactory())

    if let firebaseApp = FirebaseApp.app(), firebaseApp.options.projectID == "mockproject-1234" {
      guard let bundleID = Bundle.main.bundleIdentifier else { fatalError() }
      fatalError("""
      You must create and/or download a valid `GoogleService-Info.plist` file for \(bundleID) from \
      https://console.firebase.google.com to run this sample. Replace the existing \
      `GoogleService-Info.plist` file in the `FirebaseVertexAI/Sample` directory with this new file.
      """)
    }

    // Now that Firebase is configured, set up Remote Config
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0 // For development only.
    remoteConfig.configSettings = settings

    // Set default values
    remoteConfig.setDefaults([
      "model_name": "gemini-1.5-flash" as NSObject,
      "chat_preamble": "" as NSObject
    ])
                          
    // Fetch and activate Remote Config values
    remoteConfig.fetchAndActivate { status, error in
      if let error = error {
        print("Error fetching remote config: \(error.localizedDescription)")
      }
    }
    return true
  }
}

@main
struct VertexAISampleApp: App {
  @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

/// Placeholder App Check provider factory that returns a simple ``AppCheckNotConfigured`` error.
private class AppCheckNotConfiguredFactory: NSObject, AppCheckProviderFactory {
  private class AppCheckNotConfiguredProvider: NSObject, AppCheckProvider {
    func getToken() async throws -> AppCheckToken {
      throw AppCheckNotConfigured()
    }
  }

  func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
    return AppCheckNotConfiguredProvider()
  }
}

/// Error indicating that App Check is not configured in the sample app.
struct AppCheckNotConfigured: Error {}
