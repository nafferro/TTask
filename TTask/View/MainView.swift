//
//  MainView.swift
//  TTask
//
//  Created by Nuno Ferro on 31/10/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            HStack () {
                Text("Status: ")
                    .font(.title)
                Text("Still")
                    .font(.title)
            }
            .padding(.top, 50.0)
            HStack () {
                Text("Zone: ")
                    .font(.title)
                Text(viewModel.fence)
                    .font(.title)
            }
            .padding(.top, 50.0)
        }
        .onAppear {
            viewModel.setupGeoFence()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
